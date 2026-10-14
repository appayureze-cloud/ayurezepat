import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/cart.dart';
import 'cart_service.dart';
import 'order_history_screen.dart';

/// Matches the Stitch "Cart" screen (ayureze_cart/code.html): line
/// items, an order-summary card, and a sticky bottom "Checkout" pill
/// button; a calm empty-cart state when there's nothing to check out.
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
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(
            title: 'Your Cart',
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: AppColors.sagePrimary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
              ),
            ],
          ),
          if (loading.value)
            const Expanded(
              child: Center(
                child:
                    SpinKitFadingCircle(color: AppColors.sagePrimary, size: 36),
              ),
            )
          else if (items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        size: 56, color: AppColors.slateTextMuted),
                    const SizedBox(height: 14),
                    const Text('Your cart is empty',
                        style: TextStyle(color: AppColors.slateTextMuted)),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Browse medicines'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isRemoving = removingProductId.value == item.productId;
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              Text(
                                  'Qty ${item.quantity} · ₹${item.price.toStringAsFixed(2)} each',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text('₹${item.lineTotal.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.sagePrimary)),
                        IconButton(
                          onPressed: isRemoving ? null : () => removeItem(item),
                          icon: isRemoving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.delete_outline,
                                  color: AppColors.clayAlert),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (items.isNotEmpty)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: AppColors.creamSurfaceLowest,
                  boxShadow: AppShadows.floatingNav,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('₹${cart.value?.totalAmount ?? 0}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: AppColors.sagePrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: checkingOut.value ? null : checkout,
                        child: Text(checkingOut.value
                            ? 'Processing...'
                            : 'Checkout & Pay'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
