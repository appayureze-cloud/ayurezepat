/// One document stored on the Astra gateway's documents API
/// (`/api/v1/documents/*`, astra.ayureze.in) - lab reports, x-rays,
/// prescriptions uploaded by a doctor/admin. See docs/backend/astra.md.
class RemoteDocument {
  final String id;
  final String title;
  final String? docType;
  final DateTime? createdAt;
  final String downloadUrl;

  const RemoteDocument({
    required this.id,
    required this.title,
    this.docType,
    this.createdAt,
    required this.downloadUrl,
  });
}
