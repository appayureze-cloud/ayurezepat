import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/detail_setting_model.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

class HtmlContentPage extends StatefulWidget {
  final String title;
  final String apiKey;

  const HtmlContentPage({
    required this.title,
    required this.apiKey,
    Key? key,
  }) : super(key: key);

  @override
  _HtmlContentPageState createState() => _HtmlContentPageState();
}

class _HtmlContentPageState extends State<HtmlContentPage> {
  bool loading = false;

  String? content = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      appAllDetail(apiKey: widget.apiKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Header_v2(title: '${widget.title}'),
              content != null
                  ? Html(
                      data: '$content',
                    )
                  : NoDataWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<DetailSetting>> appAllDetail({
    required String apiKey,
  }) async {
    DetailSetting response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      if (response.success == true) {
        setState(() {
          loading = false;
          content = response.data!.toJson()[apiKey];
        });
      }
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
