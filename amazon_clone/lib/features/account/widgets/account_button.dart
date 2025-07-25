import 'package:flutter/material.dart';

class AccountButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const AccountButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).cardColor, width: 1),
          borderRadius: BorderRadius.circular(50),
          color: Theme.of(context).cardColor,
        ),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(8),
            side: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
