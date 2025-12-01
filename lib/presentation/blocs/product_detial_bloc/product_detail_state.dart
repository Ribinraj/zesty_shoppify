part of 'product_detail_bloc.dart';

@immutable
sealed class ProductDetailState {}
class ProductDetailLoading extends ProductDetailState {}
final class ProductDetailInitial extends ProductDetailState {}
class ProductDetailError extends ProductDetailState {
  final String message;
  ProductDetailError(this.message);
}

class ProductDetailLoaded extends ProductDetailState {
  final ProductDetailModel product;
  final ProductVariant? selectedVariant;
  ProductDetailLoaded({required this.product, this.selectedVariant});

  ProductDetailLoaded copyWith({ProductVariant? selectedVariant}) {
    return ProductDetailLoaded(
      product: product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }
}