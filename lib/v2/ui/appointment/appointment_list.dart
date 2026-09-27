import 'package:doctro_patient/model/v2/appointment_list_response.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../utils/logger.dart';
import '../widgets/appointment_card.dart';

class AppointmentList extends StatefulHookWidget {
  const AppointmentList({super.key});

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    setState(() {
      _tabController = TabController(length: 3, vsync: this);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<int> currentTab = useState(0);
    ValueNotifier<List<AppointmentListItemModal>> upcoming = useState([]);
    ValueNotifier<List<AppointmentListItemModal>> past = useState([]);
    ValueNotifier<List<AppointmentListItemModal>> pending = useState([]);

    Future<void> fetchAppointments() async {
      loading.value = true;
      try {
        AppointmentListResponse response =
            await RestClient(await RetroApi().dioData(context))
                .appointmentsList();
        if (response.success == true) {
          upcoming.value = response.data!.upcomingAppointment ?? [];
          past.value = response.data!.pastAppointment ?? [];
          pending.value = response.data!.pendingAppointment ?? [];
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      fetchAppointments();
    }, []);

    return ModalProgressHUD(
      inAsyncCall: loading.value,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: SingleChildScrollView(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(title: 'My Consultations'),
              TabBar(
                labelColor: Palette.primary,
                unselectedLabelColor: Palette.black,
                controller: _tabController,
                onTap: (index) {
                  currentTab.value = index;
                },
                labelStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: "Upcoming"),
                  Tab(text: "Pending"),
                  Tab(text: "Past"),
                ],
              ),
              SizedBox(height: 2.h),
              if ((currentTab.value == 0
                      ? upcoming
                      : currentTab.value == 1
                          ? pending
                          : past)
                  .value
                  .isEmpty)
                NoDataWidget(
                  onRetry: fetchAppointments,
                ),
              ...List.generate(
                  (currentTab.value == 0
                          ? upcoming
                          : currentTab.value == 1
                              ? pending
                              : past)
                      .value
                      .length,
                  (i) => i).map((index) {
                return AppointmentCard_v2(
                    appointment: (currentTab.value == 0
                            ? upcoming
                            : currentTab.value == 1
                                ? pending
                                : past)
                        .value[index]);
              }),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
