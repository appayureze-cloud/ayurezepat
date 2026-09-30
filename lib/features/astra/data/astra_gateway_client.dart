import 'package:dio/dio.dart';

import '../../../v2/utils/logger.dart';
import 'astra_gateway_apis.dart';
import 'astra_gateway_auth.dart';

/// Builds the Dio client for authenticated calls to the real Astra gateway
/// (astra.ayureze.in) - separate from the main app's `RetroApi.dioData`,
/// since this is a different host and a different bearer token (an Astra
/// JWT exchanged from a Firebase ID token, not the Firebase token itself).
class AstraGatewayClient {
  final AstraGatewayAuth _auth;

  AstraGatewayClient([AstraGatewayAuth? auth])
      : _auth = auth ?? AstraGatewayAuth();

  Future<Dio> dio() async {
    final dio = Dio(BaseOptions(
      baseUrl: AstraGatewayApis.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    final token = await _auth.getAccessToken();
    dio.options.headers['Authorization'] = 'Bearer $token';

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final requestOptions = e.requestOptions;
          final alreadyRetried = requestOptions.extra['astraRetried'] == true;
          if (e.response?.statusCode == 401 &&
              !alreadyRetried &&
              !requestOptions.path.contains('auth/refresh') &&
              !requestOptions.path.contains('auth/session')) {
            try {
              final refreshed = await _auth.getAccessToken(forceRefresh: true);
              final cloned = await dio.request(
                requestOptions.path,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                options: Options(
                  method: requestOptions.method,
                  headers: {
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $refreshed',
                  },
                  extra: {...requestOptions.extra, 'astraRetried': true},
                ),
              );
              return handler.resolve(cloned);
            } catch (err) {
              logger.e('Astra gateway token refresh failed: $err');
              return handler.reject(e);
            }
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  String? get cachedUserId => _auth.cachedUserId;
}
