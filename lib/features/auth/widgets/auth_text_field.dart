import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// Label + field + pesan error di bawahnya untuk form login.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.loginFieldRadius),
      borderSide: BorderSide(
        color: color,
        width: AppDimensions.loginFieldBorderWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.authLabel),
        const SizedBox(height: AppDimensions.loginLabelToField),
        SizedBox(
          height: AppDimensions.loginFieldHeight,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            style: AppTextStyles.authFieldInput,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.loginFieldHorizontalPadding,
              ),
              border: _border(AppColors.formBorder),
              enabledBorder: _border(AppColors.formBorder),
              focusedBorder: _border(AppColors.primary),
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: AppDimensions.loginFieldErrorSpacing),
          Text(errorText!, style: AppTextStyles.authFieldError),
        ],
      ],
    );
  }
}
