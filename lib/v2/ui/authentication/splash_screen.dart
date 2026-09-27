import 'package:doctro_patient/const/Palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';

class SplashScreen extends HookWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void checkUserLoginStatus() async {
      await Future.delayed(Duration(seconds: 2));
      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        Navigator.pushReplacementNamed(context, "Home");
      } else {
        Navigator.pushReplacementNamed(context, "SignIn");
      }
    }

    useEffect(() {
      checkUserLoginStatus();
    }, []);

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Palette.white,
          ),
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/appIcon.jpg',
            width: 45.w,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }
}
