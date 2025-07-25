import 'package:amazon_clone/features/account/services/account_services.dart';
import 'package:amazon_clone/models/order.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountStats extends StatefulWidget {
  const AccountStats({super.key});

  @override
  State<AccountStats> createState() => _AccountStatsState();
}

class _AccountStatsState extends State<AccountStats> {
  List<Order>? orders;
  final AccountServices accountServices = AccountServices();
  int ordersCount = 0;
  int wishlistCount = 0;
  int reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
  }

  void fetchUserStats() async {
    // Get orders count
    orders = await accountServices.fetchMyOrders(context: context);

    // Get user data
    final user = Provider.of<UserProvider>(context, listen: false).user;

    setState(() {
      ordersCount = orders?.length ?? 0;
      wishlistCount = user.wishlist?.length ?? 0;
      // For reviews, we can calculate from orders that have been delivered
      reviewsCount = orders?.where((order) => order.status == 3).length ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            count: ordersCount.toString(),
            color: Colors.blue,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          _buildStatItem(
            icon: Icons.favorite_outline,
            title: 'Wishlist',
            count: wishlistCount.toString(),
            color: Colors.red,
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          _buildStatItem(
            icon: Icons.star_outline,
            title: 'Reviews',
            count: reviewsCount.toString(),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
