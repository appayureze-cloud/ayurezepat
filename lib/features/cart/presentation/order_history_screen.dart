import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/cart.dart';
import 'cart_service.dart';

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

    Color statusColor(String status) {
      switch (status) {
        case 'completed':
          return Colors.green;
        case 'pending_payment':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Header_v2(title: 'Order History'),
          if (loading.value)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(color: Palette.primary, size: 6.h),
              ),
            )
          else if (orders.value.isEmpty)
            const Expanded(child: Center(child: Text('No orders yet')))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: orders.value.length,
                itemBuilder: (context, index) {
                  final order = orders.value[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 0.75.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Palette.lightGrey),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.items.map((i) => i.name).join(', '),
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('₹${order.totalAmount}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('d MMM yyyy').format(order.updatedAt),
                                style: TextStyle(fontSize: 10.sp, color: Palette.dark_grey)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                              decoration: BoxDecoration(
                                color: statusColor(order.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4.w),
                              ),
                              child: Text(order.status,
                                  style: TextStyle(fontSize: 9.sp, color: statusColor(order.status))),
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
