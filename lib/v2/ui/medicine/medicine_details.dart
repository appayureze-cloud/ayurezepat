import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/prefConstatnt.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_details_response.dart';
import 'package:doctro_patient/v2/ui/medicine/cart_controller.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart' show Html;
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitFadingCircle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'
    show ModalProgressHUD;
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/medicine/cart_list_response.dart';
import '../../../model/v2/medicine/medicine_home_response.dart'
    show PopularProducts;
import '../../utils/logger.dart';
import '../widgets/header.dart';

class MedicineDetailsScreen extends HookWidget {
  final PopularProducts product;

  MedicineDetailsScreen({required this.product, super.key});

  final CartController cartController = CartController();

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> _currentIndex = useState(0);
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<bool> expandDescription = useState(false);
    ValueNotifier<MedicineDetails?> details = useState(null);
    ValueNotifier<Variants?> selectedVariant = useState(null);
    ValueNotifier<String?> selectedOption1 = useState(null);
    ValueNotifier<String?> selectedOption2 = useState(null);
    ValueNotifier<String?> selectedOption3 = useState(null);
    ValueNotifier<List<CartItem>> items = useState([]);

    final CartItem? selectedCartItem = useMemoized(() {
      if (selectedVariant.value == null) return null;
      return items.value.firstWhereOrNull(
        (e) => e.variantId == selectedVariant.value?.id,
      );
    }, [items.value, selectedVariant.value]);

    Future<void> fetchCartItems() async {
      try {
        Preferences.onLoading(context);
        CartListResponse response =
            await RestClient(await RetroApi().dioData(context)).getCartItems();
        if (response.success == true && response.data != null) {
          items.value = response.data ?? [];
        }
        Preferences.hideDialog(context);
      } catch (error, stacktrace) {
        logger.e("Exception occur: $error stackTrace: $stacktrace");
        Preferences.hideDialog(context);
      }
    }

    void setVariantValue() {
      try {
        logger.i(''
            '\n1: ${selectedOption1.value}'
            '\n2: ${selectedOption2.value}'
            '\n3: ${selectedOption3.value}');
        switch (details.value!.options!.length) {
          case 1:
            if (selectedOption1.value != null) {
              selectedVariant.value =
                  (details.value!.variants ?? []).firstWhereOrNull(
                (e) => e.option1 == selectedOption1.value,
              );
            }
            break;
          case 2:
            if (selectedOption1.value != null &&
                selectedOption2.value != null) {
              selectedVariant.value =
                  (details.value!.variants ?? []).firstWhereOrNull(
                (e) =>
                    e.option1 == selectedOption1.value &&
                    e.option2 == selectedOption2.value,
              );
            }
            break;
          case 3:
            if (selectedOption1.value != null &&
                selectedOption2.value != null &&
                selectedOption3.value != null) {
              selectedVariant.value =
                  (details.value!.variants ?? []).firstWhereOrNull(
                (e) =>
                    e.option1 == selectedOption1.value &&
                    e.option2 == selectedOption2.value &&
                    e.option3 == selectedOption3.value,
              );
            }
            break;
        }
      } catch (e) {
        logger.e(e);
      }
    }

