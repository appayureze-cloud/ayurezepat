import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/appointment/appointment_list.dart';
import 'package:doctro_patient/v2/ui/authentication/profile.dart';
import 'package:doctro_patient/v2/ui/home/doctors_list.dart';
import 'package:doctro_patient/v2/ui/others/connectivity_responder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import 'home.dart';

class MainLandingPage extends HookWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> currentIndex = useState(0);
    ValueNotifier<int?> catId = useState(null);
    ValueNotifier<String?> search = useState(null);
    ValueNotifier<bool> loading = useState(true);

    useEffect(() {
      Future.microtask(() {
        List? arguments = ModalRoute.of(context)?.settings.arguments as List?;
        if (arguments != null &&
            arguments.isNotEmpty &&
            arguments.first is int) {
          currentIndex.value = arguments.first;
        }
        if (arguments != null &&
            arguments.isNotEmpty &&
            arguments.length > 1 &&
            arguments.first is int &&
            arguments.first == 1) {
          if (arguments[1] is int) catId.value = arguments[1];
          if (arguments[1] is String) search.value = arguments[1];
        }
        loading.value = false;
      });
    }, []);

    return ConnectivityResponder(
      childContext: context,
      child: ModalProgressHUD(
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
          child: Scaffold(
            key: _scaffoldKey,
            bottomNavigationBar: BottomNavigationBar(
              onTap: (index) {
                currentIndex.value = index;
                if (index == 1) {
                  search.value = null;
                  catId.value = null;
                }
              },
              selectedItemColor: Palette.primary,
              unselectedItemColor: Palette.grey,
              currentIndex: currentIndex.value,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.medical_services_outlined,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.meeting_room_outlined,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline_sharp,
                  ),
                  label: '',
                ),
              ],
            ),
            body: [
              MainHome(landingLoader: loading),
              DoctorsList(
                category: catId.value,
                search: search.value,
              ),
              AppointmentList(),
              Profile(),
            ].elementAt(currentIndex.value),
            floatingActionButton: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              children: [
                // WhatsApp Button
                SpeedDialChild(
                  child: Image.asset(
                    'assets/whatsapp.png',
                    height: 30,
                    width: 30,
                  ),
                  label: "Open WhatsApp",
                  backgroundColor: Colors.white,
                  onTap: () async {
                    var phone = SharedPreferenceHelper.getString(
                        Preferences.home_chatbot);
                    // Change to your number
                    var url = "https://wa.me/$phone";
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    } else {
                      // print("Could not open WhatsApp");
                    }
                  },
                ),
                // AI Chat Button
                // SpeedDialChild(
                //   child: Image.asset(
                //     'assets/ai_chat.png',
                //     height: 30,
                //     width: 30,
                //   ),
                //   label: "AI Chat",
                //   backgroundColor: Colors.white,
                //   onTap: () {
                //     // getOneSignalToken("d63f43da-5595-4865-85b8-b1146a1b1aaf");
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => AiDataCollector()),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
