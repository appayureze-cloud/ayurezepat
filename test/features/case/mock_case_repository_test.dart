import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/features/case/data/mock_case_repository.dart';
import 'package:doctro_patient/features/case/domain/case_repository.dart';
import 'package:doctro_patient/features/case/domain/entities/case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockCaseRepository', () {
    late CaseRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferenceHelper.init();
      repository = MockCaseRepository();
    });

    test('createCase returns an open case', () async {
      final created = await repository.createCase();

      expect(created.id, isNotEmpty);
      expect(created.status, CaseStatus.open);
      expect(created.isActive, isTrue);
    });

    test('ensureActiveCase reuses the previously created case id', () async {
      final created = await repository.createCase();
      final reused = await repository.ensureActiveCase();

      expect(reused.id, created.id);
    });
  });
}
