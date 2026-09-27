import 'package:doctro_patient/v2/utils/helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sizer/sizer.dart';

import '../../../const/Palette.dart';

class CustomTextField extends HookWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  const CustomTextField({
    required this.controller,
    required this.hint,
    this.textInputType,
    this.validator,
    this.inputFormatters,
    this.isPassword = false,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.focusNode,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> _isHidden = useState(isPassword ? true : false);
    return Center(
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        readOnly: readOnly,
        maxLength: maxLength,
        textAlignVertical: TextAlignVertical.center,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        focusNode: focusNode,
        minLines: minLines,
        maxLines: maxLines,
        onTap: onTap,
        style: TextStyle(
          fontSize: 16.sp,
          color: Palette.dark_blue,
        ),
        decoration: InputDecoration(
          constraints: BoxConstraints(maxWidth: 90.w, minWidth: 90.w),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: Palette.dark_grey,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isHidden.value ? Icons.visibility : Icons.visibility_off,
                    color: Palette.grey,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _isHidden.value = !_isHidden.value;
                  },
                )
              : null,
        ),
        obscureText: _isHidden.value,
        validator: validator,
      ),
    );
  }
}

class CustomDropdown<T> extends HookWidget {
  final String hint;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final List<T> items;
  final T? value;
  final String? labelKey;

  const CustomDropdown({
    required this.hint,
    required this.onChanged,
    required this.validator,
    required this.items,
    required this.value,
    this.labelKey,
    super.key,
  });

  String _getLabel(T item) {
    if (labelKey == null) return item.toString();

    try {
      final dynamic json = (item as dynamic).toJson();
      final label = json[labelKey];
      return label?.toString() ?? '';
    } catch (e) {
      return item.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w,
      child: DropdownButtonFormField2<T>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 16.sp,
            color: Palette.dark_grey,
          ),
        ),
        style: TextStyle(
          fontSize: 16.sp,
          color: Palette.dark_blue,
        ),
        alignment: Alignment.centerLeft,
        isExpanded: true,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: BorderSide(color: Palette.primary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: BorderSide(color: Palette.grey, width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: BorderSide(color: Palette.grey, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: BorderSide(color: Palette.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.w),
            borderSide: BorderSide(color: Palette.red, width: 1),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          height: 6.h,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                3.w), // 👈 Border radius of the button itself
          ),
        ),
        dropdownStyleData: DropdownStyleData(
            maxHeight: 40.h,
            // width: 90.w,
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.w)),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((T item) {
            return Text(
              _getLabel(item).toSentenceCase(),
              overflow: TextOverflow.ellipsis,
              // 👈 show ellipsis after selection
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette.dark_blue,
              ),
            );
          }).toList();
        },
        items: items.map(
          (T item) {
            return DropdownMenuItem<T>(
              child: new Text(
                _getLabel(item).toSentenceCase(),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Palette.dark_blue,
                ),
              ),
              value: item,
            );
          },
        ).toList(),
      ),
    );
  }
}
