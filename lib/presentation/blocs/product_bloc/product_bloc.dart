import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/domain/models/product_model.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'product_event.dart';
part 'product_state.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   final AppRepo repository;
//   ProductBloc({required this.repository}) : super(ProductInitial()) {
//     on<FetchProductsEvent>(_onFetchProducts);
//   }

//   FutureOr<void> _onFetchProducts(FetchProductsEvent event, Emitter<ProductState> emit) async {
//     final currentState = state;
//     try {
//       // If it's load more and we already have ProductsSuccess, set isLoadingMore true
//       if (event.isLoadMore && currentState is ProductsSuccess) {
//         // update UI to show bottom loader
//         emit(currentState.copyWith(isLoadingMore: true));
//       } else {
//         // initial load / refresh
//         emit(ProductsLoading());
//       }

//       final resp = await repository.fetchProducts(first: event.first, after: event.after);

//       if (resp.error || resp.data == null) {
//         final message = resp.message;
//         emit(ProductsError(message));
//         return;
//       }

//       final paginated = resp.data!;
//       final fetched = paginated.products;

//       if (event.isLoadMore && currentState is ProductsSuccess) {
//         // append to existing
//         final combined = List<ProductModel>.from(currentState.products)..addAll(fetched);
//         emit(ProductsSuccess(
//           products: combined,
//           hasNextPage: paginated.hasNextPage,
//           endCursor: paginated.endCursor,
//           isLoadingMore: false,
//         ));
//       } else {
//         // fresh replace
//         emit(ProductsSuccess(
//           products: fetched,
//           hasNextPage: paginated.hasNextPage,
//           endCursor: paginated.endCursor,
//           isLoadingMore: false,
//         ));
//       }
//     } catch (e) {
//       emit(ProductsError('Unexpected error'));
//     }
//   }
// }
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppRepo repository;
  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
  }

  FutureOr<void> _onFetchProducts(FetchProductsEvent event, Emitter<ProductState> emit) async {
    final currentState = state;
    final isSearch = event.query != null && event.query!.trim().isNotEmpty;
    try {
      // If it's load more and we already have ProductsSuccess, set isLoadingMore true
      if (event.isLoadMore && currentState is ProductsSuccess) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(ProductsLoading());
      }

      ApiResponse<dynamic> resp;
      if (isSearch) {
        resp = await repository.searchProducts(query: event.query!.trim(), first: event.first, after: event.after);
      } else {
        resp = await repository.fetchProducts(first: event.first, after: event.after);
      }

      if (resp.error || resp.data == null) {
        final message = resp.message;
        emit(ProductsError(message));
        return;
      }

      final paginated = resp.data as PaginatedProducts;
      final fetched = paginated.products;

      if (event.isLoadMore && currentState is ProductsSuccess) {
        // append to existing
        final combined = List<ProductModel>.from(currentState.products)..addAll(fetched);
        emit(ProductsSuccess(
          products: combined,
          hasNextPage: paginated.hasNextPage,
          endCursor: paginated.endCursor,
          isLoadingMore: false,
          query: isSearch ? event.query : currentState.query,
        ));
      } else {
        // fresh replace (initial load or new search)
        emit(ProductsSuccess(
          products: fetched,
          hasNextPage: paginated.hasNextPage,
          endCursor: paginated.endCursor,
          isLoadingMore: false,
          query: isSearch ? event.query : null,
        ));
      }
    } catch (e) {
      emit(ProductsError('Unexpected error'));
    }
  }
}