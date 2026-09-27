import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/model/v2/home_response.dart' as hr show Banner;
import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:doctro_patient/v2/ui/others/blog_detail.dart';
import 'package:doctro_patient/v2/ui/others/blog_list.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_booking.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_list.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_packages_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/blog.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';
import '../widgets/no_data.dart';
import '../widgets/therapy_card.dart';
import '../widgets/therapy_center_card.dart';
import '../widgets/therapy_package_card.dart';
import 'landing_screen.dart';

class TherapyHome extends HookWidget {
  const TherapyHome({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Blogs>> blogs = useState([]);

    final services = useState<List<Services>>([]);
    final centers = useState<List<Centers>>([]);
    final banners = useState<List<hr.Banner>>([]);
    final packages = useState<List<Packages>>([]);
    ValueNotifier<bool> loading = useState(true);
    Future<void> fetchData() async {
      try {
        loading.value = true;
        double? lat = SharedPreferenceHelper.getDouble('lat');
        double? lang = SharedPreferenceHelper.getDouble('lang');

        if (!context.mounted) return;

        blogs.value = [];
        TherapyHomeResponse response =
            await RestClient(await RetroApi().dioData(context))
                .therapyHomeData(lat, lang);

        if (response.success == true) {
          blogs.value = response.data?.blogs ?? [];
          services.value = response.data?.services ?? [];
          centers.value = response.data?.centers ?? [];
          banners.value = response.data?.banner ?? [];
          packages.value = response.data?.packages ?? [];
        }
        loading.value = false;
      } catch (e, stacktrace) {
        logger.e("Error in reverse geocoding: $e\nStackTrace: $stacktrace");
        loading.value = false;
      }
    }

    useEffect(() {
      fetchData();
    }, []);

    return ModalProgressHUD(
      inAsyncCall: loading.value,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Header_v2(
              title: 'Therapy',
              actions: [
                InkWell(
                  onTap: () {},
                  child: Icon(
                    Icons.search,
                    size: 18.sp,
                    color: Palette.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            // Banner
            if (banners.value.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  onPageChanged: (index, _) {},
                ),
                items: banners.value.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return CachedNetworkImage(
                        imageUrl: image.fullImage ?? '',
                        fit: BoxFit.cover,
                      );
                    },
                  );
                }).toList(),
              ),
            if (banners.value.isNotEmpty) SizedBox(height: 3.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Upcoming Bookings',
                  //       style: TextStyle(
                  //         color: Palette.black,
                  //         fontSize: 17.sp,
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         Navigator.pushReplacementNamed(
                  //             context, 'MedicineHome',
                  //             arguments: [1]);
                  //       },
                  //       child: Text(
                  //         'View All',
                  //         style: TextStyle(
                  //           color: Palette.primary,
                  //           fontSize: 16.sp,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 1.h),
                  // TherapyBookingCard(showBookAgain: true),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Our Partnered Centers',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 17.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TherapyLandingPage(
                                        index: 2,
                                      )));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  for (Centers center in centers.value)
                    TherapyCenterCard(center: center),
                  if (centers.value.isEmpty) NoDataSectionWidget(),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Treatments',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 17.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TherapyListScreen()));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  for (Services service in services.value)
                    GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, 'TherapyHome',
                              arguments: [2, service.therapy_services_id]);
                        },
                        child: TherapyCard(
                          service: service,
                          hidePrice: true,
                        )),
                  if (services.value.isEmpty) NoDataSectionWidget(),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Packages',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 17.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => TherapyPackagesScreen()));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  for (Packages package in packages.value)
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TherapyBookingScreen(
                                center: package.center!,
                                package: package,
                              ),
                            ),
                          );
                        },
                        child: TherapyPackageCard(package: package)),
                  if (packages.value.isEmpty) NoDataSectionWidget(),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Blogs',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 17.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => BlogsList()));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  blogs.value.length != 0
                      ? Column(
                          children: [
                            for (int i = 0; i < blogs.value.length; i++)
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                ),
                                width: 100.w,
                                height: 10.h,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlogDetail(
                                          id: blogs.value[i].id!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Palette.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.sp),
                                    ),
                                    elevation: 5,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                            vertical: 1.h,
                                          ),
                                          child: Container(
                                            width: 10.w,
                                            height: 10.w,
                                            child: CachedNetworkImage(
                                              alignment: Alignment.center,
                                              imageUrl:
                                                  blogs.value[i].fullImage!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  SpinKitFadingCircle(
                                                color: Palette.primary,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                "assets/images/NoImage.png",
                                                fit: BoxFit.fitHeight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 65.w,
                                          child: Padding(
                                            padding: EdgeInsets.all(1.h),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  blogs.value[i].title!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Palette.dark_blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  blogs.value[i].blogRef ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Palette.dark_blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : NoDataSectionWidget(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
