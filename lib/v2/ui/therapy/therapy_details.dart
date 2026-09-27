import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';
import '../widgets/header.dart';

class TherapyDetails extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header_v2(title: 'Acupuncture'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Column(
                children: [
                  // TherapyCard(
                  //   title: 'Acupuncture',
                  //   subTitle: 'Balance energy and relieve pain',
                  //   icon: '🌿',
                  //   showBooking: false,
                  // ),
                  SizedBox(height: 1.h),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (text) {},
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Palette.white,
                      constraints: BoxConstraints(
                        maxHeight: 5.5.h,
                        maxWidth: 95.w,
                      ),
                      hintText: 'Search Therapy Centers',
                      hintStyle: TextStyle(
                        fontSize: 15.sp,
                        color: Palette.grey,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search_outlined,
                          size: 17.sp,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // ...List.generate(5, (i) => i).map((index) {
                  //   return TherapyCenterCard();
                  // }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
