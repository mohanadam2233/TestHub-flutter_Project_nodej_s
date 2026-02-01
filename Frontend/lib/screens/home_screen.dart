// ✅ Updated HomeScreen:
// 1) Shows current user name from SessionStore (Hi <name>!)
// 2) Search bar filters products (name/subtitle/category)
// 3) Adds Unsplash-friendly headers to reduce 403 image failures
//
// Required file change: HomeScreen only
// Also add: import '../state/session_store.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../models/product.dart';
import '../state/cart_model.dart';
import '../state/favorites_model.dart';
import '../state/products_model.dart';
import '../state/session_store.dart';
import 'product_details_screen.dart';

const String offerImg =
    'https://images.unsplash.com/photo-1512152272829-e3139592d56f?auto=format&fit=crop&w=1200&q=80';

class HomeScreen extends StatefulWidget {
  final CartModel cart;
  final FavoritesModel fav;
  final ProductsModel products;
  final SessionStore session; // ✅ add

  const HomeScreen({
    super.key,
    required this.cart,
    required this.fav,
    required this.products,
    required this.session,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();

    if (widget.products.items.isEmpty && !widget.products.loading) {
      widget.products.load();
    }

    _searchCtrl.addListener(() {
      setState(() => _q = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> items) {
    if (_q.isEmpty) return items;
    return items.where((p) {
      final name = p.name.toLowerCase();
      final sub = p.subtitle.toLowerCase();
      final cat = p.category.toLowerCase();
      return name.contains(_q) || sub.contains(_q) || cat.contains(_q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: widget.session,
                    builder: (_, __) {
                      final name = (widget.session.username?.trim().isNotEmpty == true)
                          ? widget.session.username!.trim()
                          : 'TasteHub User';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi $name.!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What would you like to eat?',
                            style: TextStyle(
                              color: AppColors.textMute,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  _CircleSoftIcon(icon: Icons.search_rounded, onTap: () {}),
                  const SizedBox(width: 10),
                  _CircleSoftIcon(icon: Icons.notifications_none_rounded, onTap: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl, // ✅ search works now
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search_rounded),
                    hintText: 'Search for food, you want',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([widget.products, widget.fav]),
                builder: (_, __) {
                  if (widget.products.loading && widget.products.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (widget.products.error != null && widget.products.items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.products.error!.replaceFirst('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMute,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }

                  final products = _filter(widget.products.items);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _OfferCard(
                        title: 'Enjoy The\nSpecial offer\nUp to 50%',
                        imageUrl: offerImg,
                        dateText: '2 - 30 April 2026',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'popular items',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          if (_q.isNotEmpty)
                            Text(
                              '${products.length} found',
                              style: const TextStyle(
                                color: AppColors.textMute,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                          mainAxisExtent: 220,
                        ),
                        itemBuilder: (_, i) {
                          final p = products[i];
                          return _ProductTile(
                            product: p,
                            isFav: widget.fav.isFav(p.id),
                            onFav: () => widget.fav.toggle(p.id),
                            onAdd: () => widget.cart.add(p),
                            onOpen: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: p,
                                  cart: widget.cart,
                                  fav: widget.fav,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleSoftIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleSoftIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
        child: Icon(icon, color: AppColors.brown),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String dateText;
  final VoidCallback onTap;

  const _OfferCard({
    required this.title,
    required this.imageUrl,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(color: AppColors.brown, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
              child: SizedBox(
                width: 140,
                height: 150,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  httpHeaders: const {'User-Agent': 'Mozilla/5.0'}, // ✅ helps 403
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.brownDark),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.brownDark,
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onAdd;
  final VoidCallback onOpen;

  const _ProductTile({
    required this.product,
    required this.isFav,
    required this.onFav,
    required this.onAdd,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 12))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1.35,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      httpHeaders: const {'User-Agent': 'Mozilla/5.0'}, // ✅ helps 403
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: const Color(0xFFEDEAE3)),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFEDEAE3),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: onFav,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(999)),
                      child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.orange, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              product.subtitle.isEmpty ? product.category : product.subtitle,
              style: const TextStyle(color: AppColors.textMute, fontWeight: FontWeight.w700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const Spacer(),
                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.shopping_cart_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
