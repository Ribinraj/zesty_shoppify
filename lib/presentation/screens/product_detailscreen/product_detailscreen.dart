// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:zestyvibe/core/colors.dart' show Appcolors;
import 'package:zestyvibe/data/models/product_detail_model.dart';


import 'package:zestyvibe/domain/repositories/apprepo.dart';
import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_detial_bloc/product_detail_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productHandle;
  const ProductDetailScreen({super.key, required this.productHandle});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductDetailBloc _bloc;
  int _currentImageIndex = 0;
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    // assume AppRepo.instance is initialized
    _bloc = ProductDetailBloc(repository: AppRepo.instance);
    _bloc.add(LoadProductDetail(widget.productHandle));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Widget _imageCarousel(List<ProductImage> images) {
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
      );
    }

    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, i) {
              final img = images[i];
              return CachedNetworkImage(
                imageUrl: img.url,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (c, s) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (c, s, e) => const Icon(Icons.broken_image),
              );
            },
          ),
          Positioned(
            bottom: 8,
            child: Row(
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _variantSelector(ProductDetailLoaded state) {
    final variants = state.product.variants;
    if (variants.isEmpty) return const SizedBox.shrink();

    _selectedVariant =
        _selectedVariant ?? state.selectedVariant ?? variants.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select variant',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButton<ProductVariant>(
            isExpanded: true,
            value: _selectedVariant,
            items: variants.map((v) {
              final priceText = v.price != null
                  ? ' - ₹${v.price!.toStringAsFixed(2)}'
                  : '';
              final availability = v.available ? '' : ' (Out of stock)';
              return DropdownMenuItem<ProductVariant>(
                value: v,
                child: Text('${v.title}$priceText$availability'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedVariant = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _priceArea(ProductVariant? variant) {
    if (variant == null) return const SizedBox.shrink();
    final price = variant.price;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Text(
            '₹${price?.toStringAsFixed(2) ?? '-'}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          if (!variant.available)
            const Text('Out of stock', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product'),
          backgroundColor: Appcolors.kprimarycolor,
        ),
        body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductDetailError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is ProductDetailLoaded) {
              final product = state.product;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _imageCarousel(product.images),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _priceArea(_selectedVariant ?? state.selectedVariant),
                    const SizedBox(height: 8),
                    _variantSelector(state),
                    const SizedBox(height: 12),

                    // Description (basic HTML rendering)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child:
                          product.descriptionHtml != null &&
                              product.descriptionHtml!.isNotEmpty
                          ? Html(data: product.descriptionHtml!)
                          : const Text('No description'),
                    ),

                    const SizedBox(height: 20),

                    // Add to Cart button (placeholder - you should hook to cart flow)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              (_selectedVariant ?? state.selectedVariant)
                                      ?.available ==
                                  true
                              ? () {
                                  // example inside ProductDetailScreen where you handle Add to Cart:
                                  final variantId = _selectedVariant
                                      ?.id; // should be the variant gid (e.g. "gid://shopify/ProductVariant/123")
                                  if (variantId != null) {
                                    context.read<CartBloc>().add(
                                      AddItemToCart(
                                        merchandiseId: variantId,
                                        quantity: 1,
                                      ),
                                    );
                                    // optionally navigate to cart screen
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Add to cart pressed (hook me)',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Appcolors.kprimarycolor,
                          ),
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
  //////////---------searchoption----------////////////////
  
}
