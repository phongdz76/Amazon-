import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        filled: true,
        fillColor:
            Theme.of(context).inputDecorationTheme.fillColor ??
            Theme.of(context).cardColor.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter $hintText';
        }
        return null;
      },
      maxLines: maxLines,
    );
  }
}
