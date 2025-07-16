import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap, 
    this.color, 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50), // Chiều rộng đầy đủ, chiều cao 50
        backgroundColor: color,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == null ? Colors.black : Colors.white, // Màu chữ tùy thuộc vào màu nền
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}