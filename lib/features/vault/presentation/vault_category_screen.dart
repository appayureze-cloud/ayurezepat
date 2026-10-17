import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../documents/domain/entities/remote_document.dart';
import 'document_viewer_screen.dart';
import 'vault_home_screen.dart';

/// Matches the Stitch "Vault Category List" screen
/// (ayureze_vault_category_list/code.html): the documents inside one
/// folder, opening into the Document Viewer.
class VaultCategoryScreen extends StatelessWidget {
  final VaultCategory category;
  final List<RemoteDocument> documents;

  const VaultCategoryScreen(
      {required this.category, required this.documents, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(title: category.label),
          if (documents.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No documents in this folder yet',
                    style: TextStyle(color: AppColors.slateTextMuted)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentViewerScreen(document: doc),
                        ),
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
                            child: Icon(category.icon,
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
                                  Text(
                                    DateFormat('d MMM yyyy')
                                        .format(doc.createdAt!),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.slateTextMuted),
                        ],
                      ),
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
