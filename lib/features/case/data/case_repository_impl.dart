import 'package:dio/dio.dart';

import '../../../api/network_api.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../domain/case_repository.dart';
import '../domain/entities/case.dart';

class CaseException implements Exception {
  final String message;
  CaseException(this.message);

  @override
  String toString() => message;
}

class CaseRepositoryImpl implements CaseRepository {
  final Dio dio;

  CaseRepositoryImpl(this.dio);

  @override
  Future<Case> ensureActiveCase() async {
    final cachedId = SharedPreferenceHelper.getString(Preferences.activeCaseId);
    if (cachedId != null && cachedId.isNotEmpty) {
      try {
        final cached = await getCase(cachedId);
        if (cached.isActive) return cached;
      } catch (_) {
        // Cached case is gone or unreadable - fall through to creating a
        // new one rather than blocking the booking flow on it.
      }
    }
    return createCase();
  }

  @override
  Future<Case> getCase(String id) async {
    final response = await RestClient(dio).getCase(id);
    if (response.success != true || response.data == null) {
      throw CaseException(response.msg ?? 'Case not found');
    }
    return response.data!;
  }

  @override
  Future<Case> createCase() async {
    final response = await RestClient(dio).createCase();
    if (response.success != true || response.data == null) {
      throw CaseException(response.msg ?? 'Could not create case');
    }
    await SharedPreferenceHelper.setString(
        Preferences.activeCaseId, response.data!.id);
    return response.data!;
  }
}
