part of 'product_bloc.dart';

@immutable
sealed class ProductEvent {}
// class FetchProductsEvent extends ProductEvent {
//   final int first;
//   /// if `after` is null → initial load / refresh. Otherwise it loads next page.
//   final String? after;
//   final bool isLoadMore;

//   FetchProductsEvent({this.first = 12, this.after, this.isLoadMore = false});
// }
class FetchProductsEvent extends ProductEvent {
  final int first;
  final String? after;
  final bool isLoadMore;
  /// if query is non-null & non-empty => perform search instead of general fetch
  final String? query;

  FetchProductsEvent({this.first = 12, this.after, this.isLoadMore = false, this.query});
}