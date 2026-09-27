import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/v2/ui/widgets/button_v2.dart';
import 'package:doctro_patient/v2/ui/widgets/custom_text_field.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../../../model/v2/review_model.dart';

class ReviewScreen extends HookWidget {
  final int id;
  final String from;

  ReviewScreen({
    required this.id,
    required this.from,
  });

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> loading = useState(false);
    final TextEditingController userReview = useTextEditingController();
    ValueNotifier<int?> _userRating = useState(null);

    Future<void> callApiReview() async {
      try {
        loading.value = true;
        Map<String, dynamic> body = {
          "review": userReview.text,
          "rate": _userRating.value,
          "appointment_id": from == 'appointment' ? id : null,
          "therapy_booking_id": from == 'therapy' ? id : null,
        };
        ReviewResponse response = from == 'appointment'
            ? await RestClient(await RetroApi().dioData(context))
                .addAppointmentReview(body)
            : await RestClient(await RetroApi().dioData(context))
                .addTherapyReview(body);
        if (response.success == true) {
          loading.value = false;
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: '${response.data}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          loading.value = false;
          Fluttertoast.showToast(
            msg: '${response.data}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (error, stacktrace) {
        loading.value = false;
        Fluttertoast.showToast(
          msg: 'Failed to submit review',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: loading.value,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.primary,
          size: 3.h,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Header_v2(title: 'Add Review'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      Text(
                        "Write your review",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Palette.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 100.w,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: CustomTextField(
                                textInputType: TextInputType.multiline,
                                controller: userReview,
                                //Normal textInputField will be displayed
                                maxLines: 6,
                                hint:
                                    'Your review helps our patient make better choices',
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return "Please enter your review";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Rate your appointment",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Palette.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 8.w,
                        itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Palette.rating,
                        ),
                        onRatingUpdate: (rating) {
                          _userRating.value = rating.toInt();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 10.h,
        child: ButtonV2(
          label: 'Submit',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _userRating.value != null
                  ? callApiReview()
                  : Fluttertoast.showToast(
                      msg: "Please add ratings!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
            }
          },
        ),
      ),
    );
  }
}
