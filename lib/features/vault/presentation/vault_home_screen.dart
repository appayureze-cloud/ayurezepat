import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../astra/data/astra_gateway_auth.dart';
import '../../documents/domain/entities/remote_document.dart';
import '../../documents/presentation/document_service.dart';
import 'vault_category_screen.dart';

class VaultCategory {
  final String label;
  final IconData icon;
  final List<String> docTypes;

  const VaultCategory(
      {required this.label, required this.icon, required this.docTypes});
}

const vaultCategories = [
  VaultCategory(
      label: 'Lab Reports',
      icon: Icons.biotech_outlined,
      docTypes: ['lab_report', 'lab']),
  VaultCategory(
      label: 'Prescriptions',
      icon: Icons.receipt_long_outlined,
      docTypes: ['prescription']),
  VaultCategory(
      label: 'Imaging & Scans',
      icon: Icons.monitor_heart_outlined,
      docTypes: ['xray', 'imaging', 'scan']),
  VaultCategory(
      label: 'Vaccination Records',
      icon: Icons.vaccines_outlined,
      docTypes: ['vaccination']),
  VaultCategory(
      label: 'Insurance',
      icon: Icons.verified_user_outlined,
      docTypes: ['insurance']),
  VaultCategory(
      label: 'Discharge Summaries',
      icon: Icons.summarize_outlined,
      docTypes: ['discharge_summary', 'discharge']),
];

/// Matches the Stitch "Vault Home" screen (ayureze_vault_home/code.html):
/// a grid of category folders with real document counts, grouped from
/// the same already-wired documents list (GET
/// /api/v1/documents/patient/{patientId}) by `doc_type` - no categories
/// exist server-side, so this groups client-side instead of inventing a
/// taxonomy the backend doesn't have.
class VaultHomeScreen extends HookWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => DocumentService.create());
    final documents = useState<List<RemoteDocument>>([]);
    final loading = useState(true);

    useEffect(() {
      Future(() async {
        final patientId = AstraGatewayAuth().cachedUserId;
        if (patientId != null) {
          try {
            documents.value = await service.getPatientDocuments(patientId);
          } catch (_) {
            // Vault home degrades to empty folders rather than failing -
            // the patient can still retry from the category screen.
          }
        }
        loading.value = false;
      });
      return null;
    }, const []);

    List<RemoteDocument> docsFor(VaultCategory category) => documents.value
        .where((d) => category.docTypes.contains(d.docType))
        .toList();

    final categorized = documents.value
        .where(
            (d) => vaultCategories.any((c) => c.docTypes.contains(d.docType)))
        .toSet();
    final other =
        documents.value.where((d) => !categorized.contains(d)).toList();

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Health Vault'),
          if (loading.value)
            const Expanded(
              child: Center(
                child:
                    SpinKitFadingCircle(color: AppColors.sagePrimary, size: 36),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  for (final category in vaultCategories)
                    _FolderTile(
                      category: category,
                      count: docsFor(category).length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VaultCategoryScreen(
                            category: category,
                            documents: docsFor(category),
                          ),
                        ),
                      ),
                    ),
                  if (other.isNotEmpty)
                    _FolderTile(
                      category: const VaultCategory(
                          label: 'Other Documents',
                          icon: Icons.folder_outlined,
                          docTypes: []),
                      count: other.length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VaultCategoryScreen(
                            category: const VaultCategory(
                                label: 'Other Documents',
                                icon: Icons.folder_outlined,
                                docTypes: []),
                            documents: other,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final VaultCategory category;
  final int count;
  final VoidCallback onTap;

  const _FolderTile(
      {required this.category, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedLg,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.creamSurfaceLowest,
          border: Border.all(color: AppColors.slateBorder),
          borderRadius: AppRadius.roundedLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.sagePrimarySubtle,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(category.icon, size: 18, color: AppColors.sagePrimary),
            ),
            const Spacer(),
            Text(category.label,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text('$count document${count == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
