import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/cart.dart';
import 'cart_service.dart';
import 'order_history_screen.dart';

class CartScreen extends HookWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => CartService());
    final cart = useState<Cart?>(null);
    final loading = useState(true);
    final checkingOut = useState(false);
    final removingProductId = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      try {
        cart.value = await service.getCart();
      } catch (e) {
        logger.e('Failed to load cart: $e');
        Fluttertoast.showToast(msg: 'Could not load your cart');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> removeItem(CartItem item) async {
      removingProductId.value = item.productId;
      try {
        cart.value = await service.removeItem(item.productId);
      } catch (e) {
        logger.e('Failed to remove item: $e');
        Fluttertoast.showToast(msg: 'Could not remove item');
      } finally {
        removingProductId.value = null;
      }
    }

    Future<void> checkout() async {
      checkingOut.value = true;
      try {
        await service.checkoutAndPay();
        Fluttertoast.showToast(msg: 'Order placed successfully');
        if (context.mounted) Navigator.pop(context);
      } on CartPaymentCancelledException {
        Fluttertoast.showToast(msg: 'Payment cancelled');
      } catch (e) {
        logger.e('Checkout failed: $e');
        Fluttertoast.showToast(msg: 'Checkout failed: $e');
      } finally {
        checkingOut.value = false;
      }
    }

    final items = cart.value?.items ?? const <CartItem>[];

    return Scaffold(
      body: Column(
        children: [
          Header_v2(
            title: 'Your Cart',
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
              ),
            ],
          ),
          if (loading.value)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(color: Palette.primary, size: 6.h),
              ),
            )
          else if (items.isEmpty)
            const Expanded(child: Center(child: Text('Your cart is empty')))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isRemoving = removingProductId.value == item.productId;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 0.75.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Palette.lightGrey),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              Text('Qty ${item.quantity} · ₹${item.price.toStringAsFixed(2)} each',
                                  style: TextStyle(fontSize: 11.sp, color: Palette.dark_grey)),
                            ],
                          ),
                        ),
                        Text('₹${item.lineTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                        IconButton(
                          onPressed: isRemoving ? null : () => removeItem(item),
                          icon: isRemoving
                              ? SizedBox(
                                  width: 4.w,
                                  height: 4.w,
                                  child: const CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (items.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Text('₹${cart.value?.totalAmount ?? 0}',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  ButtonV2(
                    label: checkingOut.value ? 'Processing…' : 'Checkout & Pay',
                    width: 100.w,
                    onPressed: checkingOut.value ? null : checkout,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
