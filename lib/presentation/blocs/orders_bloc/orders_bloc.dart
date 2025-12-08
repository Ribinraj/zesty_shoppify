import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/data/models/order_modelitem.dart';

import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final AppRepo repository;

  OrdersBloc({required this.repository}) : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<RefreshOrders>(_onRefreshOrders);
  }

  FutureOr<void> _onLoadOrders(LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    final resp = await repository.fetchCustomerOrders();
    
    if (resp.error || resp.data == null) {
      emit(OrdersError(resp.message));
      return;
    }

    if (resp.data!.isEmpty) {
      emit(OrdersEmpty());
      return;
    }

    emit(OrdersLoaded(resp.data!));
  }

  FutureOr<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final resp = await repository.fetchOrderById(orderId: event.orderId);
    
    if (resp.error || resp.data == null) {
      emit(OrdersError(resp.message));
      return;
    }

    emit(OrderDetailsLoaded(resp.data!));
  }

  FutureOr<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // Keep current state while refreshing
    final resp = await repository.fetchCustomerOrders();
    
    if (resp.error || resp.data == null) {
      // Don't change state on error during refresh
      return;
    }

    if (resp.data!.isEmpty) {
      emit(OrdersEmpty());
      return;
    }

    emit(OrdersLoaded(resp.data!));
  }
}
