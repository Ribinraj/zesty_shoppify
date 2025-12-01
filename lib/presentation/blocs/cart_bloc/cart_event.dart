part of 'cart_bloc.dart';

@immutable
sealed class CartEvent {}
class LoadCart extends CartEvent {}

class CreateCartWithItem extends CartEvent {
  final String merchandiseId;
  final int quantity;
  CreateCartWithItem({required this.merchandiseId, this.quantity = 1});
}

class AddItemToCart extends CartEvent {
  final String merchandiseId;
  final int quantity;
  AddItemToCart({required this.merchandiseId, this.quantity = 1});
}

class UpdateCartLineQty extends CartEvent {
  final String cartLineId;
  final int quantity;
  UpdateCartLineQty({required this.cartLineId, required this.quantity});
}

class RemoveCartLine extends CartEvent {
  final String cartLineId;
  RemoveCartLine({required this.cartLineId});
}

class ClearCart extends CartEvent {}