import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/order.dart';
import '../services/order_api.dart';
import '../state/cart_model.dart';
import '../state/session_store.dart';
import '../widgets/buttons.dart';
import '../widgets/simple_topbar.dart';
import '../widgets/input_field.dart';
import '../widgets/white_panel.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel cart;
  final SessionStore session;

  const CheckoutScreen({super.key, required this.cart, required this.session});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final phone = TextEditingController();
  final address = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _placeOrder() async {
    if (widget.cart.items.isEmpty) return _msg('Cart is empty');
    if (!widget.session.isAuthed) return _msg('Please login first');

    setState(() => loading = true);
    try {
      final order = Order(items: widget.cart.items, phone: phone.text.trim(), address: address.text.trim());
      await OrderApi.createOrder(order: order, token: widget.session.token!);
      widget.cart.clear();
      if (!mounted) return;
      _msg('Order placed successfully');
      Navigator.pop(context);
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SimpleTopBar(title: 'Checkout'),
            Expanded(
              child: WhitePanel(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Delivery details', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    InputField(controller: phone, hint: 'Phone number', keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    InputField(controller: address, hint: 'Address'),
                    const Spacer(),
                    PrimaryButton(
                      text: loading ? 'Placing...' : 'Place Order',
                      onTap: () { if (!loading) _placeOrder(); },
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
