import 'package:doctro_patient/model/v2/app_section_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../const/Palette.dart';
import '../../utils/logger.dart';

class HelpCard extends HookWidget {
  final AppSection section;

  const HelpCard({
    required this.section,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void _handleAction() async {
      switch (section.actionType) {
        case 'phone':
          launchUrl(Uri.parse('tel:${section.actionValue}'));
          break;
        case 'whatsapp':
          final phone =
              section.actionValue?.replaceAll('+', '').replaceAll(' ', '');
          final uri = Uri.parse('https://wa.me/$phone');
          if (await canLaunchUrl(uri)) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            logger.e('Could not open WhatsApp');
          }
          break;
        case 'mail':
          final email = section.actionValue;
          final mailUri = Uri(
            scheme: 'mailto',
            path: email,
            query: Uri.encodeFull('subject=Support Request&body=Hi Team,'),
          );
          if (await canLaunchUrl(mailUri)) {
            launchUrl(mailUri);
          } else {
            logger.e('Could not open email app');
          }
          break;
        case 'web':
          launchUrl(Uri.parse(section.actionValue ?? ''));
          break;
        case 'navigate':
          Navigator.pushNamed(context, section.actionValue ?? '');
          break;
        default:
          logger.e('No action defined');
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.h),
      ),
      margin: EdgeInsets.only(bottom: 1.h),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.5.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 75.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${section.title}',
                    style: TextStyle(
                      color: Palette.black,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${section.subtitle}',
                    style: TextStyle(
                      color: Palette.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: () {
                _handleAction();
              },
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.grey.withValues(alpha: 0.1),
                ),
                child: Icon(
                  section.actionType == 'phone'
                      ? Icons.phone_outlined
                      : section.actionType == 'whatsapp'
                          ? Icons.messenger_outline
                          : section.actionType == 'mail'
                              ? Icons.mail_outline
                              : section.actionType == 'web'
                                  ? Icons.web_outlined
                                  : section.actionType == 'navigate'
                                      ? Icons.skip_next_sharp
                                      : Icons.info_outline,
                  size: 16.sp,
                  color: Palette.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
