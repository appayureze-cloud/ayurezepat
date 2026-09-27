import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/therapy_booking_list.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../api/network_api.dart';
import '../../../api/retrofit_Api.dart';
import '../../utils/logger.dart';
import '../widgets/header.dart';
import '../widgets/therapy_booking_card.dart';

class TherapyBookingList extends StatefulHookWidget {
  const TherapyBookingList({super.key});

  @override
  State<TherapyBookingList> createState() => _TherapyBookingListState();
}

class _TherapyBookingListState extends State<TherapyBookingList>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> currentTab = useState(0);

    ValueNotifier<bool> loading = useState(true);

    ValueNotifier<List<TherapyBooking>> upcoming = useState([]);
    ValueNotifier<List<TherapyBooking>> completed = useState([]);
    ValueNotifier<List<TherapyBooking>> cancelled = useState([]);

    Future<void> fetchTherapyBookings() async {
      loading.value = true;
      try {
        TherapyBookingListResponse response =
            await RestClient(await RetroApi().dioData(context))
                .therapyBookingsList();
        if (response.success == true) {
          upcoming.value = response.data!.upcoming ?? [];
          completed.value = response.data!.completed ?? [];
          cancelled.value = response.data!.cancelled ?? [];
          loading.value = false;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    useEffect(() {
      fetchTherapyBookings();
    }, []);

    useEffect(() {
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          currentTab.value = _tabController.index;
          // print("Tab changed to: ${_tabController.index}");
        }
      });
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
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(title: 'Therapy Bookings'),
              TabBar(
                controller: _tabController,
                labelStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                  Tab(text: "Cancelled"),
                ],
              ),
              SizedBox(height: 2.h),
              ...List.generate(
                  (currentTab.value == 0
                          ? upcoming
                          : currentTab.value == 1
                              ? completed
                              : cancelled)
                      .value
                      .length,
                  (i) => i).map((index) {
                return TherapyBookingCard(
                    bgColor: currentTab.value == 1
                        ? Palette.green_bg
                        : currentTab.value == 2
                            ? Palette.red_bg
                            : null,
                    booking: (currentTab.value == 0
                            ? upcoming
                            : currentTab.value == 1
                                ? completed
                                : cancelled)
                        .value[index]);
              }),
              if ((currentTab.value == 0
                      ? upcoming
                      : currentTab.value == 1
                          ? completed
                          : cancelled)
                  .value
                  .isEmpty)
                NoDataWidget(
                  onRetry: fetchTherapyBookings,
                ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
