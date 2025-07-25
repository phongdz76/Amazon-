import 'package:amazon_clone/features/account/services/wishlist_services.dart';
import 'package:amazon_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistButton extends StatefulWidget {
  final String productId;
  final double size;

  const WishlistButton({super.key, required this.productId, this.size = 24.0});

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  final WishlistServices wishlistServices = WishlistServices();
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    checkWishlistStatus();
  }

  void checkWishlistStatus() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    setState(() {
      isInWishlist = user.wishlist?.contains(widget.productId) ?? false;
    });
  }

  void toggleWishlist() {
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
    return GestureDetector(
      onTap: toggleWishlist,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          color: isInWishlist ? Colors.red : Colors.grey,
          size: widget.size,
        ),
      ),
    );
  }
}
