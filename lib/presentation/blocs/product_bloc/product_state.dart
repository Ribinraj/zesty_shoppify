part of 'product_bloc.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}
// class ProductsLoading extends ProductState {}


// class ProductsError extends ProductState {
//   final String message;
//   ProductsError(this.message);
// }

/// Success contains current list, page info, and whether a "load more" is in progress
// class ProductsSuccess extends ProductState {
//   final List<ProductModel> products;
//   final bool hasNextPage;
//   final String? endCursor;
//   final bool isLoadingMore;

//   ProductsSuccess({
//     required this.products,
//     required this.hasNextPage,
//     required this.endCursor,
//     this.isLoadingMore = false,
//   });

//   ProductsSuccess copyWith({
//     List<ProductModel>? products,
//     bool? hasNextPage,
//     String? endCursor,
//     bool? isLoadingMore,
//   }) {
//     return ProductsSuccess(
//       products: products ?? this.products,
//       hasNextPage: hasNextPage ?? this.hasNextPage,
//       endCursor: endCursor ?? this.endCursor,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//     );
//   }
// }
// class ProductsSuccess extends ProductState {
//   final List<ProductModel> products;
//   final bool hasNextPage;
//   final String? endCursor;
//   final bool isLoadingMore;
//   final String? query; // currently active search query (null when not searching)

//   ProductsSuccess({
//     required this.products,
//     required this.hasNextPage,
//     required this.endCursor,
//     this.isLoadingMore = false,
//     this.query,
//   });

//   ProductsSuccess copyWith({
//     List<ProductModel>? products,
//     bool? hasNextPage,
//     String? endCursor,
//     bool? isLoadingMore,
//     String? query,
//   }) {
//     return ProductsSuccess(
//       products: products ?? this.products,
//       hasNextPage: hasNextPage ?? this.hasNextPage,
//       endCursor: endCursor ?? this.endCursor,
//       isLoadingMore: isLoadingMore ?? this.isLoadingMore,
//       query: query ?? this.query,
//     );
//   }
// }
class ProductsLoading extends ProductState {}

class ProductsSuccess extends ProductState {
  final List<ProductModel> products;
  final bool hasNextPage;
  final String? endCursor;
  final bool isLoadingMore;
  final String? query;
  final ProductSortKey sortKey;
  final ProductFilter? filters;
  final String? collectionHandle;

  ProductsSuccess({
    required this.products,
    required this.hasNextPage,
    required this.endCursor,
    this.isLoadingMore = false,
    this.query,
    this.sortKey = ProductSortKey.relevance,
    this.filters,
    this.collectionHandle,
  });

  ProductsSuccess copyWith({
    List<ProductModel>? products,
    bool? hasNextPage,
    String? endCursor,
    bool? isLoadingMore,
    String? query,
    ProductSortKey? sortKey,
    ProductFilter? filters,
    String? collectionHandle,
  }) {
    return ProductsSuccess(
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      sortKey: sortKey ?? this.sortKey,
      filters: filters ?? this.filters,
      collectionHandle: collectionHandle ?? this.collectionHandle,
    );
  }
}

class ProductsError extends ProductState {
  final String message;
  ProductsError(this.message);
}

class CollectionsSuccess extends ProductState {
  final List<CollectionModel> collections;
  CollectionsSuccess(this.collections);
}