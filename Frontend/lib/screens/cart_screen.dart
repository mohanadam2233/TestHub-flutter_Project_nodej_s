import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../state/cart_model.dart';
import '../state/session_store.dart';
import '../widgets/simple_topbar.dart';
import '../widgets/white_panel.dart';
import '../widgets/buttons.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final CartModel cart;
  final SessionStore session;
  const CartScreen({super.key, required this.cart, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SimpleTopBar(title: 'Cart'),
            Expanded(
              child: WhitePanel(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: AnimatedBuilder(
                  animation: cart,
                  builder: (_, __) {
                    if (cart.items.isEmpty) {
                      return const Center(
                        child: Text('Cart is empty', style: TextStyle(color: AppColors.textMute, fontWeight: FontWeight.w700)),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final item = cart.items[i];
                              return Container(
                                decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: CachedNetworkImage(
                                          imageUrl: item.product.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(color: const Color(0xFFE0DCD3)),
                                          errorWidget: (_, __, ___) => Container(color: const Color(0xFFE0DCD3), child: const Icon(Icons.image_not_supported)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(item.product.subtitle, style: const TextStyle(color: AppColors.textMute, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Text('\$${item.product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                                    const SizedBox(width: 10),
                                    Row(
                                      children: [
                                        _QtyBtn(icon: Icons.remove_rounded, onTap: () => cart.dec(item.product.id)),
                                        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w900))),
                                        _QtyBtn(icon: Icons.add_rounded, onTap: () => cart.inc(item.product.id)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PriceLine(label: 'Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
                        _PriceLine(label: 'Delivery charge:', value: '\$${cart.delivery.toStringAsFixed(2)}'),
                        _PriceLine(label: 'Tax:', value: '\$${cart.tax.toStringAsFixed(2)}'),
                        const Divider(height: 20),
                        _PriceLine(label: 'Total', value: '\$${cart.total.toStringAsFixed(2)}', bold: true),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          text: 'checkout',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart, session: session))),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceLine({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w800, color: bold ? Colors.black : AppColors.textMute);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
