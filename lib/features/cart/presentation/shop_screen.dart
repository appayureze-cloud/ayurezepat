import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../domain/entities/product.dart';
import 'cart_screen.dart';
import 'cart_service.dart';

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text('Cart'),
        backgroundColor: Palette.primary,
      ),
      body: Column(
        children: [
          Header_v2(title: 'Shop Medicines'),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              onChanged: (v) => query.value = v,
              decoration: InputDecoration(
                hintText: 'Search medicines…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w)),
              ),
            ),
          ),
          if (loading.value)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(color: Palette.primary, size: 6.h),
              ),
            )
          else if (error.value != null)
            Expanded(child: Center(child: Text(error.value!)))
          else if (query.value.trim().isEmpty)
            const Expanded(
              child:
                  Center(child: Text('Search for a medicine to get started')),
            )
          else if (filtered.isEmpty)
            const Expanded(child: Center(child: Text('No matching medicines')))
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final isAdding = addingProductId.value == product.productId;
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
                              Text(product.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp)),
                              Text(
                                  '₹${product.priceNumeric.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Palette.dark_grey)),
                              if (!product.available)
                                Text('Out of stock',
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.red)),
                            ],
                          ),
                        ),
                        if (product.available)
                          IconButton(
                            onPressed:
                                isAdding ? null : () => addToCart(product),
                            icon: isAdding
                                ? SizedBox(
                                    width: 4.w,
                                    height: 4.w,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Icon(Icons.add_shopping_cart,
                                    color: Palette.primary),
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
