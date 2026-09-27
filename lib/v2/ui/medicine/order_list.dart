import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/const/Palette.dart';
import 'package:doctro_patient/model/v2/medicine/order_list_response.dart';
import 'package:doctro_patient/v2/ui/medicine/order_details.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';

import '../../../model/v2/doctor_list_response.dart' show Meta;
import '../../utils/helper.dart';
import '../widgets/header.dart';
import '../widgets/order_card.dart';

class OrderList_v2 extends StatefulHookWidget {
  const OrderList_v2({super.key});

  @override
  State<OrderList_v2> createState() => _OrderList_v2State();
}

class _OrderList_v2State extends State<OrderList_v2>
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
    // upcoming: pending, authorized, unfulfilled, partial, paid-but-not-fulfilled.
    // completed: fulfilled.
    // cancelled: refunded, explicitly cancelled.

    ValueNotifier<bool> loading = useState(true);
    ValueNotifier<int> currentTab = useState(0);
    ValueNotifier<int> currentPage = useState(1);
    ValueNotifier<List<OrderListItem>> data = useState([]);
    final ValueNotifier<Meta?> meta = useState(null);
    final debouncer = useMemoized(() => Debouncer(milliseconds: 500));

    final scrollController = useScrollController();

    Future<void> fetchOrders({required bool refresh}) async {
      loading.value = true;
      try {
        OrderListResponse response =
            await RestClient(await RetroApi().dioData(context)).ordersList(
                currentTab.value == 0
                    ? 'upcoming'
                    : currentTab.value == 1
                        ? 'completed'
                        : 'cancelled',
                currentPage.value,
                10);
        if (response.success == true) {
          if (response.data?.isNotEmpty ?? false) {
            if (refresh)
              data.value = response.data ?? [];
            else
              data.value = [...data.value, ...(response.data ?? [])];
          }
          loading.value = false;
          meta.value = response.meta;
        }
      } catch (error, stacktrace) {
        loading.value = false;
        logger.e("Exception occur: $error stackTrace: $stacktrace");
      }
    }

    Future<void> loadMore() async {
      if ((meta.value?.totalPages ?? 0) <= currentPage.value) return;
      loading.value = true;
      currentPage.value++;
      await fetchOrders(refresh: false);
      loading.value = false;
    }

    useEffect(() {
      () async {
        loading.value = true;
        await Future.wait([fetchOrders(refresh: true)]);
        loading.value = false;
      }();
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100) {
          debouncer.run(() {
            loadMore();
          }); // Load more when near bottom
        }
      });

      return () {
        scrollController.dispose();
      };
    }, []);

    return ModalProgressHUD(
      inAsyncCall: loading.value,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.primary,
        size: 3.h,
      ),
      child: DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header_v2(title: 'My Orders'),
              TabBar(
                onTap: (index) {
                  currentTab.value = index;
                  fetchOrders(refresh: true);
                },
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
              data.value.isEmpty
                  ? NoDataWidget(
                      onRetry: () {
                        data.value = [];
                        fetchOrders(refresh: true);
                      },
                    )
                  : Column(
                      children: [
                        for (OrderListItem order in data.value)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetails(
                                        id: order.id!,
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchOrders(refresh: true);
                                  });
                                },
                                child: OrderCard(order: order)),
                          ),
                      ],
                    ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
