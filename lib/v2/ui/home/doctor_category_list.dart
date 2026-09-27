import 'package:doctro_patient/v2/ui/widgets/doctor_category_card.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/category_list_response.dart';
import '../../../model/v2/doctor_list_response.dart';
import '../../../model/v2/home_response.dart';
import '../../utils/helper.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';

class DoctorCategoryList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<DoctorCategory>> categories = useState([]);
    final ValueNotifier<Meta?> meta = useState(null);
    final ValueNotifier<bool> loading = useState(false);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    final ValueNotifier<Map<String, dynamic>> filters = useState({
      'sortOrder': 'asc',
      'search': '',
      'page': 1,
      'per_page': 10,
    });
    final scrollController = useScrollController();

    Future<void> getCategories() async {
      try {
        loading.value = true;
        CategoryListResponse response =
            await RestClient(await RetroApi().dioData(context)).categoriesList({
          "sortOrder": "asc",
          "page": 1,
          ...filters.value,
        });
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            categories.value = [...categories.value, ...(response.data ?? [])];
          }
          meta.value = response.meta;
        }
      } catch (e) {
        logger.e('Error while fetching doctors');
      } finally {
        loading.value = false;
      }
    }

    Future<void> loadMore() async {
      if ((meta.value?.totalPages ?? 0) <= filters.value['page']) return;
      loading.value = true;
      filters.value['page'] = filters.value['page'] + 1;
      await getCategories();
      loading.value = false;
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([getCategories()]);
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
                title: 'Browse Categories',
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
                      categories.value = [];
                      getCategories();
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
                        categories.value = [];
                        getCategories();
                      } else {
                        filters.value['search'] = '';
                        filters.value['page'] = 1;
                        categories.value = [];
                        getCategories();
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
                    hintText: "Search categories",
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
              categories.value.isEmpty
                  ? NoDataWidget(
                      onRetry: () {
                        categories.value = [];
                        getCategories();
                      },
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: categories.value.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 1.h,
                        crossAxisSpacing: 2.w,
                        childAspectRatio: 1.2, // Adjust based on your card size
                      ),
                      itemBuilder: (context, index) {
                        return DoctorCategoryCard(
                            catagory: categories.value[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
