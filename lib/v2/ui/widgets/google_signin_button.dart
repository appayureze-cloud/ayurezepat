import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../FirebaseProviders/auth_provider.dart';
import '../../../const/prefConstatnt.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Center(
      child: SizedBox(
        width: 85.w,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.white,
            minimumSize: Size(85.w, 5.h),
            maximumSize: Size(85.w, 5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.h),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            elevation: 2,
          ),
          onPressed: () async {
            try {
              bool success = await authProvider.handleGoogleSignIn(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google Sign-In successful')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google Sign-In failed or cancelled')),
                );
              }
            } catch (e) {
              Preferences.hideDialog(context);
              logger.e(e);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/google_logo.png',
                height: 7.w,
                width: 7.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
