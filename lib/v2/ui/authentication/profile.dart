import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/theme.dart';
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
              backgroundColor: AppColors.sagePrimary,
              textColor: AppColors.sageOnPrimary,
            );
          }
          logoutUser();
        } else {
          if (response.message != null) {
            Fluttertoast.showToast(
              msg: '${response.message}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.sagePrimary,
              textColor: AppColors.sageOnPrimary,
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
      progressIndicator: const SpinKitFadingCircle(
        color: AppColors.sagePrimary,
        size: 36,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header_v2(title: 'Profile'),
            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) &&
                    userDetails.value != null
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                                radius: 32,
                                backgroundColor: AppColors.sagePrimaryContainer,
                                child: CircleAvatar(
                                  radius: 29,
                                  backgroundImage: imageProvider,
                                ),
                              ),
                              placeholder: (context, url) =>
                                  const SpinKitFadingCircle(
                                      color: AppColors.sagePrimary),
                              errorWidget: (context, url, error) => ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/images/no_image.jpg",
                                  fit: BoxFit.fitHeight,
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userDetails.value!.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${userDetails.value!.email}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
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
                        title: 'Medication Reminders',
                        route: 'MedicationReminders',
                        icon: Icons.medication_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Documents',
                        route: 'Documents',
                        icon: Icons.description_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Health Vault',
                        route: 'VaultLock',
                        icon: Icons.shield_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'Settings',
                        route: 'SettingsHome',
                        icon: Icons.settings_outlined,
                      ),
                      ProfileSectionCard(
                        title: 'My Case',
                        route: 'CaseSummary',
                        icon: Icons.assignment_turned_in_outlined,
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
                            color: AppColors.slateTextPrimary,
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
