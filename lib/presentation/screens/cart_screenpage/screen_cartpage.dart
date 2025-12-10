// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:zestyvibe/core/colors.dart' show Appcolors;
// import 'package:zestyvibe/data/models/cartItem_model.dart';

// import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';
// import 'package:zestyvibe/presentation/screens/screen_checkout/screen_checkout.dart';
// import 'package:zestyvibe/widgets/custom_appbar.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<CartBloc>().add(LoadCart());
//   }

//   Widget _buildLine(CartLineItem item) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ListTile(
//         leading: item.imageUrl != null
//             ? Image.network(
//                 item.imageUrl!,
//                 width: 56,
//                 height: 56,
//                 fit: BoxFit.cover,
//               )
//             : const SizedBox(
//                 width: 56,
//                 height: 56,
//                 child: Icon(Icons.image_outlined),
//               ),
//         title: Text(
//           item.productTitle,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(item.title),
//             const SizedBox(height: 6),
//             Text('₹${item.price?.toStringAsFixed(2) ?? '-'}'),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle_outline),
//                   onPressed: () {
//                     final newQty = item.quantity - 1;
//                     if (newQty <= 0) {
//                       context.read<CartBloc>().add(
//                         RemoveCartLine(cartLineId: item.id),
//                       );
//                     } else {
//                       context.read<CartBloc>().add(
//                         UpdateCartLineQty(
//                           cartLineId: item.id,
//                           quantity: newQty,
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 Text('${item.quantity}'),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline),
//                   onPressed: () {
//                     context.read<CartBloc>().add(
//                       UpdateCartLineQty(
//                         cartLineId: item.id,
//                         quantity: item.quantity + 1,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _proceedToCheckout(String checkoutUrl) async {
//     final result = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CheckoutScreen(
//           checkoutUrl: checkoutUrl,
//           onCheckoutComplete: () {
//             // Clear cart after successful checkout
//             context.read<CartBloc>().add(ClearCart());
//           },
//         ),
//       ),
//     );

