import 'package:dio/dio.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:flutter/material.dart';

import '../v2/utils/logger.dart';

class RetroApi {
  Future<Dio> dioData(BuildContext context) async {
    final dio = Dio();
    final token = SharedPreferenceHelper.getString(Preferences.auth_token);
    final refreshToken =
        SharedPreferenceHelper.getString(Preferences.refresh_token);
    final expiresIn = SharedPreferenceHelper.getInt(Preferences.expiresIn);
    final savedAt = SharedPreferenceHelper.getInt('token_saved_at');
    logger.w(
        'token: $token, refreshToken: $refreshToken, expiresIn: $expiresIn, savedAt: $savedAt');

    dio.options.headers["Accept"] = "application/json";
    dio.options.followRedirects = false;
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);

    if (token != null &&
        token != "N_A" &&
        token != "" &&
        refreshToken != null &&
        expiresIn != null &&
        savedAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiresAt = savedAt + (expiresIn * 1000);

      if (now >= expiresAt - 30000) {
        final newToken = await refreshFirebaseToken(refreshToken);
        if (newToken != null) {
          dio.options.headers["Authorization"] = "Bearer $newToken";
          await SharedPreferenceHelper.setInt(
              'token_saved_at', DateTime.now().millisecondsSinceEpoch);
        }
      } else {
        dio.options.headers["Authorization"] = "Bearer $token";
      }
    }

    // Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final requestOptions = e.requestOptions;

          if (e.response?.statusCode == 401 &&
              !requestOptions.path.contains('refresh')) {
            try {
              final refreshToken =
                  SharedPreferenceHelper.getString(Preferences.refresh_token);

              final newToken = await refreshFirebaseToken(refreshToken!);

              if (newToken != null) {
                // Retry request with new token
                final clonedRequest = await dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: Options(
                    method: requestOptions.method,
                    headers: {
                      ...requestOptions.headers,
                      'Authorization': 'Bearer $newToken',
                    },
                  ),
                );
                return handler.resolve(clonedRequest);
              } else {
                // Refresh failed, force logout
                SharedPreferenceHelper.clearPref();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  'SignIn',
                  (route) => false,
                );
                return handler.reject(e);
              }
            } catch (err) {
              logger.w('Token refresh error: $err');
              SharedPreferenceHelper.clearPref();
              Navigator.of(context).pushNamedAndRemoveUntil(
                'SignIn',
                (route) => false,
              );
              return handler.reject(err as DioException);
            }
          }

          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  Future<String?> refreshFirebaseToken(String refreshToken) async {
    try {
      final response = await Dio().post(
        'https://securetoken.googleapis.com/v1/token?key=AIzaSyDlpw8laR5rfPfx3oQeTrIENXBfXV7CZyo',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newIdToken = data['id_token'];
        final newRefreshToken = data['refresh_token'];
        final newExpiresIn = int.parse(data['expires_in']);

        // Save updated tokens
        await SharedPreferenceHelper.setString(
            Preferences.auth_token, newIdToken);
        await SharedPreferenceHelper.setString(
            Preferences.refresh_token, newRefreshToken);
        await SharedPreferenceHelper.setInt(
            Preferences.expiresIn, newExpiresIn);
        await SharedPreferenceHelper.setInt(
            'token_saved_at', DateTime.now().millisecondsSinceEpoch);

        return newIdToken;
      } else {
        return null;
      }
    } catch (e) {
      logger.e('Firebase token refresh failed: $e');
      return null;
    }
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
