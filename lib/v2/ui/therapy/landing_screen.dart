import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_booking_list.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_centers_list.dart';
import 'package:doctro_patient/v2/ui/therapy/therapy_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../utils/logger.dart';

class TherapyLandingPage extends HookWidget {
  TherapyLandingPage({this.index, super.key});

  final int? index;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> currentIndex = useState(index ?? 0);
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<int?> serviceId = useState(null);
    ValueNotifier<String?> search = useState(null);

    useEffect(() {
      Future.microtask(() {
        List? arguments = ModalRoute.of(context)?.settings.arguments as List?;
        logger.w(arguments);
        if (arguments != null &&
            arguments.isNotEmpty &&
            arguments.first is int) {
          currentIndex.value = arguments.first;
        }
        if (arguments != null &&
            arguments.isNotEmpty &&
            arguments.length > 1 &&
            arguments.first is int &&
            arguments.first == 2) {
          if (arguments[1] is int) serviceId.value = arguments[1];
          if (arguments[1] is String) search.value = arguments[1];
        }
        loading.value = false;
      });
    }, []);

    return ModalProgressHUD(
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
              if (index == 2) {
                search.value = null;
                serviceId.value = null;
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
                  Icons.list,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                ),
                label: '',
              ),
            ],
          ),
          body: [
            TherapyHome(),
            TherapyBookingList(),
            TherapyCentersList(
              serviceId: serviceId.value,
              search: search.value,
            ),
          ].elementAt(currentIndex.value),
        ),
      ),
    );
  }
}
