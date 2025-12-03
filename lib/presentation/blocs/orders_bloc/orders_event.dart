part of 'orders_bloc.dart';

@immutable
sealed class OrdersEvent {}
class LoadOrders extends OrdersEvent {}

class LoadOrderDetails extends OrdersEvent {
  final String orderId;
  LoadOrderDetails({required this.orderId});
}

class RefreshOrders extends OrdersEvent {}