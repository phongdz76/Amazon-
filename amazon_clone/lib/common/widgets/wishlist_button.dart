import 'package:amazon_clone/features/account/services/wishlist_services.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistButton extends StatefulWidget {
  final String productId;
  final double size;
  final Color? backgroundColor;

  const WishlistButton({
    super.key,
    required this.productId,
    this.size = 24,
    this.backgroundColor,
  });

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  final WishlistServices wishlistServices = WishlistServices();
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  void _checkWishlistStatus() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.wishlist != null) {
      setState(() {
        isInWishlist = user.wishlist!.contains(widget.productId);
      });
    }
  }

  void _toggleWishlist() {
    if (isInWishlist) {
      wishlistServices.removeFromWishlist(
        context: context,
        productId: widget.productId,
      );
    } else {
      wishlistServices.addToWishlist(
        context: context,
        productId: widget.productId,
      );
    }
    setState(() {
      isInWishlist = !isInWishlist;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Update wishlist status when user data changes
        final user = userProvider.user;
        final currentStatus =
            user.wishlist?.contains(widget.productId) ?? false;
        if (currentStatus != isInWishlist) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                isInWishlist = currentStatus;
              });
            }
          });
        }

        return GestureDetector(
          onTap: _toggleWishlist,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey[600],
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
