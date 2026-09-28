import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/others/html_content_page.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../FirebaseProviders/auth_provider.dart';
import '../../../api/base_model.dart';
import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../api/server_error.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../utils/form_helper.dart';
import '../../../model/v2/account_delete_model.dart';
import '../../../model/v2/user_detail_model.dart';
import '../../utils/logger.dart';
import '../widgets/profile_card.dart';
import 'login.dart';

class Profile extends HookWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<UserDetail?> userDetails = useState(null);
    ValueNotifier<bool> loading = useState(true);

    Future logoutUser() async {
      SharedPreferenceHelper.clearPref();
      Provider.of<AuthProvider>(context, listen: false).handleSignOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        ModalRoute.withName('SplashScreen'),
      );
    }

    Future<BaseModel<UserDetail>> callApiForUserDetail() async {
      UserDetail response;
      loading.value = true;
      try {
        response = await RestClient(await RetroApi().dioData(context))
            .userDetailRequest();
        userDetails.value = response;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phone_no', response.phone ?? '');
        prefs.setString('email', response.email ?? '');
        prefs.setString('name', response.name ?? '');
        loading.value = false;
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
        return BaseModel()..setException(ServerError.withError(error: error));
      }
      return BaseModel()..data = response;
    }

    Future callDeleteAccount() async {
      AccountDeleteModel response;
      try {
        loading.value = true;
        response =
            await RestClient(await RetroApi().dioData(context)).deleteAccount();
        if (response.success == true) {
          if (response.message != null) {
            Fluttertoast.showToast(
              msg: '${response.message}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.primary,
              textColor: Palette.white,
            );
          }
          logoutUser();
        } else {
          if (response.message != null) {
            Fluttertoast.showToast(
              msg: '${response.message}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.primary,
              textColor: Palette.white,
            );
          }
        }
        loading.value = false;
      } catch (error) {
        loading.value = false;
        return BaseModel()..setException(ServerError.withError(error: error));
      }
      return BaseModel()..data;
    }

    void showDeleteAccountDialog() {
      FormHelper.showMessage(
        context,
        "Delete Account",
        "Are you sure you want to delete your account?",
        "Cancel",
        () {
          Navigator.of(context).pop();
        },
        buttonText2: "Delete",
        isConfirmationDialog: true,
        onPressed2: () {
          Navigator.of(context).pop();
          callDeleteAccount();
        },
      );
    }

    useEffect(() {
      // Check logged in status
      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        callApiForUserDetail();
      }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header_v2(
              color: Palette.primary,
              title: '',
            ),
            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) &&
                    userDetails.value != null
                ? Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Palette.primary,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(2.h),
                            bottomLeft: Radius.circular(2.h),
                          ),
                        ),
                        width: 100.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 2.h,
                        ),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              alignment: Alignment.center,
                              imageUrl: (userDetails.value?.fullImage != null &&
                                      userDetails.value!.fullImage!.isNotEmpty)
                                  ? userDetails.value!.fullImage!
                                  : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZHVjdHxlbnwwfHwwfHx8MA%3D%3D',
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 7.w,
                                backgroundColor: Palette.white,
                                child: CircleAvatar(
                                  radius: 6.5.w,
                                  backgroundImage: imageProvider,
                                ),
                              ),
                              placeholder: (context, url) =>
                                  SpinKitFadingCircle(color: Palette.primary),
                              errorWidget: (context, url, error) => ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/no_image.jpg",
                                  fit: BoxFit.fitHeight,
                                  width: 12.w,
                                  height: 12.w,
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${userDetails.value!.name}',
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
                                  '${userDetails.value!.email}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Palette.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ProfileSectionCard(
                        title: 'Edit Profile',
                        route: 'EditProfile',
                        icon: Icons.person_outline,
                      ),
                      ProfileSectionCard(
                        title: 'Change Password',
                        route: 'ChangePassword',
                        icon: Icons.password,
                      ),
                      ProfileSectionCard(
                        title: 'Therapy Booking',
                        route: 'TherapyHome',
                        icon: Icons.spa_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Buy Medicines',
                        route: 'MedicineHome',
                        icon: Icons.add_shopping_cart_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Blogs',
                        route: 'Blogs',
                        icon: Icons.article_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Manage Address',
                        route: 'AddressList',
                        icon: Icons.location_on_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Health Record',
                        route: 'HealthRecord',
                        icon: Icons.folder_shared_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Notifications',
                        icon: Icons.notifications_none,
                        route: 'Notifications',
                      ),
                      ProfileSectionCard(
                        title: 'WhatsApp Updates',
                        icon: Icons.chat_outlined,
                        route: 'WhatsAppOptIn',
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HtmlContentPage(
                                apiKey: 'about',
                                title: 'About Us',
                              ),
                            ),
                          );
                        },
                        child: ProfileSectionCard(
                          title: 'About',
                          icon: Icons.info_outline,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HtmlContentPage(
                                apiKey: 'terms_and_conditions',
                                title: 'Terms & Conditions',
                              ),
                            ),
                          );
                        },
                        child: ProfileSectionCard(
                          title: 'Terms & Conditions',
                          icon: Icons.info_outline,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HtmlContentPage(
                                apiKey: 'privacy_policy',
                                title: 'Privacy Policy',
                              ),
                            ),
                          );
                        },
                        child: ProfileSectionCard(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HtmlContentPage(
                                apiKey: 'cancellation_policy',
                                title: 'Cancellation Policy',
                              ),
                            ),
                          );
                        },
                        child: ProfileSectionCard(
                          title: 'Cancellation Policy',
                          icon: Icons.info_outline,
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            showDeleteAccountDialog();
                          },
                          child: ProfileSectionCard(
                            title: 'Delete Account',
                            icon: Icons.no_accounts_rounded,
                          )),
                      GestureDetector(
                          onTap: () {
                            FormHelper.showMessage(
                              context,
                              "Logout",
                              "Are you sure you want to Logout?",
                              "Cancel",
                              () {
                                Navigator.of(context).pop();
                              },
                              buttonText2: "Logout",
                              isConfirmationDialog: true,
                              onPressed2: () {
                                Preferences.checkNetwork().then((value) =>
                                    value == true ? logoutUser() : null);
                              },
                            );
                          },
                          child: ProfileSectionCard(
                            title: 'Logout',
                            icon: Icons.logout_rounded,
                          )),
                      SizedBox(height: 1.h),
                    ],
                  )
                : loading.value
                    ? Center(
                        child: NoDataWidget(),
                      )
                    : Center(
                        child: Text(
                          'Please login!',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
