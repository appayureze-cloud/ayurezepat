import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../theme.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/product.dart';
import 'cart_screen.dart';
import 'cart_service.dart';

/// Matches the Stitch "Medicine Catalog" screen
/// (ayureze_medicine_catalog/code.html), adapted for what the real
/// Shopify catalog endpoint actually returns: no product photos,
/// categories, or descriptions (see Product's doc comment) - so this
/// stays a search-first list rather than a browsable photo grid, to
/// avoid inventing data the backend doesn't have.
class ShopScreen extends HookWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = useMemoized(() => CartService());
    final allProducts = useState<List<Product>>([]);
    final loading = useState(true);
    final error = useState<String?>(null);
    final query = useState('');
    final addingProductId = useState<String?>(null);

    Future<void> load() async {
      loading.value = true;
      error.value = null;
      try {
        allProducts.value = await service.listProducts();
      } catch (e) {
        logger.e('Failed to load products: $e');
        error.value = 'Could not load the medicine catalog';
        Fluttertoast.showToast(msg: 'Could not load the medicine catalog');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    final filtered = query.value.trim().isEmpty
        ? const <Product>[]
        : allProducts.value
            .where((p) =>
                p.name.toLowerCase().contains(query.value.trim().toLowerCase()))
            .take(50)
            .toList();

    Future<void> addToCart(Product product) async {
      addingProductId.value = product.productId;
      try {
        await service.addItem(product.name);
        Fluttertoast.showToast(msg: 'Added ${product.name} to cart');
      } catch (e) {
        logger.e('Failed to add to cart: $e');
        Fluttertoast.showToast(msg: 'Could not add to cart');
      } finally {
        addingProductId.value = null;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Cart'),
      ),
      body: Column(
        children: [
          const Header_v2(title: 'Shop Medicines'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => query.value = v,
              decoration: const InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: Icon(Icons.search, color: AppColors.slateTextMuted),
              ),
            ),
          ),
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
                    child: Text(error.value!,
                        style:
                            const TextStyle(color: AppColors.slateTextMuted))))
          else if (query.value.trim().isEmpty)
            const Expanded(
              child: Center(
                  child: Text('Search for a medicine to get started',
                      style: TextStyle(color: AppColors.slateTextMuted))),
            )
          else if (filtered.isEmpty)
            const Expanded(
                child: Center(
                    child: Text('No matching medicines',
                        style: TextStyle(color: AppColors.slateTextMuted))))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final isAdding = addingProductId.value == product.productId;
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
                              Text(product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              Text(
                                  '₹${product.priceNumeric.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              if (!product.available)
                                const Text('Out of stock',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.clayAlert)),
                            ],
                          ),
                        ),
                        if (product.available)
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.sagePrimarySubtle,
                            ),
                            onPressed:
                                isAdding ? null : () => addToCart(product),
                            icon: isAdding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.add_shopping_cart,
                                    color: AppColors.sagePrimary),
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
