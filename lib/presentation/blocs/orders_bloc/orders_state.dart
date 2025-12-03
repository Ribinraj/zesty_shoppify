part of 'orders_bloc.dart';

@immutable
sealed class OrdersState {}

final class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  OrdersLoaded(this.orders);
}

class OrderDetailsLoaded extends OrdersState {
  final OrderModel order;
  OrderDetailsLoaded(this.order);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

class OrdersEmpty extends OrdersState {}