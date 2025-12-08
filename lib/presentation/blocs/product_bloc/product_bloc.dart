import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/data/models/collection_model.dart';
import 'package:zestyvibe/data/models/product_model.dart';

import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'product_event.dart';
part 'product_state.dart';


class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final AppRepo repository;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchCollectionsEvent>(_onFetchCollections);
  }

  FutureOr<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    final isSearch = event.query != null && event.query!.trim().isNotEmpty;

    try {
      // If load more, set isLoadingMore flag
      if (event.isLoadMore && currentState is ProductsSuccess) {
        emit(currentState.copyWith(isLoadingMore: true));
      } else {
        emit(ProductsLoading());
      }

      ApiResponse<PaginatedProducts> resp;

      // Fetch from collection or general products
      if (event.collectionHandle != null) {
        resp = await repository.fetchProductsByCollection(
          collectionHandle: event.collectionHandle!,
          first: event.first,
          after: event.after,
          sortKey: event.sortKey,
          filters: event.filters,
        );
      } else if (isSearch) {
        resp = await repository.searchProducts(
          query: event.query!.trim(),
          first: event.first,
          after: event.after,
        );
      } else {
        resp = await repository.fetchProducts(
          first: event.first,
          after: event.after,
          sortKey: event.sortKey,
          filters: event.filters,
        );
      }

      if (resp.error || resp.data == null) {
        emit(ProductsError(resp.message));
        return;
      }

      final paginated = resp.data!;
      final fetched = paginated.products;

      if (event.isLoadMore && currentState is ProductsSuccess) {
        final combined = List<ProductModel>.from(currentState.products)
          ..addAll(fetched);
        emit(ProductsSuccess(
          products: combined,
          hasNextPage: paginated.hasNextPage,
          endCursor: paginated.endCursor,
          isLoadingMore: false,
          query: isSearch ? event.query : currentState.query,
          sortKey: event.sortKey,
          filters: event.filters,
          collectionHandle: event.collectionHandle,
        ));
      } else {
        emit(ProductsSuccess(
          products: fetched,
          hasNextPage: paginated.hasNextPage,
          endCursor: paginated.endCursor,
          isLoadingMore: false,
          query: isSearch ? event.query : null,
          sortKey: event.sortKey,
          filters: event.filters,
          collectionHandle: event.collectionHandle,
        ));
      }
    } catch (e) {
      emit(ProductsError('Unexpected error: $e'));
    }
  }
  FutureOr<void> _onFetchCollections(
  FetchCollectionsEvent event,
  Emitter<ProductState> emit,
) async {
  final previousState = state; // remember what UI was showing

  try {
    // 🔸 Don't emit ProductsLoading here – we don't want to hide products grid
    final resp = await repository.fetchCollections(first: 250);

    if (resp.error || resp.data == null) {
      // Optional: you can log/show snackBar from UI using another event,
      // but we won't disturb product UI.
      // So just return.
      return;
    }

    // Emit this so your BlocListener can catch & store collections
    emit(CollectionsSuccess(resp.data!));

    // Then restore whatever state UI had before (usually ProductsSuccess)
    emit(previousState);
  } catch (e) {
    // Same idea: don't block the whole page for collections failure.
    // You can choose to do nothing or log.
  }
}

// FutureOr<void> _onFetchCollections(
//   FetchCollectionsEvent event,
//   Emitter<ProductState> emit,
// ) async {
//   try {
//     // Only show loading if we don't have collections yet
//     if (state is! CollectionsSuccess) {
//       emit(ProductsLoading());
//     }

//     // Fetch up to 250 collections (Shopify API max)
//     final resp = await repository.fetchCollections(first: 250);

//     if (resp.error || resp.data == null) {
//       emit(ProductsError(resp.message));
//       return;
//     }

//     emit(CollectionsSuccess(resp.data!));
//   } catch (e) {
//     emit(ProductsError('Failed to load collections'));
//   }
// }


}