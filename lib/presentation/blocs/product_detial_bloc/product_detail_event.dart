part of 'product_detail_bloc.dart';

@immutable
sealed class ProductDetailEvent {}
class LoadProductDetail extends ProductDetailEvent {
  final String handle;
  LoadProductDetail(this.handle);
}