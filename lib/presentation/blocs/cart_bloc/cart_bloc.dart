import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/domain/models/cartItem_model.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AppRepo repository;
  CartBloc({required this.repository}) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<CreateCartWithItem>(_onCreateWithItem);
    on<AddItemToCart>(_onAddItem);
    on<UpdateCartLineQty>(_onUpdateLine);
    on<RemoveCartLine>(_onRemoveLine);
    on<ClearCart>(_onClearCart);
  }

  FutureOr<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final resp = await repository.fetchCart();
    if (resp.error || resp.data == null) {
      // no cart yet is not necessarily error -> return empty
      emit(CartInitial());
      return;
    }
    emit(CartLoaded(resp.data!));
  }

  FutureOr<void> _onCreateWithItem(CreateCartWithItem event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final lines = [
      {'merchandiseId': event.merchandiseId, 'quantity': event.quantity}
    ];
    final resp = await repository.createCart(lines: lines);
    if (resp.error || resp.data == null) {
      emit(CartError(resp.message));
      return;
    }
    emit(CartLoaded(resp.data!));
  }

  FutureOr<void> _onAddItem(AddItemToCart event, Emitter<CartState> emit) async {
    final current = state;
    // if no cart -> create cart with item
    if (current is! CartLoaded) {
      add(CreateCartWithItem(merchandiseId: event.merchandiseId, quantity: event.quantity));
      return;
    }
    emit(CartLoading());
    final resp = await repository.addLines(cartId: current.cart.id, lines: [
      {'merchandiseId': event.merchandiseId, 'quantity': event.quantity}
    ]);
    if (resp.error || resp.data == null) {
      emit(CartError(resp.message));
      return;
    }
    emit(CartLoaded(resp.data!));
  }

  FutureOr<void> _onUpdateLine(UpdateCartLineQty event, Emitter<CartState> emit) async {
    final current = state;
    if (current is! CartLoaded) return;
    emit(CartLoading());
    final resp = await repository.updateLines(cartId: current.cart.id, lines: [
      {'id': event.cartLineId, 'quantity': event.quantity}
    ]);
    if (resp.error || resp.data == null) {
      emit(CartError(resp.message));
      return;
    }
    emit(CartLoaded(resp.data!));
  }

  FutureOr<void> _onRemoveLine(RemoveCartLine event, Emitter<CartState> emit) async {
    final current = state;
    if (current is! CartLoaded) return;
    emit(CartLoading());
    final resp = await repository.removeLines(cartId: current.cart.id, lineIds: [event.cartLineId]);
    if (resp.error || resp.data == null) {
      emit(CartError(resp.message));
      return;
    }
    if (resp.data!.totalQuantity == 0) {
      emit(CartInitial());
    } else {
      emit(CartLoaded(resp.data!));
    }
  }

  FutureOr<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    // simplest: remove all lines
    final current = state;
    if (current is! CartLoaded) return;
    emit(CartLoading());
    final lineIds = current.cart.lines.map((e) => e.id).toList();
    final resp = await repository.removeLines(cartId: current.cart.id, lineIds: lineIds);
    if (resp.error) {
      emit(CartError(resp.message));
      return;
    }
    await repository.clearLocalCartId(); 
    emit(CartInitial());
  }
}
