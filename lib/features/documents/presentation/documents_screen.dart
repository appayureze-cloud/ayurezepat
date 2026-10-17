import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../../astra/data/astra_gateway_auth.dart';
import '../domain/entities/remote_document.dart';
import 'document_service.dart';

/// Matches the Stitch "Documents" screen (ayureze_documents/code.html):
/// a list of the patient's stored documents (lab reports, prescriptions,
/// x-rays) with a file-type icon, title, upload date, and an
/// open/download action. There's no confirmed upload endpoint in the
/// Astra spec yet, so there's no upload button here - only the real,
/// already-wired read path (GET /api/v1/documents/patient/{patientId}).
class DocumentsScreen extends HookWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => DocumentService.create());
    final documents = useState<List<RemoteDocument>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        final patientId = AstraGatewayAuth().cachedUserId;
        if (patientId == null) {
          documents.value = [];
          return;
        }
        documents.value = await service.getPatientDocuments(patientId);
      } catch (e) {
        logger.e('Failed to load documents: $e');
        error.value = 'Could not load your documents';
        Fluttertoast.showToast(msg: 'Could not load your documents');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    IconData iconFor(String? docType) {
      switch (docType) {
        case 'lab_report':
          return Icons.biotech_outlined;
        case 'prescription':
          return Icons.receipt_long_outlined;
        case 'xray':
        case 'imaging':
          return Icons.monitor_heart_outlined;
        default:
          return Icons.description_outlined;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Documents'),
          if (loading.value)
            const Expanded(
              child: Center(
                child:
                    SpinKitFadingCircle(color: AppColors.sagePrimary, size: 36),
              ),
            )
          else if (error.value != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error.value!),
                    const SizedBox(height: 14),
                    ElevatedButton(onPressed: load, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else if (documents.value.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.folder_open_outlined,
                        size: 56, color: AppColors.slateTextMuted),
                    SizedBox(height: 14),
                    Text('No documents yet',
                        style: TextStyle(color: AppColors.slateTextMuted)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: documents.value.length,
                itemBuilder: (context, index) {
                  final doc = documents.value[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.sagePrimarySubtle,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconFor(doc.docType),
                              size: 18, color: AppColors.sagePrimary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              if (doc.createdAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    DateFormat('d MMM yyyy')
                                        .format(doc.createdAt!),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => launchUrl(Uri.parse(doc.downloadUrl),
                              mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.open_in_new,
                              color: AppColors.sagePrimary, size: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
