import '../domain/document_repository.dart';
import '../domain/entities/remote_document.dart';

/// Stands in for the real documents API until Env.useMockDocuments is
/// flipped. See docs/backend/astra.md.
class MockDocumentRepository implements DocumentRepository {
  @override
  Future<List<RemoteDocument>> getPatientDocuments(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      RemoteDocument(
        id: 'mock_doc_1',
        title: 'Blood test report',
        docType: 'lab_report',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        downloadUrl: 'https://example.com/mock-report.pdf',
      ),
    ];
  }
}
