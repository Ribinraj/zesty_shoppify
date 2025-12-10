import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/data/models/order_modelitem.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/presentation/blocs/orders_bloc/orders_bloc.dart';
import 'package:zestyvibe/presentation/screens/screen_loginpage/login_screen.dart';
import 'package:zestyvibe/presentation/screens/screen_orders_detailspage/screen_orders_detailspage.dart';
import 'package:zestyvibe/widgets/custom_appbar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Check if user is authenticated before loading orders
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrdersBloc>().add(LoadOrders());
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return Appcolors.kgreencolor;
      case 'PENDING':
        return Colors.orange;
      case 'REFUNDED':
      case 'PARTIALLY_REFUNDED':
        return Appcolors.kredcolor;
      default:
        return Appcolors.kgreyColor;
    }
  }

  Color _getFulfillmentColor(String status) {
    switch (status.toUpperCase()) {
      case 'FULFILLED':
        return Appcolors.kgreencolor;
      case 'UNFULFILLED':
        return Colors.orange;
      case 'PARTIALLY_FULFILLED':
        return Colors.blue;
      default:
        return Appcolors.kgreyColor;
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(1),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: order.id),
                ),
              );
            },
            borderRadius: BorderRadiusStyles.kradius15(),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextStyles.subheadline(
                          text: 'Order ${order.name}',
                          color: Appcolors.kblackcolor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.sp(4),
                        color: Appcolors.kgreyColor,
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.hp(0.5)),
                  TextStyles.medium(
                    text: dateFormat.format(order.processedAt),
                    color: Appcolors.kgreyColor,
                  ),
                  SizedBox(height: ResponsiveUtils.hp(1.5)),

                  // Order items preview
                  Row(
                    children: [
                      ...order.lineItems.take(3).map((item) {
                        return Container(
                          margin: EdgeInsets.only(right: ResponsiveUtils.wp(2)),
                          child: item.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadiusStyles.kradius10(),
                                  child: Image.network(
                                    item.imageUrl!,
                                    width: ResponsiveUtils.wp(13),
                                    height: ResponsiveUtils.wp(13),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: ResponsiveUtils.wp(13),
                                  height: ResponsiveUtils.wp(13),
                                  decoration: BoxDecoration(
                                    color: Appcolors.kbackgroundcolor,
                                    borderRadius:
                                        BorderRadiusStyles.kradius10(),
                                  ),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Appcolors.kgreyColor,
                                    size: ResponsiveUtils.sp(6),
                                  ),
                                ),
                        );
                      }).toList(),
                      if (order.lineItems.length > 3)
                        Container(
                          width: ResponsiveUtils.wp(13),
                          height: ResponsiveUtils.wp(13),
                          decoration: BoxDecoration(
                            color: Appcolors.kbackgroundcolor,
                            borderRadius: BorderRadiusStyles.kradius10(),
                          ),
                          child: Center(
                            child: TextStyles.medium(
                              text: '+${order.lineItems.length - 3}',
                              weight: FontWeight.bold,
                              color: Appcolors.kprimarycolor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.hp(1.5)),

                  Divider(
                    color: Appcolors.kgreyColor.withOpacity(0.2),
                    thickness: 1,
                  ),
                  SizedBox(height: ResponsiveUtils.hp(1)),

                  // Price and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextStyles.medium(
                            text: 'Total',
                            color: Appcolors.kgreyColor,
                          ),
                          SizedBox(height: ResponsiveUtils.hp(0.3)),
                          TextStyles.subheadline(
                            text: '₹${order.totalPrice.toStringAsFixed(2)}',
                            color: Appcolors.kblackcolor,
                            weight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.wp(3),
                              vertical: ResponsiveUtils.hp(0.6),
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.financialStatus,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadiusStyles.kradius20(),
                            ),
                            child: TextStyles.caption(
                              text: order.statusText,
                              color: _getStatusColor(order.financialStatus),
                              weight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.hp(0.6)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.wp(3),
                              vertical: ResponsiveUtils.hp(0.6),
                            ),
                            decoration: BoxDecoration(
                              color: _getFulfillmentColor(
                                order.fulfillmentStatus,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadiusStyles.kradius20(),
                            ),
                            child: TextStyles.caption(
                              text: order.fulfillmentText,
                              color: _getFulfillmentColor(
                                order.fulfillmentStatus,
                              ),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: ResponsiveUtils.wp(20),
            color: Appcolors.kgreyColor,
          ),
          SizedBox(height: ResponsiveUtils.hp(2)),
          TextStyles.subheadline(
            text: 'Not logged in',
            color: Appcolors.kgreyColor,
          ),
          SizedBox(height: ResponsiveUtils.hp(1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(10)),
            child: TextStyles.medium(
              text: 'Login to view your orders',
              color: Appcolors.kgreyColor,
            ),
          ),
          SizedBox(height: ResponsiveUtils.hp(2)),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadiusStyles.kradius10(),
    
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 218, 216, 215),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(10),
                  vertical: ResponsiveUtils.hp(1.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(),
                ),
              ),
              child: TextStyles.body(
                text: 'Login',
                color: Appcolors.kprimarycolor,
                weight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.kbackgroundcolor,
      appBar: CustomAppBar(title: 'My orders'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Check authentication first
          if (authState is! AuthAuthenticated) {
            return _buildNotLoggedInView();
          }

          // User is authenticated, show orders
          return BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, ordersState) {
              if (ordersState is OrdersLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Appcolors.kprimarycolor,
                  ),
                );
              }

              if (ordersState is OrdersError) {
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
                          text: ordersState.message,
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
                            onPressed: () {
                              context.read<OrdersBloc>().add(LoadOrders());
                            },
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

              if (ordersState is OrdersEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: ResponsiveUtils.wp(20),
                        color: Appcolors.kgreyColor,
                      ),
                      SizedBox(height: ResponsiveUtils.hp(2)),
                      TextStyles.subheadline(
                        text: 'No orders yet',
                        color: Appcolors.kblackcolor,
                      ),
                      SizedBox(height: ResponsiveUtils.hp(1)),
                      TextStyles.medium(
                        text: 'Start shopping to see your orders here',
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
                            text: 'Start Shopping',
                            color: Appcolors.kwhitecolor,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (ordersState is OrdersLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrdersBloc>().add(RefreshOrders());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: Appcolors.kprimarycolor,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.hp(2),
                    ),
                    itemCount: ordersState.orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(ordersState.orders[index]);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
