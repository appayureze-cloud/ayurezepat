import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctro_patient/model/v2/home_response.dart' as hr;
import 'package:doctro_patient/v2/ui/home/doctor_category_list.dart';
import 'package:doctro_patient/v2/utils/nav_constants.dart';
import 'package:doctro_patient/v2/ui/others/blog_detail.dart';
import 'package:doctro_patient/v2/ui/others/blog_list.dart';
import 'package:doctro_patient/v2/ui/widgets/doctor_category_card.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../model/v2/blog.dart';
import '../../../model/v2/user_detail_model.dart';
import '../../utils/logger.dart';
import '../widgets/coming_soon.dart';
import '../widgets/popular_doctor_card.dart';

class MainHome extends HookWidget {
  final ValueNotifier<bool> landingLoader;

  MainHome({required this.landingLoader, super.key});

  final loc.Location location = new loc.Location();

  @override
  Widget build(BuildContext context) {
    final _showSearch = useState(false);
    final blogs = useState<List<Blogs>>([]);
    final categories = useState<List<hr.DoctorCategory>>([]);
    final doctors = useState<List<hr.Doctor>>([]);
    final banners = useState<List<hr.Banner>>([]);
    final loading = useState(true);
    final _isRequestingPermission = useState(false);
    final userDetails = useState<UserDetail?>(null);
    final place = useState<Placemark?>(null);

    Future<void> callApiForUserDetail() async {
      try {
        logger.i('fetching user...');
        UserDetail response =
            await RestClient(await RetroApi().dioData(context))
                .userDetailRequest();
        if (response.id != null) {
          userDetails.value = response;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('phone_no', response.phone ?? '');
          prefs.setString('email', response.email ?? '');
          prefs.setString('name', response.name ?? '');
        } else {
          logger.e('unable to fetch user ${response.toJson()}');
        }
      } catch (error, stacktrace) {
        logger.e("Exception occurred: $error\nStackTrace: $stacktrace");
      }
    }

    Future<void> getLocation() async {
      try {
        landingLoader.value = true;
        loading.value = true;
        if (_isRequestingPermission.value) return;

        _isRequestingPermission.value = true;
        var permissionStatus = PermissionStatus.denied;
        // Request permission
        try {
          permissionStatus = await Permission.location.request();
        } catch (e) {}

        SharedPreferences prefs = await SharedPreferences.getInstance();
        double? lat = prefs.getDouble('lat');
        double? lang = prefs.getDouble('lang');

        if (permissionStatus == PermissionStatus.granted) {
          bool serviceEnabled = await location.serviceEnabled();
          if (!serviceEnabled) {
            serviceEnabled = await location.requestService();
            if (!serviceEnabled) {
              logger.e("Location services are disabled.");
            }
          }
          var locationData = await location.getLocation();

          lat = locationData.latitude;
          lang = locationData.longitude;

          if (lat != null) prefs.setDouble('lat', lat);
          if (lang != null) prefs.setDouble('lang', lang);

          try {
            if (lat != null && lang != null) {
              final placemarks = await placemarkFromCoordinates(
                lat,
                lang,
              );
              place.value = placemarks.isNotEmpty ? placemarks[0] : null;
            }
          } catch (e) {
            logger.e(e);
          }
        }

        if (!context.mounted) return;

        blogs.value = [];
        hr.HomeResponse response =
            await RestClient(await RetroApi().dioData(context))
                .appointmentHomeData(lat, lang);

        if (response.success == true) {
          blogs.value = response.data?.blogs ?? [];
          categories.value = response.data?.categories ?? [];
          doctors.value = response.data?.doctors ?? [];
          banners.value = response.data?.banner ?? [];

          if (response.data?.settings != null) {
            hr.Settings settings = response.data!.settings!;
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.currency_symbol, settings.currencySymbol);
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.currency_code, settings.currencyCode);
            SharedPreferenceHelper.setIntIfNotNull(
                Preferences.razor, settings.razor);
            SharedPreferenceHelper.setIntIfNotNull(
                Preferences.cod, settings.cod);
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.razor_key, settings.razorKey);
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.agoraAppId, settings.agoraAppId);
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.medical_tourism, settings.medical_tourism);
            SharedPreferenceHelper.setStringIfNotNull(
                Preferences.home_chatbot, settings.home_chatbot);
          }
        }
        await callApiForUserDetail();
        loading.value = false;
        landingLoader.value = false;
      } catch (e, stacktrace) {
        logger.e("Error in reverse geocoding: $e\nStackTrace: $stacktrace");
        loading.value = false;
      } finally {
        _isRequestingPermission.value = false;
      }
    }

    final locationFuture = useMemoized(() => getLocation(), []);
    final locationSnapshot = useFuture(locationFuture);

    return ModalProgressHUD(
      inAsyncCall: loading.value ||
          locationSnapshot.connectionState == ConnectionState.waiting,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: RefreshIndicator(
        onRefresh: loading.value ? () async {} : getLocation,
        child: userDetails.value == null || locationSnapshot.hasError
            ? NoDataWidget(onRetry: () => getLocation())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: _showSearch.value ? 20.h : 16.5.h,
                      child: Stack(
                        children: [
                          Container(
                            height: _showSearch.value ? 18.h : 13.5.h,
                            color: Palette.primary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: 6.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${userDetails.value?.name ?? '-'}',
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                color: Palette.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              size: 21.sp,
                                              color: Palette.white,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${place.value?.locality ?? '-'} ${place.value?.administrativeArea ?? ''} ${place.value?.country ?? ''}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Palette.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showSearch.value =
                                                !_showSearch.value;
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5.sp),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Palette
                                                    .white, // Border color
                                                width: 0.5, // Border width
                                              ),
                                            ),
                                            child: Icon(
                                              !_showSearch.value
                                                  ? Icons.search
                                                  : Icons.search_off_outlined,
                                              size: 18.sp,
                                              color: Palette.white,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, 'MedicineHome');
                                          },
                                          child: Badge(
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(left: 15.sp),
                                              padding: EdgeInsets.all(5.sp),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Palette
                                                      .white, // Border color
                                                  width: 0.5, // Border width
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.shopping_cart_outlined,
                                                size: 18.sp,
                                                color: Palette.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: _showSearch.value ? 1 : 0,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  textAlignVertical: TextAlignVertical.center,
                                  onSubmitted: (text) {
                                    if (text.isNotEmpty) {
                                      Navigator.pushReplacementNamed(
                                          context, 'Home',
                                          arguments: [doctorsTabIndex, text]);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Palette.white,
                                    constraints: BoxConstraints(
                                      maxHeight: 5.5.h,
                                      maxWidth: 80.w,
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
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_showSearch.value) SizedBox(height: 1.h),
                          Text(
                            'What are you looking for',
                            style: TextStyle(
                              color: Palette.grey,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          SizedBox(
                            width: 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                for (int i = 0; i < 5; i++)
                                  GestureDetector(
                                    onTap: () async {
                                      switch (i) {
                                        case 0:
                                          Navigator.pushReplacementNamed(
                                              context, 'Home',
                                              arguments: [doctorsTabIndex]);
                                          break;
                                        case 2:
                                          Navigator.pushNamed(
                                              context, 'TherapyHome');
                                          break;
                                        case 3:
                                          Navigator.pushNamed(
                                              context, 'MedicineHome');
                                          break;
                                        case 4:
                                          {
                                            var url = SharedPreferenceHelper
                                                .getString(Preferences
                                                    .medical_tourism);
                                            if (url != null &&
                                                await canLaunchUrl(
                                                    Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } else {
                                              logger.i("Could not open url");
                                            }
                                            break;
                                          }
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 16.w,
                                          // height: 8.h,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(2.w),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: i == 0
                                                        ? Palette.primary
                                                        : i == 1
                                                            ? Color(0xffE2B5B5)
                                                            : i == 2
                                                                ? Color(
                                                                    0xffF17171)
                                                                : i == 3
                                                                    ? Color(
                                                                        0xffE7A03D)
                                                                    : Palette
                                                                        .primary),
                                                child: SvgPicture.asset(
                                                  'assets/icons/${i == 0 ? 'doctor' : i == 1 ? 'lab_test' : i == 2 ? 'therapy' : i == 3 ? 'medicine' : 'medical_tourism'}.svg',
                                                  height: 11.w,
                                                  width: 11.w,
                                                  color: Palette.white,
                                                ),
                                              ),
                                              SizedBox(height: 10.sp),
                                              Text(
                                                '${i == 0 ? 'Doctor' : i == 1 ? 'Lab Test' : i == 2 ? 'Therapy' : i == 3 ? 'Medicine' : 'Medical Tourism'}',
                                                style: TextStyle(
                                                  color: Palette.grey,
                                                  fontSize: 14.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (i == 1)
                                          HorizontalComingSoonRibbon(
                                            width: 28.w,
                                            height: 5.h,
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Browse by category',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 16.sp,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              DoctorCategoryList()));
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          if (categories.value.isNotEmpty)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 2.5.w,
                              children: List.generate(
                                  categories.value.length,
                                  (index) => DoctorCategoryCard(
                                      catagory: categories.value[index])),
                            )
                          else
                            NoDataSectionWidget(),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Popular Doctors',
                                style: TextStyle(
                                  color: Palette.grey,
                                  fontSize: 16.sp,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, 'Home',
                                      arguments: [doctorsTabIndex]);
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          if (doctors.value.isNotEmpty)
                            Wrap(
                              spacing: 2.w,
                              runSpacing: 1.w,
                              children:
                                  List.generate(doctors.value.length, (i) {
                                return PopularDoctorCard(
                                    doctor: doctors.value[i]);
                              }),
                            )
                          else
                            NoDataSectionWidget(),
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => BlogsList()));
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
                                                builder: (context) =>
                                                    BlogDetail(
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
                                                      alignment:
                                                          Alignment.center,
                                                      imageUrl: blogs
                                                          .value[i].fullImage!,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitFadingCircle(
                                                        color: Palette.primary,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
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
                                                    padding:
                                                        EdgeInsets.all(1.h),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          blogs.value[i].title!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            color: Palette
                                                                .dark_blue,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          blogs.value[i]
                                                                  .blogRef ??
                                                              '',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: Palette
                                                                .dark_blue,
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
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
