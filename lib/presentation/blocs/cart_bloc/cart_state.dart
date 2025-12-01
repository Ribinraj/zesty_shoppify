part of 'cart_bloc.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class CartLoaded extends CartState {
  final CartModel cart;
  CartLoaded(this.cart);
}
