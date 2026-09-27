import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' show SpinKitFadingCircle;
import 'package:sizer/sizer.dart';

class MedicineBlogDetails extends StatelessWidget {
  final String fullImage;
  final String title;
  final String desc;
  const MedicineBlogDetails({
    required this.fullImage,
    required this.title,
    required this.desc,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(title: 'Blog'),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: 5.w,
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: '$fullImage',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => SpinKitFadingCircle(
                          color: Palette.blue,
                        ),
                        errorWidget: (context, url, error) => Center(
                        child: Image.asset(
                          "assets/images/NoImage.png",
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  children: [
                    Text(
                      '$title',
                      style: TextStyle(
                          fontSize: 2.h,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(
                  2.w,
                ),
                child: Column(
                  children: [
                    Html(data: "$desc"),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}