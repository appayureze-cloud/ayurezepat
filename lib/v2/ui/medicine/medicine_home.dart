import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctro_patient/model/v2/home_response.dart' as ht;
import 'package:doctro_patient/v2/ui/medicine/medicine_blog_detail.dart';
import 'package:doctro_patient/v2/ui/medicine/medicine_category_list.dart';
import 'package:doctro_patient/v2/ui/widgets/home_medicine_card.dart';
import 'package:doctro_patient/v2/ui/widgets/medicine_category_card.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../model/v2/medicine/medicine_home_response.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';

class MedicineHome extends HookWidget {
  const MedicineHome({super.key});

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final banners = useState<List<ht.Banner>>([]);
    final categories = useState<List<PopularCategories>>([]);
    final products = useState<List<PopularProducts>>([]);
    final blogs = useState<List<ShopifyBlog>>([]);
    final hasLoaded = useRef(false);

    Future<void> getData() async {
      try {
        if (hasLoaded.value) return;
        if (!context.mounted) return;
        hasLoaded.value = true;
        logger.w('calle..');
        blogs.value = [];
        MedicineHomeResponse response =
            await RestClient(await RetroApi().dioData(context))
                .medicineHomeData();
        if (response.success == true) {
          blogs.value = response.data?.blogs ?? [];
          categories.value = response.data?.popularCategories ?? [];
          products.value = response.data?.popularProducts ?? [];
          banners.value = response.data?.banners ?? [];
        }
        loading.value = false;
      } catch (e, stacktrace) {
        logger.e("Error in medicine home: $e\nStackTrace: $stacktrace");
        loading.value = false;
      }
    }

    useEffect(() {
      getData();
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
              title: 'Medicine',
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'Notifications');
                  },
                  child: Icon(
                    Icons.notifications_none,
                    size: 18.sp,
                    color: Palette.black,
                  ),
                ),
                SizedBox(width: 3.w),
                Badge(
                  smallSize: 10.sp,
                  largeSize: 10.sp,
                  textStyle: TextStyle(
                    fontSize: 10.sp,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'Cart');
                    },
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 18.sp,
                      color: Palette.black,
                    ),
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
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shop By Categories',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MedicineCategoryList()));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (categories.value.isEmpty)
                    NoDataSectionWidget()
                  else
                    SizedBox(
                      width: 100.w,
                      child: GridView.count(
                        crossAxisCount: 3, // 2 columns
                        mainAxisSpacing: 1.w,
                        crossAxisSpacing: 1.w,
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // If inside another scroll
                        childAspectRatio: 0.92, // Adjust width/height ratio
                        children: [
                          for (PopularCategories category in categories.value)
                            MedicineCategoryCard(category: category),
                        ],
                      ),
                    ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: TextStyle(
                          color: Palette.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, 'MedicineHome',
                              arguments: [2]);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  if (products.value.isEmpty)
                    NoDataSectionWidget()
                  else
                    SizedBox(
                      width: 100.w,
                      child: Wrap(
                        runAlignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        spacing: 1.w,
                        runSpacing: 1.w,
                        children: [
                          for (PopularProducts product in products.value)
                            HomeMedicineCard(product: product),
                        ],
                      ),
                    ),
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
                                            MedicineBlogDetails(
                                          fullImage:
                                              blogs.value[i].image?.src ?? '',
                                          title: blogs.value[i].title ??
                                              'No Title',
                                          desc: blogs.value[i].bodyHtml ??
                                              '<center><b>No Data</b></center>',
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
                                                  blogs.value[i].image?.src ??
                                                      '',
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
    );
  }
}