//     // If checkout was successful, reload cart
//     if (result == true && mounted) {
//       context.read<CartBloc>().add(LoadCart());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: 'Cart'),
//       body: BlocBuilder<CartBloc, CartState>(
//         builder: (context, state) {
//           if (state is CartLoading) {
//             return const Center(
//               child: CircularProgressIndicator(color: Appcolors.kprimarycolor),
//             );
//           }
//           if (state is CartInitial) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_cart_outlined,
//                     size: 80,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Your cart is empty',
//                     style: TextStyle(color: Colors.grey[700], fontSize: 18),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('Continue Shopping'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           if (state is CartError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
//                   const SizedBox(height: 16),
//                   Text('Error: ${state.message}'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => context.read<CartBloc>().add(LoadCart()),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           if (state is CartLoaded) {
//             final cart = state.cart;
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       const SizedBox(height: 8),
//                       ...cart.lines.map(_buildLine).toList(),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 8),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Total Items',
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                           Text(
//                             '${cart.totalQuantity} item${cart.totalQuantity > 1 ? 's' : ''}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'Subtotal',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                           ),
//                           Text(
//                             cart.totalAmount != null
//                                 ? '₹${cart.totalAmount!.toStringAsFixed(2)}'
//                                 : '-',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: cart.checkoutUrl != null
//                             ? () => _proceedToCheckout(cart.checkoutUrl!)
//                             : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Appcolors.kprimarycolor,
//                           minimumSize: const Size.fromHeight(48),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'Proceed to Checkout',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.hp(1),
        horizontal: ResponsiveUtils.wp(4),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Appcolors.kwhitecolor,
          borderRadius: BorderRadiusStyles.kradius15(),
          boxShadow: [
            BoxShadow(
              color: Appcolors.kblackcolor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.wp(3)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadiusStyles.kradius10(),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: ResponsiveUtils.wp(20),
                        height: ResponsiveUtils.wp(20),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: ResponsiveUtils.wp(20),
                            height: ResponsiveUtils.wp(20),
                            decoration: BoxDecoration(
                              color: Appcolors.kbackgroundcolor,
                              borderRadius: BorderRadiusStyles.kradius10(),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              color: Appcolors.kgreyColor,
                              size: ResponsiveUtils.sp(8),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: ResponsiveUtils.wp(20),
                        height: ResponsiveUtils.wp(20),
                        decoration: BoxDecoration(
                          color: Appcolors.kbackgroundcolor,
                          borderRadius: BorderRadiusStyles.kradius10(),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Appcolors.kgreyColor,
                          size: ResponsiveUtils.sp(8),
                        ),
                      ),
              ),
              SizedBox(width: ResponsiveUtils.wp(3)),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextStyles.body(
                      text: item.productTitle,
                      color: Appcolors.kblackcolor,
                      weight: FontWeight.w600,
                    ),
                    SizedBox(height: ResponsiveUtils.hp(0.5)),
                    TextStyles.medium(
                      text: item.title,
                      color: Appcolors.kgreyColor,
                    ),
                    SizedBox(height: ResponsiveUtils.hp(0.8)),
                    TextStyles.body(
                      text: '₹${item.price?.toStringAsFixed(2) ?? '-'}',
                      color: Appcolors.kprimarycolor,
                      weight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Appcolors.kbackgroundcolor,
                      borderRadius: BorderRadiusStyles.kradius10(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Appcolors.kprimarycolor,
                            size: ResponsiveUtils.sp(5.5),
                          ),
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
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: ResponsiveUtils.wp(10),
                            minHeight: ResponsiveUtils.wp(10),
                          ),
                        ),
                        TextStyles.medium(
                          text: '${item.quantity}',
                          weight: FontWeight.bold,
                          color: Appcolors.kblackcolor,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Appcolors.kprimarycolor,
                            size: ResponsiveUtils.sp(5.5),
                          ),
                          onPressed: () {
                            context.read<CartBloc>().add(
                              UpdateCartLineQty(
                                cartLineId: item.id,
                                quantity: item.quantity + 1,
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: ResponsiveUtils.wp(10),
                            minHeight: ResponsiveUtils.wp(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      backgroundColor: Appcolors.kbackgroundcolor,
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
                    size: ResponsiveUtils.wp(20),
                    color: Appcolors.kgreyColor,
                  ),
                  SizedBox(height: ResponsiveUtils.hp(2)),
                  TextStyles.subheadline(
                    text: 'Your cart is empty',
                    color: Appcolors.kblackcolor,
                  ),
                  SizedBox(height: ResponsiveUtils.hp(1)),
                  TextStyles.medium(
                    text: 'Add items to get started',
                    color: Appcolors.kgreyColor,
                  ),
                  SizedBox(height: ResponsiveUtils.hp(3)),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusStyles.kradius10(),
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors.kprimarycolor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.kprimarycolor,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(8),
                          vertical: ResponsiveUtils.hp(1.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusStyles.kradius10(),
                        ),
                      ),
                      child: TextStyles.body(
                        text: 'Continue Shopping',
                        color: Appcolors.kwhitecolor,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is CartError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveUtils.wp(16),
                      color: Appcolors.kredcolor.withOpacity(0.7),
                    ),
                    SizedBox(height: ResponsiveUtils.hp(2)),
                    TextStyles.subheadline(
                      text: 'Oops! Something went wrong',
                      color: Appcolors.kblackcolor,
                    ),
                    SizedBox(height: ResponsiveUtils.hp(1)),
                    TextStyles.medium(
                      text: state.message,
                      color: Appcolors.kgreyColor,
                    ),
                    SizedBox(height: ResponsiveUtils.hp(3)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusStyles.kradius10(),
                        boxShadow: [
                          BoxShadow(
                            color: Appcolors.kprimarycolor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            context.read<CartBloc>().add(LoadCart()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolors.kprimarycolor,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(8),
                            vertical: ResponsiveUtils.hp(1.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusStyles.kradius10(),
                          ),
                        ),
                        child: TextStyles.body(
                          text: 'Retry',
                          color: Appcolors.kwhitecolor,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CartLoaded) {
            final cart = state.cart;
            return Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.hp(2),
                    ),
                    children: [...cart.lines.map(_buildLine).toList()],
                  ),
                ),

                // Bottom Summary Section
                Container(
                  decoration: BoxDecoration(
                    color: Appcolors.kwhitecolor,
                    boxShadow: [
                      BoxShadow(
                        color: Appcolors.kblackcolor.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(4),
                        vertical: ResponsiveUtils.hp(2),
                      ),
                      child: Column(
                        children: [
                          // Total Items Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextStyles.medium(
                                text: 'Total Items',
                                color: Appcolors.kgreyColor,
                              ),
                              TextStyles.medium(
                                text:
                                    '${cart.totalQuantity} item${cart.totalQuantity > 1 ? 's' : ''}',
                                color: Appcolors.kgreyColor,
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.hp(1)),

                          // Subtotal Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextStyles.subheadline(
                                text: 'Subtotal',
                                color: Appcolors.kblackcolor,
                                weight: FontWeight.bold,
                              ),
                              TextStyles.subheadline(
                                text: cart.totalAmount != null
                                    ? '₹${cart.totalAmount!.toStringAsFixed(2)}'
                                    : '-',
                                color: Appcolors.kprimarycolor,
                                weight: FontWeight.bold,
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.hp(2)),

                          // Checkout Button
                          Container(
                            height: ResponsiveUtils.hp(5.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusStyles.kradius15(),
                            ),
                            child: ElevatedButton(
                              onPressed: cart.checkoutUrl != null
                                  ? () => _proceedToCheckout(cart.checkoutUrl!)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  218,
                                  218,
                                  217,
                                ),
                                disabledBackgroundColor: Appcolors.kgreyColor
                                    .withOpacity(0.3),
                                minimumSize: const Size.fromHeight(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusStyles.kradius15(),
                                ),
                              ),
                              child: TextStyles.body(
                                text: 'Proceed to Checkout',
                                color: Appcolors.kprimarycolor,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
