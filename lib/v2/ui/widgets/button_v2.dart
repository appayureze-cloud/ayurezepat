import 'package:flutter/material.dart';

import '../../../theme.dart';

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
        width: width ?? MediaQuery.of(context).size.width * 0.85,
        child: ElevatedButton(
          style: buttonColor != null
              ? ElevatedButton.styleFrom(backgroundColor: buttonColor)
              : null,
          onPressed: onPressed,
          child: Text(
            label,
            style: fontSize != null ? TextStyle(fontSize: fontSize) : null,
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
      width: width ?? MediaQuery.of(context).size.width * 0.85,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? AppColors.sagePrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: fontSize != null ? TextStyle(fontSize: fontSize) : null,
        ),
      ),
    );
  }
}
