import '../../../const/env.dart';
import '../data/document_repository_impl.dart';
import '../data/mock_document_repository.dart';
import '../domain/document_repository.dart';
import '../domain/entities/remote_document.dart';

/// Resolves the real vs mock DocumentRepository, the same pattern as
/// MedicineReminderService.
class DocumentService {
  final DocumentRepository _repository;

  DocumentService(this._repository);

  factory DocumentService.create() => DocumentService(
        Env.useMockDocuments
            ? MockDocumentRepository()
            : DocumentRepositoryImpl(),
      );

  Future<List<RemoteDocument>> getPatientDocuments(String patientId) =>
      _repository.getPatientDocuments(patientId);
}