    Future<void> fetchMedicineDetails() async {
      loading.value = true;
      try {
        MedicineDetailsResponse response =
            await RestClient(await RetroApi().dioData(context))
                .getMedicineDetails(product.id!);
        if (response.success == true && response.data != null) {
          details.value = response.data;
          items.value = (response.data?.cartItems ?? []);

          if (details.value!.options != null &&
              details.value!.options!.isNotEmpty) {
            for (int i = 0;
                i < details.value!.options!.length;
                i++ /*MedicineOptions option in details.value!.options!*/) {
              if (details.value!.options![i].values != null &&
                  details.value!.options![i].values!.isNotEmpty) {
                switch (i) {
                  case 0:
                    selectedOption1.value =
                        details.value!.options![i].values![0];
                    break;
                  case 1:
                    selectedOption2.value =
                        details.value!.options![i].values![0];
                    break;
                  case 2:
                    selectedOption3.value =
                        details.value!.options![i].values![0];
                    break;
                }
              }
            }
          }
          setVariantValue();
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      fetchMedicineDetails();
    }, []);

    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: loading.value
            ? SizedBox.shrink()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header_v2(
                      title: 'Product Details',
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 2.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${details.value!.title}',
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if ((details.value!.images ?? []).isEmpty)
                            SizedBox(height: 2.h),
                          if ((details.value!.images ?? []).isNotEmpty)
                            CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                enlargeCenterPage: true,
                                height: 35.h,
                                autoPlay: true,
                                viewportFraction: 0.8,
                                onPageChanged: (index, _) {
                                  _currentIndex.value = index;
                                },
                              ),
                              items: (details.value!.images ?? []).map((i) {
                                return InwardImageContainer(
                                  imageUrl: i.src ?? '',
                                );
                              }).toList(),
                            )
                          else
                            Image.asset(
                              height: 20.h,
                              width: 90.w,
                              "assets/images/NoImage.png",
                              fit: BoxFit.fitHeight,
                            ),
                          if ((details.value!.images ?? []).isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (details.value!.images ?? [])
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return GestureDetector(
                                  onTap: () {
                                    _carouselController
                                        .animateToPage(entry.key);
                                  },
                                  child: Container(
                                    width: 2.w,
                                    height: 2.w,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 1.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentIndex.value == entry.key
                                          ? Palette.grey
                                          : Palette.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 1.h),
                          SizedBox(height: 0.5.h),
                          Column(
                            children: [
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                child: ConstrainedBox(
                                  constraints: expandDescription.value
                                      ? BoxConstraints()
                                      : BoxConstraints(maxHeight: 25.h),
                                  child: Html(
                                    data: '${details.value!.description}',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  expandDescription.value =
                                      !expandDescription.value;
                                },
                                child: Text(
                                  expandDescription.value
                                      ? 'Read Less'
                                      : 'Read More',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 14.sp,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Divider(),
                          SizedBox(height: 1.h),
                          Text(
                            'Product Variants',
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          if (details.value!.options!.length > 1)
                            for (int i = 0;
                                i < (details.value!.options ?? []).length;
                                i++)
                              Padding(
                                padding: EdgeInsets.only(bottom: 1.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.w,
                                      child: Text(
                                        '${(details.value!.options ?? [])[i].name}',
                                        style: TextStyle(
                                          color: Palette.primary,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    for (String value
                                        in (details.value!.options ?? [])[i]
                                                .values ??
                                            [])
                                      GestureDetector(
                                        onTap: () {
                                          if (i == 0) {
                                            selectedOption1.value = value;
                                          } else if (i == 1) {
                                            selectedOption2.value = value;
                                          } else if (i == 2) {
                                            selectedOption3.value = value;
                                          }

                                          setVariantValue();
                                        },
                                        child: SelectableWidget(
                                          title: value,
                                          isSelected: i == 0
                                              ? selectedOption1.value == value
                                              : i == 1
                                                  ? selectedOption2.value ==
                                                      value
                                                  : selectedOption3.value ==
                                                      value,
                                        ),
                                      ),
                                    SizedBox(width: 3.w),
                                  ],
                                ),
                              ),
                          if (details.value!.options!.length > 1)
                            SizedBox(height: 1.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedVariant.value != null &&
                                        (selectedVariant
                                                    .value!.compareAtPrice ??
                                                0) >
                                            0)
                                      Text(
                                        'MRP: ${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${selectedVariant.value!.compareAtPrice ?? 0}',
                                        style: TextStyle(
                                          color: Palette.grey,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    if (selectedVariant.value != null &&
                                        (selectedVariant
                                                    .value!.compareAtPrice ??
                                                0) >
                                            0)
                                      SizedBox(height: 0.2.h),
                                    if (selectedVariant.value != null)
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(
                                          text:
                                              '${SharedPreferenceHelper.getString(Preferences.currency_symbol)}',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.none,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${selectedVariant.value!.price}',
                                              style: TextStyle(
                                                fontSize: 19.sp,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' (-${(product.discountPercent ?? 0).toStringAsFixed(2)}%)',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Palette.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(width: 3.w),
                                Spacer(),
                                selectedCartItem?.id != null
                                    ? Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              bool result = await cartController
                                                  .updateCartDebounced(
                                                context: context,
                                                productId: details.value!.id!,
                                                variantId: selectedCartItem!
                                                    .variantId!,
                                                quantity: ((selectedCartItem
                                                                .quantity ??
                                                            0) >
                                                        0)
                                                    ? ((selectedCartItem
                                                                .quantity ??
                                                            0) +
                                                        1)
                                                    : 0,
                                                price: selectedCartItem.price!,
                                                isRemove: true,
                                              );
                                              if (result) fetchCartItems();
                                            },
                                            icon: Icon(Icons.remove),
                                          ),
                                          Text('${selectedCartItem!.quantity}'),
                                          IconButton(
                                            onPressed: () async {
                                              bool result = await cartController
                                                  .updateCartDebounced(
                                                context: context,
                                                productId: details.value!.id!,
                                                variantId:
                                                    selectedCartItem.variantId!,
                                                quantity: (selectedCartItem
                                                            .quantity ??
                                                        0) +
                                                    1,
                                                price: selectedCartItem.price!,
                                                isRemove: false,
                                              );
                                              if (result) fetchCartItems();
                                            },
                                            icon: Icon(Icons.add),
                                          ),
                                        ],
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          if (details.value!.cartStatus ==
                                                  true &&
                                              (items.value
                                                  .map((e) => e.variantId)
                                                  .contains(selectedVariant
                                                      .value?.id))) {
                                            Navigator.pushNamed(
                                                context, 'Cart');
                                            return;
                                          }
                                          if (selectedVariant.value != null) {
                                            bool result = await cartController
                                                .updateCartDebounced(
                                              context: context,
                                              productId: selectedVariant
                                                  .value!.productId!,
                                              variantId:
                                                  selectedVariant.value!.id!,
                                              quantity: 1,
                                              price:
                                                  selectedVariant.value!.price!,
                                              isRemove: false,
                                            );
                                            if (result) fetchMedicineDetails();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Please select any variant",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                            );
                                          }
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              details.value!.cartStatus ==
                                                          true &&
                                                      (items.value
                                                          .map((e) =>
                                                              e.variantId)
                                                          .contains(
                                                              selectedVariant
                                                                  .value?.id))
                                                  ? Icons.shopping_cart_outlined
                                                  : Icons
                                                      .add_circle_outline_outlined,
                                              color: Palette.primary,
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              details.value!.cartStatus ==
                                                          true &&
                                                      (items.value
                                                          .map((e) =>
                                                              e.variantId)
                                                          .contains(
                                                              selectedVariant
                                                                  .value?.id))
                                                  ? 'Go to cart'
                                                  : 'Add to cart',
                                              style: TextStyle(
                                                color: Palette.primary,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),

                          SizedBox(height: 2.h),
                          RatingsBreakdown(
                            ratingData: details.value!.reviews ?? [],
                            rating: details.value!.averageRating!,
                            count: details.value!.ratingsCount ?? 0,
                          ),
                          SizedBox(height: 2.h),
                          // if (details.value?.cartStatus != true &&
                          //     (items.value
                          //         .map((e) => e.variantId)
                          //         .contains(selectedVariant.value?.id)))
                          ButtonV2(
                            label: 'Go to Cart',
                            onPressed: () {
                              Navigator.pushNamed(context, 'Cart');
                            },
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class RatingsBreakdown extends StatelessWidget {
  final List<MedicineReview> ratingData;
  final double rating;
  final int count;

  const RatingsBreakdown(
      {required this.ratingData,
      required this.rating,
      required this.count,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left block (star icon and ratings summary)
        Column(
          children: [
            Icon(
              Icons.star,
              size: 5.h,
              color: Palette.rating,
            ),
            SizedBox(height: 1.h),
            Text(
              "$count Ratings\nand Reviews",
              style: TextStyle(
                color: Palette.grey,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(width: 3.w),
        // Right block (star breakdown)
        Expanded(
          child: Column(
            children: ratingData.map((data) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  children: [
                    // Star count and icon
                    Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 15.sp,
                      ),
                    ),
                    Icon(
                      Icons.star,
                      size: 16.sp,
                      color: Palette.rating,
                    ),
                    SizedBox(width: 2.w),
                    // Bar (manually controlled width based on percent)
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 0.75.h,
                            decoration: BoxDecoration(
                              color: Palette.lightGrey,
                              borderRadius: BorderRadius.circular(1.h),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: rating,
                            child: Container(
                              height: 0.75.h,
                              decoration: BoxDecoration(
                                color: Palette.primary,
                                borderRadius: BorderRadius.circular(1.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(width: 2.w),
                    // Percent text
                    // Text(
                    //   "${rating}%",
                    //   style: TextStyle(
                    //     fontSize: 15.sp,
                    //   ),
                    // ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SelectableWidget extends HookWidget {
  final bool isSelected;
  final String title;

  SelectableWidget({
    required this.isSelected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      // height: 11.h,
      padding: EdgeInsets.all(2.w),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(
                color: Palette.primary,
              )
            : null,
        borderRadius: BorderRadius.circular(1.w),
        color: isSelected ? Palette.primary_bg : Palette.lightGrey2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${title}'.toSentenceCase(),
            style: TextStyle(
              color: Palette.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class InwardImageContainer extends StatelessWidget {
  final String imageUrl;

  InwardImageContainer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.w),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: 100.w,
          height: 40.h,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Center(
            child: Image.asset(
              "assets/images/NoImage.png",
              width: 100.w,
              height: 20.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
