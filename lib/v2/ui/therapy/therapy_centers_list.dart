import 'package:doctro_patient/model/v2/centers_list_response.dart';
import 'package:doctro_patient/model/v2/services_list_response.dart';
import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_center_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/doctor_list_response.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../widgets/button_v2.dart';
import '../widgets/header.dart';
import '../widgets/no_data.dart';

class TherapyCentersList extends HookWidget {
  final int? serviceId;
  final String? search;
  const TherapyCentersList({this.serviceId, this.search, super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Centers>> centers = useState([]);
    final ValueNotifier<List<Services>> services = useState([]);
    final ValueNotifier<Meta?> meta = useState(null);
    final ValueNotifier<bool> loading = useState(false);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    final ValueNotifier<Map<String, dynamic>> filters = useState({
      'sortOrder': 'asc',
      'search': search ?? '',
      'service_ids': serviceId != null ? [serviceId] : [],
      'min_distance': 0,
      'min_rating': 0,
      'max_distance': null,
      'max_rating': null,
      'page': 1,
      'per_page': 10,
    });
    final scrollController = useScrollController();

    Future<void> getServices() async {
      try {
        ServicesListResponse response =
            await RestClient(await RetroApi().dioData(context)).servicesList({
          "sortOrder": "asc",
          "page": 1,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            services.value = response.data ?? [];
          }
        }
      } catch (e) {
        logger.e('Error while fetching doctors');
      }
    }

    Future<void> getCentersList() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var lat = prefs.getDouble('lat');
        var lng = prefs.getDouble('lang');
        CentersListResponse response =
            await RestClient(await RetroApi().dioData(context)).centersList({
          'lat': lat,
          'lang': lng,
          ...filters.value,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            logger.i(response.data?.isNotEmpty ?? false);
            centers.value = [...centers.value, ...(response.data ?? [])];
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
      await getCentersList();
      loading.value = false;
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([getServices(), getCentersList()]);
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
      logger.w(filters.value);
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
              title: 'Therapy Centers',
              actions: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FilterBottomSheet(
                        services: services.value,
                        filters: filters.value,
                        onApply: (filter) async {
                          // print(
                          //     "Selected Filters: ${filter.serviceIds}, sort: ${filter.sortOrder}");
                          // Call your API here with filters
                          filters.value = {
                            'sortOrder': filter.sortOrder,
                            'search': '',
                            'service_ids': filter.serviceIds,
                            'min_distance': filter.minDistance,
                            'min_rating': filter.minRating,
                            'max_distance': filter.maxDistance,
                            'max_rating': filter.maxRating,
                            'page': 1,
                            'per_page': 10,
                          };
                          loading.value = true;
                          centers.value = [];
                          await getCentersList();
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
                textCapitalization: TextCapitalization.words,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (text) {
                  debouncer.run(() async {
                    if (text.length > 2) {
                      filters.value['search'] = text;

                      filters.value['page'] = 1;
                      loading.value = true;
                      centers.value = [];
                      await getCentersList();
                      loading.value = false;
                    } else {
                      filters.value['search'] = '';

                      filters.value['page'] = 1;
                      loading.value = true;
                      centers.value = [];
                      await getCentersList();
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
                  hintText: "Search therapy centers",
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
            for (Centers center in centers.value)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: TherapyCenterCard(center: center),
              ),
            if (centers.value.isEmpty)
              NoDataWidget(
                onRetry: () {
                  centers.value = [];
                  getCentersList();
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class FilterModel {
  String sortOrder;
  List<int> serviceIds;
  double minDistance;
  double? maxDistance;
  double minRating;
  double? maxRating;

  FilterModel({
    this.sortOrder = 'asc',
    this.serviceIds = const [],
    this.minDistance = 0,
    this.maxDistance,
    this.minRating = 0,
    this.maxRating,
  });
}

class FilterBottomSheet extends HookWidget {
  final List<Services> services;
  final Map<String, dynamic> filters;

  final void Function(FilterModel) onApply;

  FilterBottomSheet({
    required this.services,
    required this.onApply,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final sortOrder = useState(filters['sortOrder']);
    final selectedServices =
        useState<List<int>>(List<int>.from(filters['service_ids']));
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

            // Multi-Select Services
            InputDecorator(
              decoration: InputDecoration(
                labelText: "Therapies",
                labelStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Palette.grey,
                ),
              ),
              child: Wrap(
                spacing: 8,
                children: services.map((service) {
                  return FilterChip(
                    label: Text(
                      '${service.name}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Palette.black,
                      ),
                    ),
                    selected: selectedServices.value.contains(service.id),
                    onSelected: (val) {
                      if (val) {
                        selectedServices.value = [
                          ...selectedServices.value,
                          service.id!
                        ];
                      } else {
                        selectedServices.value = selectedServices.value
                            .where((id) => id != service.id)
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
                  serviceIds: selectedServices.value,
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
                  serviceIds: [],
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
