import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro_patient/api/base_model.dart';
import 'package:doctro_patient/api/network_api.dart';
import 'package:doctro_patient/api/retrofit_Api.dart';
import 'package:doctro_patient/api/server_error.dart';
import 'package:doctro_patient/model/v2/notification_model.dart';
import 'package:doctro_patient/theme.dart';
import 'package:doctro_patient/v2/ui/widgets/header.dart';
import 'package:doctro_patient/v2/ui/widgets/no_data.dart';
import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

/// Matches the Stitch "Notifications Inbox" screen
/// (ayureze_notifications_inbox/code.html): a chronological list of
/// cards instead of a dotted-divider list.
class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Data> userNotification = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    callApiNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamSurface,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0,
        progressIndicator: const SpinKitFadingCircle(
          color: AppColors.sagePrimary,
          size: 36,
        ),
        child: Column(
          children: [
            const Header_v2(title: 'Notifications'),
            if (userNotification.isEmpty)
              Expanded(child: Center(child: NoDataWidget()))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userNotification.length,
                  itemBuilder: (context, index) {
                    final item = userNotification[index];
                    final date = DateUtil()
                        .formattedDate(DateTime.parse(item.createdAt!));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.creamSurfaceLowest,
                        border: Border.all(color: AppColors.slateBorder),
                        borderRadius: AppRadius.roundedLg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: CachedNetworkImage(
                              height: 44,
                              width: 44,
                              fit: BoxFit.cover,
                              imageUrl: item.doctor?.fullImage ?? '',
                              placeholder: (context, url) => Container(
                                height: 44,
                                width: 44,
                                color: AppColors.sagePrimarySubtle,
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 44,
                                width: 44,
                                color: AppColors.sagePrimaryContainer,
                                child: const Icon(Icons.notifications,
                                    color: AppColors.sagePrimary, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.doctor?.name ?? 'AyurEze',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                    ),
                                    Text(date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item.message ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<BaseModel<UserNotification>> callApiNotification() async {
    UserNotification response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(await RetroApi().dioData(context))
          .notificationRequest();
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            loading = false;
            userNotification.addAll(response.data!);
          });
        }
      });
    } catch (error, stacktrace) {
      setState(() {
        loading = false;
      });
      // print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
