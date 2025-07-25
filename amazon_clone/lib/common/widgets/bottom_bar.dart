import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/account/screens/account_screen.dart';
import 'package:amazon_clone/features/cart/screens/cart_screen.dart';
import 'package:amazon_clone/features/home/screens/home_screen.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;

  List<Widget> pages = [
    const HomeScreen(),
    const AccountScreen(),
    const CartScreen(),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userCartLen = context.watch<UserProvider>().user.cart.length;

    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Account',
                      index: 1,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.shopping_cart_outlined,
                      activeIcon: Icons.shopping_cart,
                      label: 'Cart',
                      index: 2,
                      badgeCount: userCartLen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    int? badgeCount,
  }) {
    final isSelected = _page == index;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () => updatePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? themeProvider.getSelectedNavBarColor(context)
                      : themeProvider.getUnselectedNavBarColor(context),
                  size: 24,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? themeProvider.getSelectedNavBarColor(context)
                    : themeProvider.getUnselectedNavBarColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
