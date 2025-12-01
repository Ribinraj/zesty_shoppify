import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/domain/models/product_detail_model.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final AppRepo repository;
  ProductDetailBloc({required this.repository}) : super(ProductDetailInitial()) {
    on<LoadProductDetail>(_onLoadProductDetail);
  }

  FutureOr<void> _onLoadProductDetail(LoadProductDetail event, Emitter<ProductDetailState> emit) async {
    try {
      emit(ProductDetailLoading());
      final resp = await repository.fetchProductByHandle(handle: event.handle);
      if (resp.error || resp.data == null) {
        emit(ProductDetailError(resp.message));
        return;
      }
      final product = resp.data!;
      emit(ProductDetailLoaded(product: product, selectedVariant: product.defaultVariant));
    } catch (e) {
      emit(ProductDetailError('Unexpected error'));
    }
  }
}
