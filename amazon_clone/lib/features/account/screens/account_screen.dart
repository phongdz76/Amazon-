import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/account/widgets/account_stats.dart';
import 'package:amazon_clone/features/account/widgets/below_app_bar.dart';
import 'package:amazon_clone/features/account/widgets/live_stream_button.dart';
import 'package:amazon_clone/features/account/widgets/orders.dart';
import 'package:amazon_clone/features/account/widgets/top_buttons.dart';
import 'package:amazon_clone/common/widgets/theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.getAppBarGradient(context),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/amazon_in.png',
                      width: 120,
                      height: 45,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(Icons.notifications_outlined),
                        ),
                        const Icon(Icons.search_outlined),
                        const SizedBox(width: 10),
                        const ThemeToggleButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const BelowAppBar(),
                const SizedBox(height: 10),
                const AccountStats(),
                const SizedBox(height: 10),
                const TopButtons(),
                const SizedBox(height: 10),
                const ThemeSettingTile(),
                const SizedBox(height: 10),
                const SizedBox(height: 20),
                const Orders(),
                const SizedBox(
                  height: 80,
                ), // Extra padding để không bị che bởi bottom nav
              ],
            ),
          ),
        );
      },
    );
  }
}
