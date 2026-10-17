import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/doctor_info_card.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/helper.dart';
import '../../appointments/domain/entities/doctor_summary.dart';
import '../../appointments/presentation/appointment_service.dart';
import '../../cart/domain/entities/product.dart';
import '../../cart/presentation/cart_service.dart';
import '../../cart/presentation/shop_screen.dart';

/// Matches the Stitch "Global Search" screen
/// (ayureze_global_search/code.html): grouped results (Doctors,
/// Medicines) as the query comes in. The mock also groups by Documents
/// and Past conversations, which this app has no searchable index for
/// (documents aren't text-searchable, and there's no conversation
/// history - see the Companion Chat History skip note), so those groups
/// are left out rather than faked.
class GlobalSearchScreen extends HookWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final allDoctors = useState<List<DoctorSummary>>([]);
    final allProducts = useState<List<Product>>([]);
    final loading = useState(true);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 300));

    useEffect(() {
      Future(() async {
        try {
          allDoctors.value = await AppointmentService().listDoctors();
        } catch (_) {}
        try {
          allProducts.value = await CartService().listProducts();
        } catch (_) {}
        loading.value = false;
      });
      return null;
    }, const []);

    final q = query.value.trim().toLowerCase();
    final doctorResults = q.isEmpty
        ? const <DoctorSummary>[]
        : allDoctors.value
            .where((d) =>
                d.name.toLowerCase().contains(q) ||
                (d.specialization ?? '').toLowerCase().contains(q))
            .take(5)
            .toList();
    final productResults = q.isEmpty
        ? const <Product>[]
        : allProducts.value
            .where((p) => p.name.toLowerCase().contains(q))
            .take(5)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Search'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              autofocus: true,
              onChanged: (v) => debouncer.run(() => query.value = v),
              decoration: const InputDecoration(
                hintText: 'Search doctors, medicines...',
                prefixIcon: Icon(Icons.search, color: AppColors.slateTextMuted),
              ),
            ),
          ),
          Expanded(
            child: loading.value
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.sagePrimary),
                  )
                : q.isEmpty
                    ? const Center(
                        child: Text('Search for doctors or medicines',
                            style: TextStyle(color: AppColors.slateTextMuted)),
                      )
                    : doctorResults.isEmpty && productResults.isEmpty
                        ? const Center(
                            child: Text('No results found',
                                style:
                                    TextStyle(color: AppColors.slateTextMuted)),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (doctorResults.isNotEmpty) ...[
                                Text('Doctors',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                for (final d in doctorResults)
                                  DoctorInfoCard_v2(doctor: d),
                                const SizedBox(height: 16),
                              ],
                              if (productResults.isNotEmpty) ...[
                                Text('Medicines',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 8),
                                for (final p in productResults)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.creamSurfaceLowest,
                                      border: Border.all(
                                          color: AppColors.slateBorder),
                                      borderRadius: AppRadius.roundedLg,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(p.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall),
                                        ),
                                        Text(
                                            '₹${p.priceNumeric.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const ShopScreen()),
                                    ),
                                    child: const Text('See all in Shop'),
                                  ),
                                ),
                              ],
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
