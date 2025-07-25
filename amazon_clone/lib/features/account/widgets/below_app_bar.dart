import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BelowAppBar extends StatelessWidget {
  const BelowAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: themeProvider.getAppBarGradient(context),
      ),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!)
                  : null,
              child: user.avatar == null
                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          // Greeting text
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'Hello, ',
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                children: [
                  TextSpan(
                    text: user.name,
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
