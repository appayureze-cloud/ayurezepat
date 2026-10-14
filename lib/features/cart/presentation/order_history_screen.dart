import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/cart.dart';
import 'cart_service.dart';

/// Matches the Stitch "Order History & Tracking" screen
/// (ayureze_order_history_tracking/code.html): orders as cards with an
/// icon+label status chip (never color alone).
class OrderHistoryScreen extends HookWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => CartService());
    final orders = useState<List<CartOrder>>([]);
    final loading = useState(true);

    Future<void> load() async {
      loading.value = true;
      try {
        orders.value = await service.orderHistory();
      } catch (e) {
        logger.e('Failed to load order history: $e');
        Fluttertoast.showToast(msg: 'Could not load your orders');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    (Color, Color, IconData) statusStyle(String status) {
      switch (status) {
        case 'completed':
          return (
            AppColors.sagePrimaryContainer,
            AppColors.sagePrimary,
            Icons.check_circle_outline
          );
        case 'pending_payment':
          return (
            AppColors.amberWarningContainer,
            AppColors.amberWarning,
            Icons.schedule
          );
        default:
          return (
            AppColors.creamSurfaceLow,
            AppColors.slateTextMuted,
            Icons.local_shipping_outlined
          );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          const Header_v2(title: 'Order History'),
          if (loading.value)
            const Expanded(
              child: Center(
                child:
                    SpinKitFadingCircle(color: AppColors.sagePrimary, size: 36),
              ),
            )
          else if (orders.value.isEmpty)
            const Expanded(
                child: Center(
                    child: Text('No orders yet',
                        style: TextStyle(color: AppColors.slateTextMuted))))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.value.length,
                itemBuilder: (context, index) {
                  final order = orders.value[index];
                  final (bgColor, fgColor, icon) = statusStyle(order.status);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.creamSurfaceLowest,
                      border: Border.all(color: AppColors.slateBorder),
                      borderRadius: AppRadius.roundedLg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.items.map((i) => i.name).join(', '),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('₹${order.totalAmount}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.sagePrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                DateFormat('d MMM yyyy')
                                    .format(order.updatedAt),
                                style: Theme.of(context).textTheme.bodySmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: AppRadius.roundedPill,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 13, color: fgColor),
                                  const SizedBox(width: 4),
                                  Text(order.status,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: fgColor)),
                                ],
                              ),
                            ),
                          ],
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
