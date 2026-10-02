import 'entities/remote_document.dart';

abstract class DocumentRepository {
  /// Newest first.
  Future<List<RemoteDocument>> getPatientDocuments(String patientId);
}
