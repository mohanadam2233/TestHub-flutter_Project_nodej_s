import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/product.dart';
import '../state/cart_model.dart';
import '../state/favorites_model.dart';
import '../widgets/buttons.dart';
import '../widgets/white_panel.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final CartModel cart;
  final FavoritesModel fav;

  const ProductDetailsScreen({super.key, required this.product, required this.cart, required this.fav});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.brown,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text('TasteHub', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 8,
                    child: AnimatedBuilder(
                      animation: fav,
                      builder: (_, __) {
                        final isFav = fav.isFav(product.id);
                        return IconButton(
                          onPressed: () => fav.toggle(product.id),
                          icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.orange),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 150,
                          width: 280,
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.brownDark),
                            errorWidget: (_, __, ___) => Container(color: AppColors.brownDark, child: const Icon(Icons.image_not_supported, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: WhitePanel(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.orange.withOpacity(0.95)),
                        const SizedBox(width: 6),
                        Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 12),
                        Text(product.category, style: const TextStyle(color: AppColors.textMute, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(product.description, style: const TextStyle(color: AppColors.textMute, fontWeight: FontWeight.w600, height: 1.45)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Buy Now',
                            onTap: () {
                              cart.add(product);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlineButtonX(
                            text: 'Add to cart',
                            onTap: () {
                              cart.add(product);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
