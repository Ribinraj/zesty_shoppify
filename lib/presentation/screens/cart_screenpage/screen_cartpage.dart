// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zestyvibe/core/colors.dart' show Appcolors;
import 'package:zestyvibe/domain/models/cartItem_model.dart';
import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCart());
  }

  Widget _buildLine(CartLineItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: item.imageUrl != null
            ? Image.network(item.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
            : const SizedBox(width: 56, height: 56, child: Icon(Icons.image_outlined)),
        title: Text(item.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title),
            const SizedBox(height: 6),
            Text('₹${item.price?.toStringAsFixed(2) ?? '-'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    final newQty = item.quantity - 1;
                    if (newQty <= 0) {
                      context.read<CartBloc>().add(RemoveCartLine(cartLineId: item.id));
                    } else {
                      context.read<CartBloc>().add(UpdateCartLineQty(cartLineId: item.id, quantity: newQty));
                    }
                  },
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    context.read<CartBloc>().add(UpdateCartLineQty(cartLineId: item.id, quantity: item.quantity + 1));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCheckout(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open checkout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Appcolors.kprimarycolor,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartInitial) {
            return Center(child: Text('Your cart is empty', style: TextStyle(color: Colors.grey[700])));
          }
          if (state is CartError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is CartLoaded) {
            final cart = state.cart;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 8),
                      ...cart.lines.map(_buildLine).toList(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8)
                  ]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(cart.totalAmount != null ? '₹${cart.totalAmount!.toStringAsFixed(2)}' : '-'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: cart.checkoutUrl != null ? () => _openCheckout(cart.checkoutUrl!) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Appcolors.kprimarycolor, minimumSize: const Size.fromHeight(48)),
                        child: const Text('Proceed to Checkout'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
