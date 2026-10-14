import 'dart:async';

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
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../features/appointments/domain/entities/doctor_summary.dart';
import '../../../features/appointments/presentation/appointment_service.dart';
import '../../../model/v2/blog.dart';
import '../../../model/v2/user_detail_model.dart';
import '../../../theme.dart';
import '../../utils/logger.dart';
import '../others/notifications.dart';
import '../widgets/coming_soon.dart';
import '../widgets/popular_doctor_card.dart';

class MainHome extends HookWidget {
  final ValueNotifier<bool> landingLoader;

  MainHome({required this.landingLoader, super.key});

  final loc.Location location = new loc.Location();

  @override
  Widget build(BuildContext context) {
    final blogs = useState<List<Blogs>>([]);
    final categories = useState<List<hr.DoctorCategory>>([]);
    final doctors = useState<List<DoctorSummary>>([]);
    final banners = useState<List<hr.Banner>>([]);
    final loading = useState(true);
    final _isRequestingPermission = useState(false);
    final userDetails = useState<UserDetail?>(null);
    final place = useState<Placemark?>(null);

    Future<void> loadDoctors() async {
      // Sourced from the real Astra/Supabase doctors table, not the Laravel
      // home response - Laravel doctor ids and Astra doctor_ids are not the
      // same identity space, so this can't come from appointmentHomeData().
      try {
        doctors.value = await AppointmentService().listDoctors();
      } catch (e) {
        logger.e('Error fetching doctors from Astra: $e');
      }
    }

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
        unawaited(loadDoctors());
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
        color: AppColors.sagePrimary,
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
                    // Greeting header + notification bell (Stitch: Top App
                    // Bar + "Good morning" headline, ayureze_home/code.html).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${userDetails.value?.name ?? 'there'}',
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${place.value?.locality ?? ''} ${place.value?.administrativeArea ?? ''}'
                                          .trim()
                                          .isEmpty
                                      ? 'How is your care today?'
                                      : '${place.value?.locality} ${place.value?.administrativeArea}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Notifications()));
                            },
                            icon: const Icon(Icons.notifications_none,
                                color: AppColors.sagePrimary),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'MedicineHome');
                            },
                            icon: const Icon(Icons.shopping_cart_outlined,
                                color: AppColors.sagePrimary),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (text) {
                          if (text.isNotEmpty) {
                            Navigator.pushReplacementNamed(context, 'Home',
                                arguments: [doctorsTabIndex, text]);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search doctors, medicines...',
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.slateTextMuted),
                        ),
                      ),
                    ),
                    // Hero "Talk to Astra" card
                    // (ayureze_home/code.html: "AI Ayurvedic Companion").
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, 'Home',
                            arguments: [astraTabIndex]),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.sagePrimaryContainer,
                                AppColors.sagePrimary,
                              ],
                            ),
                            borderRadius: AppRadius.roundedLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.psychology,
                                        size: 18, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'AI AYURVEDIC COMPANION',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Talk to Astra',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(color: Colors.white)),
                              const SizedBox(height: 6),
                              Text(
                                'Describe your symptoms or ask about remedies and daily rituals.',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.creamSurfaceLowest,
                                  borderRadius: AppRadius.roundedPill,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Start conversation',
                                        style: TextStyle(
                                            color: AppColors.sagePrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward,
                                        size: 16, color: AppColors.sagePrimary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 3.h),
                          Text(
                            'What are you looking for',
                            style: TextStyle(
                              color: AppColors.slateTextMuted,
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
                                                        ? AppColors.sagePrimary
                                                        : i == 1
                                                            ? Color(0xffE2B5B5)
                                                            : i == 2
                                                                ? Color(
                                                                    0xffF17171)
                                                                : i == 3
                                                                    ? Color(
                                                                        0xffE7A03D)
                                                                    : AppColors
                                                                        .sagePrimary),
                                                child: SvgPicture.asset(
                                                  'assets/icons/${i == 0 ? 'doctor' : i == 1 ? 'lab_test' : i == 2 ? 'therapy' : i == 3 ? 'medicine' : 'medical_tourism'}.svg',
                                                  height: 11.w,
                                                  width: 11.w,
                                                  color: AppColors
                                                      .creamSurfaceLowest,
                                                ),
                                              ),
                                              SizedBox(height: 10.sp),
                                              Text(
                                                '${i == 0 ? 'Doctor' : i == 1 ? 'Lab Test' : i == 2 ? 'Therapy' : i == 3 ? 'Medicine' : 'Medical Tourism'}',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.slateTextMuted,
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
                                  color: AppColors.slateTextMuted,
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
                                    color: AppColors.sagePrimary,
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
                                  color: AppColors.slateTextMuted,
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
                                    color: AppColors.sagePrimary,
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
                                  color: AppColors.slateTextPrimary,
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
                                    color: AppColors.sagePrimary,
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
                                            color: AppColors.creamSurfaceLowest,
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
                                                        color: AppColors
                                                            .sagePrimary,
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
                                                            color: AppColors
                                                                .slateTextPrimary,
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
                                                            color: AppColors
                                                                .slateTextPrimary,
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
