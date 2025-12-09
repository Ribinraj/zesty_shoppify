// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'package:zestyvibe/core/colors.dart' show Appcolors;
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/data/models/product_detail_model.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';
import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_detial_bloc/product_detail_bloc.dart';
import 'package:zestyvibe/widgets/custom_snackbar.dart';

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
        height: ResponsiveUtils.hp(40),
        decoration: BoxDecoration(
          color: Appcolors.kbackgroundcolor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(ResponsiveUtils.wp(8)),
            bottomRight: Radius.circular(ResponsiveUtils.wp(8)),
          ),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: ResponsiveUtils.wp(20),
            color: Appcolors.kgreyColor.withOpacity(0.5),
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: ResponsiveUtils.hp(45),
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (context, i) {
              final img = images[i];
              return Hero(
                tag: 'product_${widget.productHandle}',
                child: CachedNetworkImage(
                  imageUrl: img.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (c, s) => Container(
                    color: Appcolors.kbackgroundcolor,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Appcolors.kprimarycolor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (c, s, e) => Container(
                    color: Appcolors.kbackgroundcolor,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: ResponsiveUtils.wp(20),
                      color: Appcolors.kgreyColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Gradient overlay at bottom for better dot visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: ResponsiveUtils.hp(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Appcolors.kblackcolor.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        // Page indicators
        if (images.length > 1)
          Positioned(
            bottom: ResponsiveUtils.hp(2),
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final isActive = _currentImageIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(1),
                  ),
                  width: isActive
                      ? ResponsiveUtils.wp(6)
                      : ResponsiveUtils.wp(2),
                  height: ResponsiveUtils.wp(2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Appcolors.kwhitecolor
                        : Appcolors.kwhitecolor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.wp(2),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _variantSelector(ProductDetailLoaded state) {
    final variants = state.product.variants;
    if (variants.isEmpty) return const SizedBox.shrink();

    _selectedVariant =
        _selectedVariant ?? state.selectedVariant ?? variants.first;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(1),
      ),
      padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
      decoration: BoxDecoration(
        color: Appcolors.kwhitecolor,
        borderRadius: BorderRadius.circular(ResponsiveUtils.wp(3)),
        boxShadow: [
          BoxShadow(
            color: Appcolors.kprimarycolor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                IconlyLight.category,
                size: ResponsiveUtils.wp(5),
                color: Appcolors.kprimarycolor,
              ),
              SizedBox(width: ResponsiveUtils.wp(2)),
              Text(
                'Select Variant',
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(4.2),
                  fontWeight: FontWeight.w600,
                  color: Appcolors.kblackcolor,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.hp(1.5)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.wp(3),
              vertical: ResponsiveUtils.hp(0.5),
            ),
            decoration: BoxDecoration(
              color: Appcolors.kbackgroundcolor,
              borderRadius: BorderRadius.circular(ResponsiveUtils.wp(2)),
              border: Border.all(
                color: Appcolors.kprimarycolor.withOpacity(0.2),
              ),
            ),
            child: DropdownButton<ProductVariant>(
              isExpanded: true,
              value: _selectedVariant,
              underline: const SizedBox(),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Appcolors.kprimarycolor,
              ),
              dropdownColor: Appcolors.kwhitecolor,
              items: variants.map((v) {
                final priceText = v.price != null
                    ? ' - ₹${v.price!.toStringAsFixed(2)}'
                    : '';
                final availability = v.available ? '' : ' (Out of stock)';
                return DropdownMenuItem<ProductVariant>(
                  value: v,
                  child: Text(
                    '${v.title}$priceText$availability',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.sp(3.8),
                      color: v.available
                          ? Appcolors.kblackcolor
                          : Appcolors.kgreyColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedVariant = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceAndAvailability(ProductVariant? variant) {
    if (variant == null) return const SizedBox.shrink();
    final price = variant.price;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(4)),
      padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Appcolors.kprimarycolor.withOpacity(0.1),
            Appcolors.kbackgroundcolor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.wp(3)),
        border: Border.all(
          color: Appcolors.kprimarycolor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(3.5),
                  color: Appcolors.kgreyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: ResponsiveUtils.hp(0.5)),
              Text(
                '₹${price?.toStringAsFixed(2) ?? '-'}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(6.5),
                  fontWeight: FontWeight.bold,
                  color: Appcolors.kprimarycolor,
                ),
              ),
            ],
          ),
          if (!variant.available)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.wp(4),
                vertical: ResponsiveUtils.hp(1),
              ),
              decoration: BoxDecoration(
                color: Appcolors.kredcolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.wp(2)),
                border: Border.all(
                  color: Appcolors.kredcolor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Appcolors.kredcolor,
                    size: ResponsiveUtils.wp(4.5),
                  ),
                  SizedBox(width: ResponsiveUtils.wp(1.5)),
                  Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Appcolors.kredcolor,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.sp(3.5),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.wp(4),
                vertical: ResponsiveUtils.hp(1),
              ),
              decoration: BoxDecoration(
                color: Appcolors.kgreencolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.wp(2)),
                border: Border.all(
                  color: Appcolors.kgreencolor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Appcolors.kgreencolor,
                    size: ResponsiveUtils.wp(4.5),
                  ),
                  SizedBox(width: ResponsiveUtils.wp(1.5)),
                  Text(
                    'In Stock',
                    style: TextStyle(
                      color: Appcolors.kgreencolor,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.sp(3.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Appcolors.kbackgroundcolor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(ResponsiveUtils.wp(2)),
            decoration: BoxDecoration(
              color: Appcolors.kwhitecolor.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Appcolors.kblackcolor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Appcolors.kblackcolor,
                size: ResponsiveUtils.wp(5),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // actions: [
          //   Container(
          //     margin: EdgeInsets.all(ResponsiveUtils.wp(2)),
          //     decoration: BoxDecoration(
          //       color: Appcolors.kwhitecolor.withOpacity(0.9),
          //       shape: BoxShape.circle,
          //       boxShadow: [
          //         BoxShadow(
          //           color: Appcolors.kblackcolor.withOpacity(0.1),
          //           blurRadius: 8,
          //           offset: const Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: IconButton(
          //       icon: Icon(
          //         IconlyLight.heart,
          //         color: Appcolors.kprimarycolor,
          //         size: ResponsiveUtils.wp(6),
          //       ),
          //       onPressed: () {
          //         // Add to wishlist functionality
          //       },
          //     ),
          //   ),
          // ],
        ),
        body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Appcolors.kprimarycolor,
                ),
              );
            }

            if (state is ProductDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: ResponsiveUtils.wp(20),
                      color: Appcolors.kredcolor,
                    ),
                    SizedBox(height: ResponsiveUtils.hp(2)),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(5),
                        fontWeight: FontWeight.w600,
                        color: Appcolors.kblackcolor,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.hp(1)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.wp(10),
                      ),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(3.5),
                          color: Appcolors.kgreyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductDetailLoaded) {
              final product = state.product;

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _imageCarousel(product.images),
                        SizedBox(height: ResponsiveUtils.hp(2)),
                        
                        // Product Title
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(4),
                          ),
                          child: Text(
                            product.title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.sp(5.5),
                              fontWeight: FontWeight.bold,
                              color: Appcolors.kblackcolor,
                              height: 1.3,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.hp(2)),
                        
                        // Price and Availability
                        _priceAndAvailability(
                          _selectedVariant ?? state.selectedVariant,
                        ),
                        
                        SizedBox(height: ResponsiveUtils.hp(1.5)),
                        
                        // Variant Selector
                        _variantSelector(state),
                        
                        SizedBox(height: ResponsiveUtils.hp(2)),
                        
                        // Description Section
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(4),
                          ),
                          padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
                          decoration: BoxDecoration(
                            color: Appcolors.kwhitecolor,
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.wp(3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Appcolors.kprimarycolor.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    IconlyLight.document,
                                    size: ResponsiveUtils.wp(5),
                                    color: Appcolors.kprimarycolor,
                                  ),
                                  SizedBox(width: ResponsiveUtils.wp(2)),
                                  Text(
                                    'Product Description',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.sp(4.2),
                                      fontWeight: FontWeight.w600,
                                      color: Appcolors.kblackcolor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.hp(1.5)),
                              product.descriptionHtml != null &&
                                      product.descriptionHtml!.isNotEmpty
                                  ? Html(
                                      data: product.descriptionHtml!,
                                      style: {
                                        "body": Style(
                                          fontSize: FontSize(
                                            ResponsiveUtils.sp(3.8),
                                          ),
                                          color: Appcolors.kgreyColor,
                                          lineHeight: const LineHeight(1.6),
                                        ),
                                      },
                                    )
                                  : Text(
                                      'No description available',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.sp(3.8),
                                        color: Appcolors.kgreyColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveUtils.hp(12)),
                      ],
                    ),
                  ),
                  
                  // Fixed Add to Cart Button at Bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
                      decoration: BoxDecoration(
                        color: Appcolors.kwhitecolor,
                        boxShadow: [
                          BoxShadow(
                            color: Appcolors.kblackcolor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ResponsiveUtils.wp(6)),
                          topRight: Radius.circular(ResponsiveUtils.wp(6)),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: ResponsiveUtils.hp(6.5),
                          child: ElevatedButton(
                            onPressed: (_selectedVariant ??
                                        state.selectedVariant)
                                    ?.available ==
                                true
                                ? () {
                                    final variantId = _selectedVariant?.id;
                                    if (variantId != null) {
                                      context.read<CartBloc>().add(
                                            AddItemToCart(
                                              merchandiseId: variantId,
                                              quantity: 1,
                                            ),
                                          );
                                    }

                           CustomSnackbar.show(context, message:  'Added to cart successfully!', type:SnackbarType.success);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Appcolors.kprimarycolor,
                              disabledBackgroundColor:
                                  Appcolors.kgreyColor.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.wp(3),
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  IconlyBold.bag,
                                  color: Appcolors.kwhitecolor,
                                  size: ResponsiveUtils.wp(5.5),
                                ),
                                SizedBox(width: ResponsiveUtils.wp(2)),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.sp(4.5),
                                    fontWeight: FontWeight.w600,
                                    color: Appcolors.kwhitecolor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}