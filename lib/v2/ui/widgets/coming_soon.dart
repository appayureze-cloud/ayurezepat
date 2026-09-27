import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HorizontalComingSoonRibbon extends StatelessWidget {
  final double height;
  final double width;

  const HorizontalComingSoonRibbon({
    required this.height,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: -5.w,
      child: Image.asset(
        'assets/images/coming_soon.png',
        height: height,
        width: width,
      ),
    );
  }
}
