import 'package:flutter/material.dart';

class DealOfDay extends StatefulWidget {
  const DealOfDay({super.key});

  @override
  State<DealOfDay> createState() => _DealOfDayState();
}

class _DealOfDayState extends State<DealOfDay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10, top: 15),
          child: const Text(
            'Deal of the Day',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Image.network(
          'https://i.pinimg.com/736x/60/87/3f/60873fd33cd14bb02e128e05bccddc32.jpg',
          height: 235,
          fit: BoxFit.fitHeight,
        ),
        Container(
          padding: const EdgeInsets.only(left: 15),
          alignment: Alignment.topLeft,
          child: const Text(
            '\$1,299.00',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 15, right: 40),
          child: const Text(
            'Waifu',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network('https://i.pinimg.com/736x/60/87/3f/60873fd33cd14bb02e128e05bccddc32.jpg', 
              fit: BoxFit.fitWidth, 
              width: 100, 
              height: 100
            ),
            Image.network('https://i.pinimg.com/736x/60/87/3f/60873fd33cd14bb02e128e05bccddc32.jpg', 
              fit: BoxFit.fitWidth, 
              width: 100, 
              height: 100
            ),
            Image.network('https://i.pinimg.com/736x/60/87/3f/60873fd33cd14bb02e128e05bccddc32.jpg', 
              fit: BoxFit.fitWidth, 
              width: 100, 
              height: 100
            ),
            Image.network('https://i.pinimg.com/736x/60/87/3f/60873fd33cd14bb02e128e05bccddc32.jpg', 
              fit: BoxFit.fitWidth, 
              width: 100, 
              height: 100
            ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ).copyWith(left: 15,),
          alignment: Alignment.topLeft,
          child: const Text(
            'See all deals',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}