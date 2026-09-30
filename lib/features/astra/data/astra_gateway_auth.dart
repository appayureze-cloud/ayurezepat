import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_dtos.dart';

class AstraGatewayAuthException implements Exception {
  final String message;
  AstraGatewayAuthException(this.message);

  @override
  String toString() => message;
}

/// Astra's gateway is a separate auth domain from the main app backend: it
/// issues its own short-lived JWT in exchange for a Firebase ID token
/// (`POST /api/v1/auth/session`), rather than accepting the Firebase token
/// directly like `RetroApi` does for `Apis.baseUrl`. This caches that
/// exchange the same way `CaseRepository` caches `activeCaseId` - across
/// app restarts, refreshed only when it's actually expired.
class AstraGatewayAuth {
  /// A bare Dio with no interceptors of its own - used only for the
  /// session-exchange/refresh calls themselves, which must never recurse
  /// into the auth logic that calls them.
  final Dio _bareDio = Dio(BaseOptions(baseUrl: AstraGatewayApis.baseUrl));

  Future<String> getAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cachedValidToken();
      if (cached != null) return cached;
    }

    final refreshToken =
        SharedPreferenceHelper.getString(Preferences.astraGatewayRefreshToken);
    if (forceRefresh && refreshToken != null && refreshToken.isNotEmpty) {
      try {
        return await _refresh(refreshToken);
      } catch (_) {
        // Refresh token expired/invalid - fall through to a fresh exchange.
      }
    }

    return _exchangeFirebaseToken();
  }

  String? _cachedValidToken() {
    final token =
        SharedPreferenceHelper.getString(Preferences.astraGatewayAccessToken);
    final expiresAt =
        SharedPreferenceHelper.getInt(Preferences.astraGatewayTokenExpiresAt);
    if (token == null || token.isEmpty || expiresAt == null) return null;
    // 30s safety margin so a token doesn't expire mid-request.
    final stillValid = DateTime.now().isBefore(
        DateTime.fromMillisecondsSinceEpoch(expiresAt)
            .subtract(const Duration(seconds: 30)));
    return stillValid ? token : null;
  }

  Future<String> _exchangeFirebaseToken() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw AstraGatewayAuthException(
          'No Firebase session to exchange for an Astra session.');
    }
    final firebaseToken = await firebaseUser.getIdToken();
    if (firebaseToken == null) {
      throw AstraGatewayAuthException('Could not obtain a Firebase ID token.');
    }
    final response = await _bareDio.post(
      AstraGatewayApis.authSession,
      data: AstraSessionExchangeRequest(firebaseToken: firebaseToken).toJson(),
    );
    return _cacheAndReturn(
        AstraSessionExchangeResponse.fromJson(response.data));
  }

  Future<String> _refresh(String refreshToken) async {
    final response = await _bareDio.post(
      AstraGatewayApis.authRefresh,
      data: {'refresh_token': refreshToken},
    );
    return _cacheAndReturn(
        AstraSessionExchangeResponse.fromJson(response.data));
  }

  Future<String> _cacheAndReturn(AstraSessionExchangeResponse session) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: session.expiresIn))
        .millisecondsSinceEpoch;
    await SharedPreferenceHelper.setString(
        Preferences.astraGatewayAccessToken, session.accessToken);
    await SharedPreferenceHelper.setInt(
        Preferences.astraGatewayTokenExpiresAt, expiresAt);
    if (session.refreshToken != null) {
      await SharedPreferenceHelper.setString(
          Preferences.astraGatewayRefreshToken, session.refreshToken!);
    }
    // Prefer patient_id (the id the companion API's user_id param expects
    // for a patient) over the generic user_id/sub.
    final userId = session.user.patientId ?? session.user.userId;
    await SharedPreferenceHelper.setString(
        Preferences.astraGatewayUserId, userId);
    return session.accessToken;
  }

  String? get cachedUserId =>
      SharedPreferenceHelper.getString(Preferences.astraGatewayUserId);
}
