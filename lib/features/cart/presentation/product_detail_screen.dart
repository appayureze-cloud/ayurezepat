import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/product.dart';
import 'cart_screen.dart';
import 'cart_service.dart';

/// Matches the Stitch "Product Detail" screen
/// (ayureze_product_detail/code.html), limited to what the real catalog
/// endpoint actually returns (name, price, availability, vendor - see
/// Product's doc comment). The mock's photo and description need data
/// this backend doesn't have, so a generic medicine icon stands in for
/// the photo and there's no fabricated description text.
class ProductDetailScreen extends HookWidget {
  final Product product;

  const ProductDetailScreen({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => CartService());
    final quantity = useState(1);
    final adding = useState(false);

    Future<void> addToCart() async {
      adding.value = true;
      try {
        await service.addItem(product.name, quantity: quantity.value);
        Fluttertoast.showToast(msg: 'Added ${product.name} to cart');
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        }
      } catch (e) {
        logger.e('Failed to add to cart: $e');
        Fluttertoast.showToast(msg: 'Could not add to cart');
      } finally {
        adding.value = false;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: Column(
        children: [
          Header_v2(title: product.name),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.sagePrimarySubtle,
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: const Center(
                    child: Icon(Icons.medication_outlined,
                        size: 72, color: AppColors.sagePrimary),
                  ),
                ),
                const SizedBox(height: 20),
                Text(product.name,
                    style: Theme.of(context).textTheme.displayMedium),
                if ((product.vendor ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(product.vendor!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                const SizedBox(height: 12),
                Text('₹${product.priceNumeric.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(color: AppColors.sagePrimary)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.available
                        ? AppColors.sagePrimarySubtle
                        : AppColors.clayAlertContainer,
                    borderRadius: AppRadius.roundedPill,
                  ),
                  child: Text(
                    product.available ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: product.available
                            ? AppColors.sagePrimary
                            : AppColors.clayAlert),
                  ),
                ),
                const SizedBox(height: 28),
                if (product.available) ...[
                  Text('Quantity',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap:
                            quantity.value > 1 ? () => quantity.value-- : null,
                      ),
                      SizedBox(
                        width: 48,
                        child: Text('${quantity.value}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: () => quantity.value++,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (product.available)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: adding.value ? null : addToCart,
                    child: Text(adding.value ? 'Adding...' : 'Add to cart'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedMd,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.creamSurfaceLowest,
          border: Border.all(color: AppColors.slateBorder),
          borderRadius: AppRadius.roundedMd,
        ),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? AppColors.slateTextMuted
                : AppColors.sagePrimary),
      ),
    );
  }
}
