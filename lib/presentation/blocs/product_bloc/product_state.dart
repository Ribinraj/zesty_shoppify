part of 'product_bloc.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}
class ProductsLoading extends ProductState {}


class ProductsError extends ProductState {
  final String message;
  ProductsError(this.message);
}

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
class ProductsSuccess extends ProductState {
  final List<ProductModel> products;
  final bool hasNextPage;
  final String? endCursor;
  final bool isLoadingMore;
  final String? query; // currently active search query (null when not searching)

  ProductsSuccess({
    required this.products,
    required this.hasNextPage,
    required this.endCursor,
    this.isLoadingMore = false,
    this.query,
  });

  ProductsSuccess copyWith({
    List<ProductModel>? products,
    bool? hasNextPage,
    String? endCursor,
    bool? isLoadingMore,
    String? query,
  }) {
    return ProductsSuccess(
      products: products ?? this.products,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      endCursor: endCursor ?? this.endCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
    );
  }
}