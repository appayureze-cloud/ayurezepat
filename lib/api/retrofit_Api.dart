import 'package:dio/dio.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../v2/utils/logger.dart';

/// Builds the Dio client used for authenticated API calls.
///
/// Auth tokens are never refreshed by the app talking to Google directly.
/// When the user has a live FirebaseAuth session (Google sign-in today;
/// phone/email sign-in once the backend issues a Firebase custom token -
/// see docs/backend/auth.md) we always pull a fresh ID token from the SDK,
/// which handles refreshing internally. If there is no FirebaseAuth session
/// (legacy phone/email login), we fall back to the token the backend handed
/// us at login time and rely on the 401 handler to force a re-login instead
/// of trying to refresh it ourselves.
class RetroApi {
  Future<Dio> dioData(BuildContext context) async {
    final dio = Dio();

    dio.options.headers["Accept"] = "application/json";
    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);

    final token = await _currentIdToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final requestOptions = e.requestOptions;

          if (e.response?.statusCode == 401 &&
              !requestOptions.path.contains('refresh')) {
            try {
              final refreshedToken = await _currentIdToken(forceRefresh: true);

              if (refreshedToken != null && refreshedToken.isNotEmpty) {
                final clonedRequest = await dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: Options(
                    method: requestOptions.method,
                    headers: {
                      ...requestOptions.headers,
                      'Authorization': 'Bearer $refreshedToken',
                    },
                  ),
                );
                return handler.resolve(clonedRequest);
              }

              await _forceLogout(context);
              return handler.reject(e);
            } catch (err) {
              logger.e('Token refresh error: $err');
              await _forceLogout(context);
              return handler.reject(e);
            }
          }

          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  /// Returns a fresh Firebase ID token when a FirebaseAuth session exists
  /// (the SDK caches and refreshes it internally), otherwise falls back to
  /// whatever token the backend issued at login for legacy sign-in paths
  /// that don't yet have a FirebaseAuth session.
  Future<String?> _currentIdToken({bool forceRefresh = false}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.getIdToken(forceRefresh);
    }
    if (forceRefresh) {
      // No FirebaseAuth session to refresh against - the legacy token
      // cannot be renewed client-side. Caller will force a re-login.
      return null;
    }
    return SharedPreferenceHelper.getString(Preferences.auth_token);
  }

  Future<void> _forceLogout(BuildContext context) async {
    SharedPreferenceHelper.clearPref();
    Navigator.of(context).pushNamedAndRemoveUntil(
      'SignIn',
      (route) => false,
    );
  }
}

class RetroApi2 {
  Dio dioData2() {
    final dio = Dio();
    dio.options.headers["Accept"] = "application/json";
    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    return dio;
  }
}
