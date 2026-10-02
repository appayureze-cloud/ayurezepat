import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_category_list_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_home_response.dart';
import 'package:doctro_patient/model/v2/medicine/medicine_list_response.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart' show ButtonV2;
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'
    show ModalProgressHUD;
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/doctor_list_response.dart' show Meta;
import '../widgets/header.dart';
import '../widgets/medicine_list_card.dart';

class MedicineList_v2 extends HookWidget {
  final int? category;
  const MedicineList_v2({this.category, super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<PopularProducts>> products = useState([]);
    final ValueNotifier<List<PopularCategories>> categories = useState([]);
    final ValueNotifier<Meta?> meta = useState(null);
    final ValueNotifier<bool> loading = useState(false);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));
    final TextEditingController _searchController = useTextEditingController();

    final ValueNotifier<Map<String, dynamic>> filters = useState({
      'sortOrder': 'asc',
      'search': '',
      'category_ids': category != null ? [category] : [],
      'min_rating': 0,
      'max_rating': null,
      'page': 1,
      'per_page': 10,
    });

    final scrollController = useScrollController();

    Future<void> getCategories() async {
      try {
        MedicineCategoryListResponse response =
            await RestClient(await RetroApi().dioData(context))
                .medicineCategoryList({
          "sortOrder": "asc",
          "page": 1,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            categories.value = response.data ?? [];
          }
        }
      } catch (e) {
        logger.e('Error while fetching categories $e');
      }
    }

    Future<void> getProducts() async {
      try {
        MedicinesListResponse response =
            await RestClient(await RetroApi().dioData(context)).productsList({
          ...filters.value,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            products.value = [...products.value, ...(response.data ?? [])];
          }
          meta.value = response.meta;
        }
      } catch (e) {
        logger.e('Error while fetching medicines $e');
      }
    }

    Future<void> loadMore() async {
      try {
        if ((meta.value?.totalPages ?? 0) <= filters.value['page']) return;
        loading.value = true;
        filters.value['page'] = filters.value['page'] + 1;
        await getProducts();
        loading.value = false;
      } catch (e) {
        logger.e('Error in medicine list load more $e');
      }
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([getProducts(), getCategories()]);
        loading.value = false;
      }();
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100) {
          debouncer.run(() {
            loadMore();
          });
        }
      });

      return () {
        scrollController.dispose();
      };
    }, []);

    return ModalProgressHUD(
      inAsyncCall: loading.value,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header_v2(
              title: 'Products',
              actions: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FilterBottomSheet(
                        categories: categories.value,
                        filters: filters.value,
                        onApply: (filter) async {
                          // print(
                          //     "Selected Filters: ${filter.categoryIds}, sort: ${filter.sortOrder}");
                          // Call your API here with filters
                          filters.value = {
                            'sortOrder': filter.sortOrder,
                            'search': _searchController.text,
                            'category_ids': filter.categoryIds,
                            'min_rating': filter.minRating,
                            'max_rating': filter.maxRating,
                            'page': 1,
                            'per_page': 10,
                          };

                          loading.value = true;
                          products.value = [];
                          await getProducts();
                          loading.value = false;
                        },
                      ),
                    );
                  },
                  child: Icon(
                    Icons.filter_alt_outlined,
                    size: 21.sp,
                    color: Palette.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
              child: TextField(
                controller: _searchController,
                textCapitalization: TextCapitalization.words,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (text) {
                  debouncer.run(() async {
                    if (text.length > 2) {
                      filters.value['search'] = text;
                      filters.value['page'] = 1;
                      products.value = [];
                      loading.value = true;
                      await getProducts();
                      loading.value = false;
                    } else if (filters.value['search'].length > 2) {
                      filters.value['search'] = '';
                      filters.value['page'] = 1;
                      products.value = [];
                      loading.value = true;
                      await getProducts();
                      loading.value = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Palette.white,
                  constraints: BoxConstraints(
                    maxHeight: 5.5.h,
                    maxWidth: 95.w,
                  ),
                  hintText: "Search Products",
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Palette.grey,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_outlined,
                      size: 17.sp,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            if (products.value.isEmpty)
              NoDataWidget(
                onRetry: getProducts,
              ),
            GridView.builder(
              padding: EdgeInsets.all(8),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.value.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: 0.70, // Adjust based on desired card shape
              ),
              itemBuilder: (context, index) {
                return MedicineListCard(product: products.value[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModel {
  String sortOrder;
  List<int> categoryIds;
  double minRating;
  double? maxRating;

  FilterModel({
    this.sortOrder = 'asc',
    this.categoryIds = const [],
    this.minRating = 0,
    this.maxRating,
  });
}

class FilterBottomSheet extends HookWidget {
  final List<PopularCategories> categories;
  final Map<String, dynamic> filters;

  final void Function(FilterModel) onApply;

  FilterBottomSheet({
    required this.categories,
    required this.onApply,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final sortOrder = useState(filters['sortOrder']);
    final selectedCategories =
        useState<List<int>>(List<int>.from(filters['category_ids']));
    final minRating =
        useState<double>(double.parse('${filters['min_rating']}'));
    final maxRating =
        useState<double?>(double.tryParse('${filters['max_rating']}'));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Sort Order Dropdown
            DropdownButtonFormField<String>(
              value: sortOrder.value,
              decoration: InputDecoration(
                labelText: 'Sort Order',
                labelStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Palette.grey,
                ),
              ),
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette.black,
              ),
              items: ['asc', 'desc']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                  .toList(),
              onChanged: (val) => sortOrder.value = val!,
            ),

            SizedBox(height: 1.h),

            // Multi-Select Categories
            InputDecorator(
              decoration: InputDecoration(
                labelText: "Categories",
                labelStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Palette.grey,
                ),
              ),
              child: Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  return FilterChip(
                    label: Text(
                      '${cat.name}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Palette.black,
                      ),
                    ),
                    selected: selectedCategories.value.contains(cat.id),
                    onSelected: (val) {
                      if (val) {
                        selectedCategories.value = [
                          ...selectedCategories.value,
                          cat.id!
                        ];
                      } else {
                        selectedCategories.value = selectedCategories.value
                            .where((id) => id != cat.id)
                            .toList();
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 1.h),

            // Rating Range
            Text(
              "Rating (Min - Max): ${minRating.value} - ${maxRating.value ?? '∞'}",
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette.grey,
              ),
            ),
            RangeSlider(
              values: RangeValues(minRating.value, maxRating.value ?? 5),
              min: 0,
              max: 5,
              divisions: 10,
              activeColor: Palette.primary,
              labels:
                  RangeLabels('${minRating.value}', '${maxRating.value ?? 5}'),
              onChanged: (RangeValues values) {
                minRating.value = values.start;
                maxRating.value = values.end == 5 ? null : values.end;
              },
            ),

            SizedBox(height: 1.h),

            ButtonV2(
              onPressed: () {
                final filter = FilterModel(
                  sortOrder: sortOrder.value,
                  categoryIds: selectedCategories.value,
                  minRating: minRating.value,
                  maxRating: maxRating.value,
                );
                onApply(filter);
                Navigator.pop(context);
              },
              label: "Apply Filters",
            ),
            ButtonV2(
              buttonColor: Palette.grey,
              onPressed: () {
                final filter = FilterModel(
                  sortOrder: 'asc',
                  categoryIds: [],
                  minRating: 0,
                  maxRating: null,
                );
                onApply(filter);
                Navigator.pop(context);
              },
              label: "Clear Filters",
            ),
          ],
        ),
      ),
    );
  }
}
