import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/app_colors.dart';
import '../state/cart_model.dart';
import '../state/favorites_model.dart';
import '../state/products_model.dart';
import '../state/session_store.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  final SessionStore session;
  final ProductsModel products;

  const AppShell({super.key, required this.session, required this.products});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final cart = CartModel();
  final fav = FavoritesModel();

  @override
  void initState() {
    super.initState();
    if (widget.products.items.isEmpty && !widget.products.loading) {
      widget.products.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(cart: cart, fav: fav, products: widget.products, session: widget.session),
      CartScreen(cart: cart, session: widget.session),
      FavoritesScreen(cart: cart, fav: fav, products: widget.products),
      ProfileScreen(cart: cart, fav: fav, session: widget.session),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([cart, fav, widget.products, widget.session]),
      builder: (_, __) {
        return Scaffold(
          body: pages[index],
          bottomNavigationBar: _BottomBar(
            currentIndex: index,
            cartCount: cart.totalQty,
            favCount: fav.ids.length,
            onTap: (i) => setState(() => index = i),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final int favCount;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.currentIndex, required this.cartCount, required this.favCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: FontAwesomeIcons.house, isActive: currentIndex == 0, onTap: () => onTap(0)),
          _BadgeWrap(count: cartCount, child: _NavIcon(icon: FontAwesomeIcons.cartShopping, isActive: currentIndex == 1, onTap: () => onTap(1))),
          _BadgeWrap(count: favCount, child: _NavIcon(icon: FontAwesomeIcons.heart, isActive: currentIndex == 2, onTap: () => onTap(2))),
          _NavIcon(icon: FontAwesomeIcons.user, isActive: currentIndex == 3, onTap: () => onTap(3)),
        ],
      ),
    );
  }
}

class _BadgeWrap extends StatelessWidget {
  final int count;
  final Widget child;
  const _BadgeWrap({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(999)),
              child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isActive ? AppColors.brownDark : Colors.transparent, borderRadius: BorderRadius.circular(14)),
        child: FaIcon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
