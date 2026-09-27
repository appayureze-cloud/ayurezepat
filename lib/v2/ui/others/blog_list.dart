import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/base_model.dart' show BaseModel;
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/blog.dart' show Blogs, BlogsResponse;
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import 'blog_detail.dart';

class BlogsList extends StatefulWidget {
  @override
  _BlogsListState createState() => _BlogsListState();
}

class _BlogsListState extends State<BlogsList> {
  bool loading = false;
  List<Blogs> blogsList = [];

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Header_v2(title: 'Blogs'),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: RefreshIndicator(
                  onRefresh: fetchBlogs,
                  child: blogsList.length != 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: blogsList.length,
                              padding: EdgeInsets.symmetric(
                                vertical: 1.h,
                              ),
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
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
                                                  id: blogsList[index].id!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            color: Palette.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1.h),
                                            ),
                                            elevation: 5,
                                            child: Row(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 1.h,
                                                  ),
                                                  child: Container(
                                                    width: 15.w,
                                                    height: 15.w,
                                                    child: CachedNetworkImage(
                                                      alignment:
                                                          Alignment.center,
                                                      imageUrl: blogsList[index]
                                                          .fullImage!,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          SpinKitFadingCircle(
                                                        color: Palette.blue,
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
                                                        EdgeInsets.all(2.w),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          blogsList[index]
                                                              .title!,
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
                                                          blogsList[index]
                                                              .blogRef!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
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
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      : NoDataWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<BlogsResponse>> fetchBlogs() async {
    BlogsResponse response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(await RetroApi().dioData(context)).blogList();
      setState(() {
        loading = false;
        if (response.success == true) {
          blogsList.addAll(response.data!);
        }
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
