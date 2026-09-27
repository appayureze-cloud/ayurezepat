import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../api/retrofit_Api.dart';
import '../../../const/Palette.dart';
import '../../../const/prefConstatnt.dart';
import '../../../const/preference.dart';
import '../../../v2/ui/medicine/cart.dart';
import '../../../v2/ui/widgets/button_v2.dart';
import '../../../v2/ui/widgets/header.dart';
import '../../../v2/utils/logger.dart';
import '../data/smart_order_service.dart';
import '../domain/entities/smart_order_draft.dart';
import 'smart_order_reprompt_scheduler.dart';

class SmartOrderDraftScreen extends HookWidget {
  final String draftId;

  const SmartOrderDraftScreen({required this.draftId, super.key});

  @override
  Widget build(BuildContext context) {
    final draft = useState<SmartOrderDraft?>(null);
    final loading = useState(true);
    final busy = useState(false);

    Future<void> load() async {
      loading.value = true;
      try {
        final dio = await RetroApi().dioData(context);
        draft.value = await SmartOrderService.withDio(dio).getDraft(draftId);
      } catch (e) {
        logger.e('Failed to load smart order draft: $e');
        Fluttertoast.showToast(msg: 'Could not load this order');
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, const []);

    Future<void> buy() async {
      busy.value = true;
      try {
        final dio = await RetroApi().dioData(context);
        await SmartOrderService.withDio(dio).markBought(draftId);
        await cancelSmartOrderReprompt(draftId);
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Cart()),
        );
      } catch (e) {
        logger.e('Failed to buy smart order draft: $e');
        Fluttertoast.showToast(msg: 'Could not add these to your cart');
      } finally {
        busy.value = false;
      }
    }

    Future<void> ignore() async {
      busy.value = true;
      try {
        final dio = await RetroApi().dioData(context);
        await SmartOrderService.withDio(dio).markIgnored(draftId);
        await scheduleSmartOrderReprompt(draftId);
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        logger.e('Failed to ignore smart order draft: $e');
      } finally {
        busy.value = false;
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Header_v2(title: 'Prescribed medicines'),
          if (loading.value)
            Expanded(
              child: Center(
                child: SpinKitFadingCircle(color: Palette.primary, size: 6.h),
              ),
            )
          else if (draft.value == null)
            const Expanded(child: Center(child: Text('Order not found')))
          else
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your doctor prescribed these. Buy them now or decide later.',
                      style:
                          TextStyle(fontSize: 13.sp, color: Palette.dark_grey1),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final item in draft.value!.items)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0.5.h),
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Palette.lightGrey),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.name} x${item.quantity}',
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                  ),
                                  Text(
                                    '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${item.price * item.quantity}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                        Text(
                          '${SharedPreferenceHelper.getString(Preferences.currency_symbol)} ${draft.value!.total}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonV2(
                            label: 'Not now',
                            buttonColor: Palette.grey,
                            onPressed: busy.value ? null : ignore,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ButtonV2(
                            label: 'Buy now',
                            onPressed: busy.value ? null : buy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
