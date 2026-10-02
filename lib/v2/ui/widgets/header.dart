import 'package:doctro_patient/const/Palette.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Header_v2 extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Color? color;

  const Header_v2({required this.title, this.actions, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: title.isNotEmpty ? 11.h : 6.h,
      width: 100.w,
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(3.w, 5.h, 4.w, 0),
          child: Row(
            children: [
              SizedBox(
                width: 21.w,
                child: Navigator.of(context).canPop()
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 5.w,
                            color:
                                color != null ? Palette.white : Palette.black,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              if (title.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color != null ? Palette.white : Palette.black,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: 21.w,
                child: actions != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ...(actions ?? []),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
