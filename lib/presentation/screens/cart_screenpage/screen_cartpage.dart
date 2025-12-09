import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart' show Appcolors;
import 'package:zestyvibe/data/models/cartItem_model.dart';

import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';
import 'package:zestyvibe/presentation/screens/screen_checkout/screen_checkout.dart';
import 'package:zestyvibe/widgets/custom_appbar.dart';

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
            ? Image.network(
                item.imageUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
            : const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.image_outlined),
              ),
        title: Text(
          item.productTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                      context.read<CartBloc>().add(
                        RemoveCartLine(cartLineId: item.id),
                      );
                    } else {
                      context.read<CartBloc>().add(
                        UpdateCartLineQty(
                          cartLineId: item.id,
                          quantity: newQty,
                        ),
                      );
                    }
                  },
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    context.read<CartBloc>().add(
                      UpdateCartLineQty(
                        cartLineId: item.id,
                        quantity: item.quantity + 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToCheckout(String checkoutUrl) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          checkoutUrl: checkoutUrl,
          onCheckoutComplete: () {
            // Clear cart after successful checkout
            context.read<CartBloc>().add(ClearCart());
          },
        ),
      ),
    );

    // If checkout was successful, reload cart
    if (result == true && mounted) {
      context.read<CartBloc>().add(LoadCart());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cart'),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Appcolors.kprimarycolor),
            );
          }
          if (state is CartInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.grey[700], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }
          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(LoadCart()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Items',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${cart.totalQuantity} item${cart.totalQuantity > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            cart.totalAmount != null
                                ? '₹${cart.totalAmount!.toStringAsFixed(2)}'
                                : '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: cart.checkoutUrl != null
                            ? () => _proceedToCheckout(cart.checkoutUrl!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolors.kprimarycolor,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
