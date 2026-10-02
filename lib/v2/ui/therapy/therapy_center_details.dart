import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctro_patient/model/v2/center_details_response.dart';
import 'package:doctro_patient/model/v2/therapy_home_response.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';
import '../widgets/no_data.dart';
import '../widgets/therapy_card.dart';
import '../widgets/therapy_package_card.dart';

class TherapyCentersDetails extends HookWidget {
  final Centers center;

  const TherapyCentersDetails({required this.center, super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<Centers?> centerDetails = useState(null);
    ValueNotifier<List<Services>> services = useState([]);
    ValueNotifier<List<Packages>> packages = useState([]);
    ValueNotifier<int> _currentIndex = useState(0);

    Future<void> fetchCenterDetails() async {
      loading.value = true;
      try {
        CenterDetailsResponse response =
            await RestClient(await RetroApi().dioData(context))
                .getCenterDetails(center.id!);
        if (response.success == true && response.data != null) {
          centerDetails.value = response.data!.center!;
          services.value = response.data!.services!;
          packages.value = response.data!.packages!;
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      fetchCenterDetails();
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
                  children: [
                    Header_v2(
                      title: 'Therapy Center Details',
                    ),
                    SizedBox(height: 2.h),
                    if (centerDetails.value!.gallery!.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          autoPlay: true,
                          onPageChanged: (index, _) {},
                        ),
                        items: centerDetails.value!.gallery!.map((image) {
                          return Builder(
                            builder: (BuildContext context) {
                              return CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    if (centerDetails.value!.gallery!.isNotEmpty)
                      SizedBox(height: 1.h),
                    if (centerDetails.value!.gallery!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                                centerDetails.value!.gallery!.length, (i) => i)
                            .asMap()
                            .entries
                            .map((entry) {
                          return Container(
                            width: 2.w,
                            height: 2.w,
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex.value == entry.key
                                  ? Palette.grey
                                  : Palette.grey.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    if (centerDetails.value!.gallery!.isNotEmpty)
                      SizedBox(height: 3.h),
                    Text(
                      '${centerDetails.value!.name}',
                      style: TextStyle(
                        color: Palette.primary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${centerDetails.value!.address}',
                      style: TextStyle(
                        color: Palette.grey,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IgnorePointer(
                          child: RatingBar.builder(
                            initialRating: double.tryParse(
                                    '${centerDetails.value!.rate}') ??
                                0,
                            minRating: 1,
                            glowColor: Palette.rating,
                            unratedColor: Palette.rating,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 4.w,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Palette.rating,
                            ),
                            onRatingUpdate: (double value) {},
                          ),
                        ),
                        Text(
                          '(${centerDetails.value!.review})',
                          style: TextStyle(
                            color: Palette.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 3.5.w,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Divider(color: Palette.lightGrey),
                    SizedBox(height: 0.5.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Services',
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            for (Services service in services.value)
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TherapyBookingScreen(
                                          center: center,
                                          service: service,
                                        ),
                                      ),
                                    );
                                  },
                                  child: TherapyCard(service: service)),
                            if (services.value.isEmpty) NoDataSectionWidget(),
                            SizedBox(height: 2.h),
                            Text(
                              'Packages',
                              style: TextStyle(
                                color: Palette.black,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            for (Packages package in packages.value)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TherapyBookingScreen(
                                        center: center,
                                        package: Packages.fromJson({
                                          ...package.toJson(),
                                          'center':
                                              centerDetails.value!.toJson(),
                                        }),
                                      ),
                                    ),
                                  );
                                },
                                child: TherapyPackageCard(
                                    package: Packages.fromJson({
                                  ...package.toJson(),
                                  'center': centerDetails.value!.toJson(),
                                })),
                              ),
                            if (packages.value.isEmpty) NoDataSectionWidget(),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
      ),
    );
  }
}
