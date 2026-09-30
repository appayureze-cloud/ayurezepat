import 'package:doctro_patient/features/documents/data/mock_document_repository.dart';
import 'package:doctro_patient/features/documents/domain/document_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockDocumentRepository', () {
    late DocumentRepository repository;

    setUp(() {
      repository = MockDocumentRepository();
    });

    test('getPatientDocuments returns at least one document', () async {
      final documents = await repository.getPatientDocuments('patient-1');

      expect(documents, isNotEmpty);
      expect(documents.first.downloadUrl, isNotEmpty);
    });
  });
}
