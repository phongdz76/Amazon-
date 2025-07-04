import 'package:flutter/material.dart';

class SingelProduct extends StatelessWidget {
  final String image;
  const SingelProduct({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DecoratedBox(
        decoration:  BoxDecoration(
          border: Border.all(
            color: Colors.black12,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(10),
          child: Image.network(
            image, 
            fit: BoxFit.fitHeight,
            width: 180,
          ),
        ),
      ),
    );
  }
}