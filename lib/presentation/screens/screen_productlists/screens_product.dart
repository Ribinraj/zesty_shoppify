
//////////////////////
// lib/screens/product_list_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zestyvibe/core/colors.dart' show Appcolors;
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/domain/models/product_model.dart';
import 'package:zestyvibe/presentation/blocs/product_bloc/product_bloc.dart';
import 'package:zestyvibe/presentation/screens/product_detailscreen/product_detailscreen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  static const _threshold = 200;
  static const _pageSize = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(FetchProductsEvent(first: _pageSize));
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (maxScroll - current <= _threshold) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductsSuccess) {
        if (state.hasNextPage && !state.isLoadingMore) {
          // preserve query if searching
          context.read<ProductBloc>().add(FetchProductsEvent(
                first: _pageSize,
                after: state.endCursor,
                isLoadMore: true,
                query: state.query,
              ));
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = value.trim();
      if (q.isEmpty) {
        // clear search -> fetch default products
        context.read<ProductBloc>().add(FetchProductsEvent(first: _pageSize));
      } else {
        // search initial
        context.read<ProductBloc>().add(FetchProductsEvent(first: _pageSize, query: q));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildItem(ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productHandle: p.handle),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area with rounded top corners
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: p.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (c, s) => Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Appcolors.kprimarycolor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (c, s, e) => Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 48,
                            ),
                          ),
                        ),
                ),
              ),

              // Product details section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    ResponsiveText(
                      p.title,
                      sizeFactor: 0.95,
                      weight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                    const SizedBox(height: 6),
                    
                    // Price with better styling
                    if (p.price != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Appcolors.kprimarycolor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ResponsiveText(
                          '₹${p.price}',
                          sizeFactor: 0.9,
                          weight: FontWeight.w700,
                          color: Appcolors.kprimarycolor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products, tags or vendor',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        backgroundColor: Appcolors.kprimarycolor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Appcolors.kprimarycolor)),
                  const SizedBox(height: 12),
                  const Text('Loading products...'),
                ],
              ),
            );
          }

          if (state is ProductsError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ProductsSuccess) {
            final items = state.products;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: items.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 80.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.query == null || state.query!.isEmpty ? 'No products yet' : 'No results for "${state.query}"',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _buildItem(items[i]),
                            childCount: items.length,
                          ),
                        ),
                ),
                // footer
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: state.isLoadingMore
                          ? CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Appcolors.kprimarycolor))
                          : !state.hasNextPage
                              ? Text(
                                  'No more products',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            );
          }

          // fallback: if initial, show search + skeleton grid trigger initial fetch
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(child: Center(child: Text('Start browsing products'))),
            ],
          );
        },
      ),
    );
  }
}
