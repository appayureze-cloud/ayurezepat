import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class ButtonV2 extends StatelessWidget {
  final Color? buttonColor;
  final String label;
  final double? width;
  final double? fontSize;
  final void Function()? onPressed;

  const ButtonV2(
      {required this.label,
      this.buttonColor,
      this.onPressed,
      this.width,
      this.fontSize,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? 85.w,
        child: FilledButton(
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(buttonColor ?? Palette.primary),
          ),
          onPressed: onPressed,
          child: Text(
            '$label',
            style: TextStyle(
              color: Palette.white,
              fontSize: fontSize ?? 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final Color? buttonColor;
  final String label;
  final double? width;
  final double? fontSize;
  final void Function()? onPressed;

  const SmallButton(
      {required this.label,
      this.buttonColor,
      this.onPressed,
      this.width,
      this.fontSize,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 85.w,
      child: FilledButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          backgroundColor:
              WidgetStateProperty.all(buttonColor ?? Palette.primary),
        ),
        onPressed: onPressed,
        child: Text(
          '$label',
          style: TextStyle(
            color: Palette.white,
            fontSize: fontSize ?? 16.sp,
          ),
        ),
      ),
    );
  }
}
