import 'package:doctro_patient/model/v2/category_list_response.dart';
import 'package:doctro_patient/model/v2/doctor_list_response.dart';
import 'package:doctro_patient/model/v2/home_response.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/doctor_info_card.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';

class DoctorsList extends HookWidget {
  final int? category;
  final String? search;
  const DoctorsList({this.category, this.search, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController =
        useTextEditingController(text: search);
    final ValueNotifier<List<Doctor>> doctors = useState([]);
    final ValueNotifier<List<DoctorCategory>> categories = useState([]);
    final ValueNotifier<Meta?> meta = useState(null);
    final ValueNotifier<bool> loading = useState(false);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    final ValueNotifier<Map<String, dynamic>> filters = useState({
      'sortOrder': 'asc',
      'search': search ?? '',
      'category_ids': category != null ? [category] : [],
      'min_distance': 0,
      'min_rating': 0,
      'max_distance': null,
      'max_rating': null,
      'page': 1,
      'per_page': 10,
    });
    final scrollController = useScrollController();

    Future<void> getCategories() async {
      try {
        CategoryListResponse response =
            await RestClient(await RetroApi().dioData(context)).categoriesList({
          "sortOrder": "asc",
          "page": 1,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            categories.value = response.data ?? [];
          }
        }
      } catch (e) {
        logger.e('Error while fetching doctors');
      }
    }

    Future<void> getDoctorsList() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var lat = prefs.getDouble('lat');
        var lng = prefs.getDouble('lang');
        DoctorListResponse response =
            await RestClient(await RetroApi().dioData(context)).doctorList({
          'lat': lat,
          'lang': lng,
          ...filters.value,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            doctors.value = [...doctors.value, ...(response.data ?? [])];
          }
          meta.value = response.meta;
        }
      } catch (e) {
        logger.e('Error while fetching doctors $e');
      }
    }

    Future<void> loadMore() async {
      if ((meta.value?.totalPages ?? 0) <= filters.value['page']) return;
      loading.value = true;
      filters.value['page'] = filters.value['page'] + 1;
      await getDoctorsList();
      loading.value = false;
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([getDoctorsList(), getCategories()]);
        loading.value = false;
      }();
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100) {
          debouncer.run(() {
            loadMore();
          }); // Load more when near bottom
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
              title: 'Top Doctors',
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
                            'search': '',
                            'category_ids': filter.categoryIds,
                            'min_distance': filter.minDistance,
                            'min_rating': filter.minRating,
                            'max_distance': filter.maxDistance,
                            'max_rating': filter.maxRating,
                            'page': 1,
                            'per_page': 10,
                          };
                          loading.value = true;
                          doctors.value = [];
                          await getDoctorsList();
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
                controller: searchController,
                textCapitalization: TextCapitalization.words,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (text) {
                  debouncer.run(() async {
                    if (text.length > 2) {
                      filters.value['search'] = text;
                      filters.value['page'] = 1;
                      doctors.value = [];
                      loading.value = true;
                      await getDoctorsList();
                      loading.value = false;
                    } else {
                      filters.value['search'] = '';
                      filters.value['page'] = 1;
                      doctors.value = [];
                      loading.value = true;
                      await getDoctorsList();
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
                  hintText: "Search Doctor",
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
            if (doctors.value.isEmpty)
              NoDataWidget(
                onRetry: getDoctorsList,
              ),
            for (Doctor doctor in doctors.value)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: DoctorInfoCard_v2(doctor: doctor),
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
  double minDistance;
  double? maxDistance;
  double minRating;
  double? maxRating;

  FilterModel({
    this.sortOrder = 'asc',
    this.categoryIds = const [],
    this.minDistance = 0,
    this.maxDistance,
    this.minRating = 0,
    this.maxRating,
  });
}

class FilterBottomSheet extends HookWidget {
  final List<DoctorCategory> categories;
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
    final minDistance =
        useState<double>(double.parse('${filters['min_distance']}'));
    final maxDistance =
        useState<double?>(double.tryParse('${filters['max_distance']}'));
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

            // Distance Range
            Text(
              "Distance (Min - Max): ${minDistance.value} - ${maxDistance.value ?? '∞'} km",
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette.grey,
              ),
            ),
            RangeSlider(
              values: RangeValues(minDistance.value, maxDistance.value ?? 100),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: Palette.primary,
              labels: RangeLabels(
                  '${minDistance.value}', '${maxDistance.value ?? 100}'),
              onChanged: (RangeValues values) {
                minDistance.value = values.start;
                maxDistance.value = values.end == 100 ? null : values.end;
              },
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
                  minDistance: minDistance.value,
                  maxDistance: maxDistance.value,
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
                  minDistance: 0,
                  maxDistance: null,
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
