import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../shared/image/text.dart';

class FormTextInput extends StatelessWidget {
  const FormTextInput({
    Key? key,
    required this.label,
    this.mask,
    this.filter,
    this.onChange,
    this.keyboardType,
    this.controller,
    this.enabled = true,
    this.placeholder,
    this.labelStyle,
    this.regex,
    this.onTap,
    this.capitalization,
    this.onSubmitted,
    this.textInputAction,
  }) : super(key: key);

  final String label;
  final String? mask;
  final Map<String, RegExp>? filter;
  final Function? onChange;
  final Function? onTap;
  final TextInputType? keyboardType;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final bool enabled;
  final String? placeholder;
  final String? regex;
  final TextCapitalization? capitalization;
  final Function? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle == labelStyle ? labelStyle : smallText,
          alignLabelWithHint: true,
          hintText: placeholder,
        ),
        style: baseBlackText,
        textCapitalization: capitalization ?? TextCapitalization.none,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: [
          MaskTextInputFormatter(
            mask: mask,
            filter: filter,
          ),
          if (regex != null) FilteringTextInputFormatter.allow(RegExp(regex!)),
        ],
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        onChanged: (value) {
          if (onChange != null) {
            onChange!(value);
          }
        },
        onSubmitted: (value) {
          if (onSubmitted != null) {
            onSubmitted!(value);
          }
        },
      ),
    );
  }
}
