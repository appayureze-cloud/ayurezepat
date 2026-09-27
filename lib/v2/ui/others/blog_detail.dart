import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/blog_details.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

class BlogDetail extends StatefulWidget {
  final int id;

  BlogDetail({required this.id});

  @override
  _BlogDetailState createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {
  bool loading = false;
  int? id = 0;
  String? title = "";
  String? desc = "";
  String? blogRef = "";
  String? fullImage = "";

  @override
  void initState() {
    super.initState();
    id = widget.id;
    callApiHealthTipDetail();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(title: 'Read Blog'),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                      width: width * 1,
                      height: width * 0.5,
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: '$fullImage',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => SpinKitFadingCircle(
                          color: Palette.blue,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "assets/images/white_img.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    Text(
                      '$title',
                      style: TextStyle(
                          fontSize: height * 0.022,
                          color: Palette.dark_blue,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(
                    horizontal: width * 0.05, vertical: width * 0.01),
                child: Column(
                  children: [
                    Text(
                      '$blogRef',
                      style: TextStyle(
                          fontSize: height * 0.017, color: Palette.grey),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.all(
                  width * 0.05,
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
      ),
    );
  }

  Future<BaseModel<BlogDetails>> callApiHealthTipDetail() async {
    BlogDetails response;
    setState(() {
      loading = true;
    });
    try {
      response =
          await RestClient(await RetroApi().dioData(context)).blogDetails(id);
      setState(() {
        setState(() {
          loading = false;
          if (response.success == true) {
            title = response.data!.title;
            desc = response.data!.desc;
            blogRef = response.data!.blogRef;
            fullImage = response.data!.fullImage;
          }
        });
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
