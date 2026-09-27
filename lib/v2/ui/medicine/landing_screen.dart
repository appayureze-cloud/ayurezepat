import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/v2/ui/medicine/medicine_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import 'medicine_list.dart';
import 'order_list.dart';

class MedicineLandingPage extends HookWidget {
  final int? index;

  MedicineLandingPage({this.index, super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> currentIndex = useState(index ?? 0);
    ValueNotifier<int?> category = useState(null);
    ValueNotifier<bool> loading = useState(true);

    useEffect(() {
      Future.microtask(() {
        List? arguments = ModalRoute.of(context)?.settings.arguments as List?;
        if (arguments != null && arguments.isNotEmpty) {
          if (arguments.first is int) currentIndex.value = arguments.first;

          if (arguments.length > 1 && arguments[1] is int)
            category.value = arguments[1];
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
                  Icons.search,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.list,
                ),
                label: '',
              ),
            ],
          ),
          body: [
            MedicineHome(),
            MedicineList_v2(
              category: category.value,
            ),
            OrderList_v2(),
          ].elementAt(currentIndex.value),
        ),
      ),
    );
  }
}
