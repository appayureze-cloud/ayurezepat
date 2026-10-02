import 'package:doctro_patient/model/v2/services_list_response.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/ui/widgets/therapy_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/therapy_home_response.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';

class TherapyListScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Services>> services = useState([]);
    final ValueNotifier<bool> loading = useState(false);
    final ValueNotifier<int?> currentPage = useState(null);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    final ValueNotifier<Map<String, dynamic>> filters = useState({
      'sortOrder': 'asc',
      'search': '',
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
          ...filters.value,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            services.value = [...services.value, ...(response.data ?? [])];
          }
          currentPage.value = response.currentPage ?? currentPage.value;
        }
      } catch (e) {
        logger.e('Error while fetching services');
      }
    }

    Future<void> loadMore() async {
      if ((currentPage.value ?? 0) >= filters.value['page']) return;
      loading.value = true;
      filters.value['page'] = filters.value['page'] + 1;
      await getServices();
      loading.value = false;
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([getServices()]);
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
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Header_v2(
                title: 'Browse Therapies',
                actions: [
                  GestureDetector(
                    onTap: () {
                      filters.value = {
                        'sortOrder': filters.value['sortOrder'] == 'asc'
                            ? 'desc'
                            : 'asc',
                        'search': filters.value['search'],
                        'page': 1,
                        'per_page': 10,
                      };
                      services.value = [];
                      getServices();
                    },
                    child: Icon(
                      Icons.sort,
                      size: 21.sp,
                      color: filters.value['sortOrder'] == 'asc'
                          ? Palette.black
                          : Palette.primary,
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
                        services.value = [];
                        loading.value = true;
                        await getServices();
                        loading.value = false;
                      } else {
                        filters.value['search'] = '';

                        filters.value['page'] = 1;
                        services.value = [];
                        loading.value = true;
                        await getServices();
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
                    hintText: "Search therapies",
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
              if (services.value.isNotEmpty)
                Wrap(
                  spacing: 3.w,
                  runSpacing: 0.5.h,
                  children: [
                    for (Services service in services.value)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, 'TherapyHome', (_) => false,
                              arguments: [2, service.id!]);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: TherapyCard(
                            service: service,
                            hidePrice: true,
                          ),
                        ),
                      ),
                  ],
                )
              else
                NoDataWidget(
                  onRetry: getServices,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
