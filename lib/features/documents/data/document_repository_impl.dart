import '../../../v2/utils/logger.dart';
import '../../astra/data/astra_gateway_apis.dart';
import '../../astra/data/astra_gateway_client.dart';
import '../domain/document_repository.dart';
import '../domain/entities/remote_document.dart';

/// Talks to the real documents API on the Astra gateway. Like the
/// reminders API, `security: none` in the published spec, and its list
/// response has no fixed schema, so each entry is parsed defensively -
/// see docs/backend/astra.md.
class DocumentRepositoryImpl implements DocumentRepository {
  final AstraGatewayClient _gateway;

  DocumentRepositoryImpl([AstraGatewayClient? gateway])
      : _gateway = gateway ?? AstraGatewayClient();

  @override
  Future<List<RemoteDocument>> getPatientDocuments(String patientId) async {
    final dio = await _gateway.dio();
    final response =
        await dio.get(AstraGatewayApis.documentsForPatient(patientId));
    final data = response.data;
    final items = _extractList(data);
    final documents =
        items.map(_parseDocument).whereType<RemoteDocument>().toList();
    documents.sort((a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    return documents;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final candidate = data['documents'] ?? data['data'] ?? data['items'];
      if (candidate is List) return candidate;
    }
    logger.w('Unexpected patient documents response shape: $data');
    return const [];
  }

  RemoteDocument? _parseDocument(dynamic item) {
    if (item is! Map) return null;
    final id = (item['document_id'] ?? item['id'])?.toString();
    if (id == null) {
      logger.w('Document with no id in response, skipping: $item');
      return null;
    }
    final createdAtRaw =
        item['created_at'] ?? item['uploaded_at'] ?? item['at'];
    return RemoteDocument(
      id: id,
      title: (item['description'] ?? item['doc_type'] ?? 'Document').toString(),
      docType: item['doc_type']?.toString(),
      createdAt:
          createdAtRaw is String ? DateTime.tryParse(createdAtRaw) : null,
      downloadUrl:
          '${AstraGatewayApis.baseUrl}${AstraGatewayApis.documentDownload(id)}',
    );
  }
}
