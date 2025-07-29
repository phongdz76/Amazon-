import 'package:amazon_clone/features/account/services/account_services.dart';
import 'package:amazon_clone/features/account/widgets/account_button.dart';
import 'package:amazon_clone/features/livesream/UserLiveStreamPage.dart';
import 'package:flutter/material.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AccountButton(text: 'Your Orders', onTap: () {}),
            AccountButton(
              text: 'Profile',
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            AccountButton(
              text: 'Log Out',
              onTap: () => AccountServices().logOut(context),
            ),
            AccountButton(
              text: 'Wish List',
              onTap: () {
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            AccountButton(
              text: 'Watch Live',
              onTap: () {
                // Navigate to User Live Stream Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserLiveStreamPage(),
                  ),
                );
              },
            ),
            AccountButton(text: 'Support', onTap: () {}),
          ],
        ),
      ],
    );
  }
}
