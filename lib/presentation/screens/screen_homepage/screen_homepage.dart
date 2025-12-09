

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/data/models/collection_model.dart';
// import 'package:zestyvibe/data/models/product_model.dart';



// import 'package:zestyvibe/presentation/blocs/banner_bloc/banner_bloc.dart';
// import 'package:zestyvibe/presentation/blocs/product_bloc/product_bloc.dart';
// import 'package:zestyvibe/presentation/screens/product_detailscreen/product_detailscreen.dart';
// import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/carosal_widget.dart';
// import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/collectionsheet_widget.dart';
// import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/filtersheet_widget.dart';
// import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/sortsheet_widget.dart';


// class ShopifyHomePage extends StatefulWidget {
//   const ShopifyHomePage({super.key});

//   @override
//   State<ShopifyHomePage> createState() => _ShopifyHomePageState();
// }

// class _ShopifyHomePageState extends State<ShopifyHomePage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();

//   Timer? _debounce;

//   static const _threshold = 200;
//   static const _pageSize = 12;

//   // Filter state
//   ProductSortKey _sortKey = ProductSortKey.relevance;
//   bool _availableOnly = false;
//   String? _minPrice;
//   String? _maxPrice;
//   String? _selectedCollection;
//   List<CollectionModel> _collections = [];

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Load banners and collections
//       context.read<BannerBloc>().add(FetchBannersEvent());
//       context.read<ProductBloc>().add(FetchCollectionsEvent());
//       context.read<ProductBloc>().add(FetchProductsEvent(first: _pageSize));
//     });

//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (!_scrollController.hasClients) return;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final current = _scrollController.position.pixels;
//     if (maxScroll - current <= _threshold) {
//       final state = context.read<ProductBloc>().state;
//       if (state is ProductsSuccess) {
//         if (state.hasNextPage && !state.isLoadingMore) {
//           context.read<ProductBloc>().add(FetchProductsEvent(
//                 first: _pageSize,
//                 after: state.endCursor,
//                 isLoadMore: true,
//                 query: state.query,
//                 sortKey: state.sortKey,
//                 filters: state.filters,
//                 collectionHandle: state.collectionHandle,
//               ));
//         }
//       }
//     }
//   }

//   void _onSearchChanged(String value) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 350), () {
//       _applyFilters();
//     });
//   }

//   void _showFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => FilterSheet(
//         initialAvailableOnly: _availableOnly,
//         initialMinPrice: _minPrice,
//         initialMaxPrice: _maxPrice,
//         onApply: (availableOnly, minPrice, maxPrice) {
//           setState(() {
//             _availableOnly = availableOnly;
//             _minPrice = minPrice;
//             _maxPrice = maxPrice;
//           });
//           _applyFilters();
//         },
//       ),
//     );
//   }

//   void _showSortSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SortSheet(
//         currentSortKey: _sortKey,
//         onSortSelected: (sortKey) {
//           setState(() => _sortKey = sortKey);
//           _applyFilters();
//         },
//       ),
//     );
//   }

//   void _showCollectionsSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => CollectionsSheet(
//         collections: _collections,
//         selectedCollection: _selectedCollection,
//         isLoading: _collections.isEmpty,
//         onCollectionSelected: (collectionHandle) {
//           setState(() => _selectedCollection = collectionHandle);
//           _applyFilters();
//         },
//       ),
//     );
//   }

//   void _onBannerTap(String? collectionHandle) {
//     if (collectionHandle != null) {
//       setState(() => _selectedCollection = collectionHandle);
//       _applyFilters();
//     }
//   }

//   void _applyFilters() {
//     final query = _searchController.text.trim();

//     // Build filter object
//     ProductFilter? filter;
//     PriceRange? priceRange;

//     final minPrice = double.tryParse(_minPrice ?? '');
//     final maxPrice = double.tryParse(_maxPrice ?? '');

//     if (minPrice != null || maxPrice != null) {
//       priceRange = PriceRange(
//         min: minPrice ?? 0,
//         max: maxPrice ?? 999999,
//       );
//     }

//     if (_availableOnly || priceRange != null) {
//       filter = ProductFilter(
//         available: _availableOnly ? true : null,
//         price: priceRange,
//       );
//     }

//     // Trigger fetch
//     context.read<ProductBloc>().add(FetchProductsEvent(
//           first: _pageSize,
//           query: query.isEmpty ? null : query,
//           sortKey: _sortKey,
//           filters: filter,
//           collectionHandle: _selectedCollection,
//         ));
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Widget _buildProductCard(ProductModel p) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProductDetailScreen(productHandle: p.handle),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                           const BorderRadius.vertical(top: Radius.circular(12)),
//                       child: p.imageUrl != null
//                           ? CachedNetworkImage(
//                               imageUrl: p.imageUrl!,
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                               placeholder: (c, s) => Container(
//                                 color: Colors.grey[100],
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Appcolors.kprimarycolor),
//                                   ),
//                                 ),
//                               ),
//                               errorWidget: (c, s, e) => Container(
//                                 color: Colors.grey[100],
//                                 child: Icon(Icons.broken_image_outlined,
//                                     color: Colors.grey[400], size: 40),
//                               ),
//                             )
//                           : Container(
//                               color: Colors.grey[100],
//                               child: Icon(Icons.image_outlined,
//                                   color: Colors.grey[400], size: 40),
//                             ),
//                     ),
//                     if (p.isOnSale)
//                       Positioned(
//                         top: 8,
//                         right: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Text(
//                             '-${p.discountPercentage}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (!p.availableForSale)
//                       Positioned(
//                         top: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Text(
//                             'Sold Out',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (p.vendor != null)
//                       Text(
//                         p.vendor!.toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey[600],
//                           letterSpacing: 0.5,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     const SizedBox(height: 4),
//                     Text(
//                       p.title,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         height: 1.3,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     if (p.price != null)
//                       Row(
//                         children: [
//                           Text(
//                             '₹${p.price}',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: p.isOnSale
//                                   ? Colors.red
//                                   : Appcolors.kprimarycolor,
//                             ),
//                           ),
//                           if (p.isOnSale) ...[
//                             const SizedBox(width: 6),
//                             Text(
//                               '₹${p.compareAtPrice}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                                 decoration: TextDecoration.lineThrough,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: _onSearchChanged,
//         textInputAction: TextInputAction.search,
//         decoration: InputDecoration(
//           hintText: 'Search products...',
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           suffixIcon: _searchController.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear, size: 20),
//                   onPressed: () {
//                     _searchController.clear();
//                     _applyFilters();
//                     FocusScope.of(context).unfocus();
//                   },
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildToolbar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: _showCollectionsSheet,
//               icon: const Icon(Icons.category_outlined, size: 18),
//               label: Text(_selectedCollection == null
//                   ? 'Collections'
//                   : _collections
//                           .firstWhere((c) => c.handle == _selectedCollection)
//                           .title
//                           .split(' ')
//                           .take(2)
//                           .join(' ') +
//                       (_collections
//                                   .firstWhere(
//                                       (c) => c.handle == _selectedCollection)
//                                   .title
//                                   .split(' ')
//                                   .length >
//                               2
//                           ? '...'
//                           : '')),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _selectedCollection != null
//                     ? Appcolors.kprimarycolor
//                     : Colors.black87,
//                 side: BorderSide(
//                   color: _selectedCollection != null
//                       ? Appcolors.kprimarycolor
//                       : Colors.grey[300]!,
//                 ),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: _showFilterSheet,
//               icon: const Icon(Icons.filter_list, size: 18),
//               label: const Text('Filter'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.black87,
//                 side: BorderSide(color: Colors.grey[300]!),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: _showSortSheet,
//               icon: const Icon(Icons.sort, size: 18),
//               label: const Text('Sort'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.black87,
//                 side: BorderSide(color: Colors.grey[300]!),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Shop',
//             style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
//         backgroundColor: Appcolors.kprimarycolor,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart_outlined),
//             onPressed: () {
//               // Navigate to cart
//             },
//           ),
//         ],
//       ),
//       body: MultiBlocListener(
//         listeners: [
//           BlocListener<ProductBloc, ProductState>(
//             listener: (context, state) {
//               if (state is CollectionsSuccess) {
//                 setState(() {
//                   _collections = state.collections;
//                 });
//               }
//             },
//           ),
//         ],
//         child: BlocBuilder<ProductBloc, ProductState>(
//           builder: (context, productState) {
//             if (productState is ProductsLoading) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                           Appcolors.kprimarycolor),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('Loading products...',
//                         style: TextStyle(color: Colors.grey)),
//                   ],
//                 ),
//               );
//             }

//             if (productState is ProductsError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline,
//                         size: 64, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text('Error: ${productState.message}',
//                         textAlign: TextAlign.center),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _applyFilters,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (productState is ProductsSuccess) {
//               final items = productState.products;
//               return CustomScrollView(
//                 controller: _scrollController,
//                 slivers: [
//                   SliverToBoxAdapter(child: _buildSearchBar()),
                  
//                   // Banner Section
//                   SliverToBoxAdapter(
//                     child: BlocBuilder<BannerBloc, BannerState>(
//                       builder: (context, bannerState) {
//                         if (bannerState is BannerSuccess &&
//                             bannerState.banners.isNotEmpty) {
//                           return BannerCarouselWidget(
//                             banners: bannerState.banners,
//                             onBannerTap: _onBannerTap,
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
                  
//                   SliverToBoxAdapter(child: _buildToolbar()),
//                   SliverPadding(
//                     padding: const EdgeInsets.all(16),
//                     sliver: items.isEmpty
//                         ? SliverToBoxAdapter(
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 60.0),
//                               child: Center(
//                                 child: Column(
//                                   children: [
//                                     Icon(Icons.search_off,
//                                         size: 72, color: Colors.grey[300]),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       productState.query == null ||
//                                               productState.query!.isEmpty
//                                           ? 'No products yet'
//                                           : 'No results for "${productState.query}"',
//                                       style: TextStyle(
//                                           color: Colors.grey[600], fontSize: 16),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                         : SliverGrid(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               childAspectRatio: 0.68,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                             ),
//                             delegate: SliverChildBuilderDelegate(
//                               (context, i) => _buildProductCard(items[i]),
//                               childCount: items.length,
//                             ),
//                           ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       child: Center(
//                         child: productState.isLoadingMore
//                             ? CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                     Appcolors.kprimarycolor),
//                               )
//                             : !productState.hasNextPage && items.isNotEmpty
//                                 ? Text(
//                                     'You\'ve seen it all!',
//                                     style: TextStyle(
//                                       color: Colors.grey[500],
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   )
//                                 : const SizedBox.shrink(),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }

//             // Initial state
//             return Column(
//               children: [
//                 _buildSearchBar(),
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.storefront,
//                             size: 80, color: Colors.grey[300]),
//                         const SizedBox(height: 16),
//                         const Text('Start browsing products',
//                             style: TextStyle(color: Colors.grey)),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _applyFilters,
//                           child: const Text('Load Products'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
///////////////////////////
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zestyvibe/core/appconstants.dart';

import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';

import 'package:zestyvibe/data/models/product_model.dart';
import 'package:zestyvibe/data/models/collection_model.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';

import 'package:zestyvibe/presentation/blocs/product_bloc/product_bloc.dart';
import 'package:zestyvibe/presentation/blocs/banner_bloc/banner_bloc.dart';

import 'package:zestyvibe/presentation/screens/product_detailscreen/product_detailscreen.dart';
import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/carosal_widget.dart';
import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/collectionsheet_widget.dart';
import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/filtersheet_widget.dart';
import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/home_shimmer.dart';
import 'package:zestyvibe/presentation/screens/screen_Homepage/widgets/sortsheet_widget.dart';
import 'package:zestyvibe/presentation/screens/screen_homepage/widgets/screen_logloutfuncton.dart';
import 'package:zestyvibe/presentation/screens/screen_loginpage/login_screen.dart';



class ShopifyHomePage extends StatefulWidget {
  const ShopifyHomePage({super.key});

  @override
  State<ShopifyHomePage> createState() => _ShopifyHomePageState();
}

class _ShopifyHomePageState extends State<ShopifyHomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  static const _threshold = 200;
  static const _pageSize = 12;

  // Filter state
  ProductSortKey _sortKey = ProductSortKey.relevance;
  bool _availableOnly = false;
  String? _minPrice;
  String? _maxPrice;
  String? _selectedCollection;
  List<CollectionModel> _collections = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load banners, collections, and products
      context.read<BannerBloc>().add(FetchBannersEvent());
      context.read<ProductBloc>().add(FetchCollectionsEvent());
      context.read<ProductBloc>().add(FetchProductsEvent(first: _pageSize));
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (maxScroll - current <= _threshold) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductsSuccess) {
        if (state.hasNextPage && !state.isLoadingMore) {
          context.read<ProductBloc>().add(
                FetchProductsEvent(
                  first: _pageSize,
                  after: state.endCursor,
                  isLoadMore: true,
                  query: state.query,
                  sortKey: state.sortKey,
                  filters: state.filters,
                  collectionHandle: state.collectionHandle,
                ),
              );
        }
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() {}); // updates clear icon visibility
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _applyFilters();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        initialAvailableOnly: _availableOnly,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        onApply: (availableOnly, minPrice, maxPrice) {
          setState(() {
            _availableOnly = availableOnly;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusStyles.kradius20(),
      ),
      builder: (context) => SortSheet(
        currentSortKey: _sortKey,
        onSortSelected: (sortKey) {
          setState(() => _sortKey = sortKey);
          _applyFilters();
        },
      ),
    );
  }

  void _showCollectionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionsSheet(
        collections: _collections,
        selectedCollection: _selectedCollection,
        isLoading: _collections.isEmpty,
        onCollectionSelected: (collectionHandle) {
          setState(() => _selectedCollection = collectionHandle);
          _applyFilters();
        },
      ),
    );
  }

  void _onBannerTap(String? collectionHandle) {
    if (collectionHandle != null) {
      setState(() => _selectedCollection = collectionHandle);
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim();

    // Build filter object
    ProductFilter? filter;
    PriceRange? priceRange;

    final minPrice = double.tryParse(_minPrice ?? '');
    final maxPrice = double.tryParse(_maxPrice ?? '');

    if (minPrice != null || maxPrice != null) {
      priceRange = PriceRange(
        min: minPrice ?? 0,
        max: maxPrice ?? 999999,
      );
    }

    if (_availableOnly || priceRange != null) {
      filter = ProductFilter(
        available: _availableOnly ? true : null,
        price: priceRange,
      );
    }

    // Trigger fetch
    context.read<ProductBloc>().add(
          FetchProductsEvent(
            first: _pageSize,
            query: query.isEmpty ? null : query,
            sortKey: _sortKey,
            filters: filter,
            collectionHandle: _selectedCollection,
          ),
        );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildProductCard(ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusStyles.kradius10(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          borderRadius: BorderRadiusStyles.kradius10(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusStyles.kradius10(),
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
                                  size: ResponsiveUtils.sp(6),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey[400],
                                size: ResponsiveUtils.sp(6),
                              ),
                            ),
                    ),
                    if (p.isOnSale)
                      Positioned(
                        top: ResponsiveUtils.hp(1),
                        right: ResponsiveUtils.wp(2),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(2.2),
                            vertical: ResponsiveUtils.hp(0.6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadiusStyles.kradius5(),
                          ),
                          child: ResponsiveText(
                            '-${p.discountPercentage}',
                            sizeFactor: 0.82,
                            weight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (!p.availableForSale)
                      Positioned(
                        top: ResponsiveUtils.hp(1),
                        left: ResponsiveUtils.wp(2),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.wp(2.2),
                            vertical: ResponsiveUtils.hp(0.6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadiusStyles.kradius5(),
                          ),
                          child: const ResponsiveText(
                            'Sold Out',
                            sizeFactor: 0.74,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(ResponsiveUtils.wp(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.vendor != null)
                      Text(
                        p.vendor!.toUpperCase(),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(2.5),
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ResponsiveSizedBox.height5,
                    Text(
                      p.title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(3),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ResponsiveSizedBox.height5,
                    if (p.price != null)
                      Row(
                        children: [
                          Text(
                            '₹${p.price}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.sp(3.2),
                              fontWeight: FontWeight.w700,
                              color: p.isOnSale
                                  ? Colors.red
                                  : Appcolors.kprimarycolor,
                            ),
                          ),
                          if (p.isOnSale) ...[
                            ResponsiveSizedBox.width5,
                            Text(
                              '₹${p.compareAtPrice}',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(2.6),
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
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
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(1.2),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusStyles.kradius10(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: ResponsiveUtils.sp(3),
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            fontSize: ResponsiveUtils.sp(2.8),
            color: Colors.grey,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.hp(1.5),
            horizontal: ResponsiveUtils.wp(4),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(0.9),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showCollectionsSheet,
              icon: const Icon(Icons.category_outlined, size: 18),
              label: Text(
                _selectedCollection == null
                    ? 'Categories'
                    : _collections
                            .firstWhere((c) => c.handle == _selectedCollection)
                            .title
                            .split(' ')
                            .take(2)
                            .join(' ') +
                        (_collections
                                    .firstWhere(
                                      (c) => c.handle == _selectedCollection,
                                    )
                                    .title
                                    .split(' ')
                                    .length >
                                2
                            ? '...'
                            : ''),
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(2.8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _selectedCollection != null
                    ? Appcolors.kprimarycolor
                    : Colors.black87,
                side: BorderSide(
                  color: _selectedCollection != null
                      ? Appcolors.kprimarycolor
                      : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(),
                ),
              ),
            ),
          ),
          ResponsiveSizedBox.width5,
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                'Filter',
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(2.8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(),
                ),
              ),
            ),
          ),
          ResponsiveSizedBox.width5,
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showSortSheet,
              icon: const Icon(Icons.sort, size: 18),
              label: Text(
                'Sort',
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(2.8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 227, 224, 224),
  elevation: 0,
  centerTitle: false,
  surfaceTintColor: Appcolors.kwhitecolor,

  leading: Padding(
    padding: EdgeInsets.only(left: ResponsiveUtils.wp(3)),
    child: Center(
      child: Image.asset(
        Appconstants.applogo,
        height: ResponsiveUtils.hp(6),
        fit: BoxFit.contain,
      ),
    ),
  ),

  title: Text(
    'Zesty Vibe',
    style: TextStyle(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      fontSize: ResponsiveUtils.sp(5),
      color: Appcolors.kprimarycolor,
    ),
  ),

  actions: [
    BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // -------------------------------------------
        // USER LOGGED IN → SHOW LOGOUT BUTTON
        // -------------------------------------------
        if (state is AuthAuthenticated) {
          return Padding(
            padding: EdgeInsets.only(
              right: ResponsiveUtils.wp(3),
              top: ResponsiveUtils.hp(0.8),
              bottom: ResponsiveUtils.hp(0.8),
            ),
            child: InkWell(
              onTap: () => showLogoutDialog(context),
              borderRadius: BorderRadiusStyles.kradius5(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(4),
                  vertical: ResponsiveUtils.hp(0.9),
                ),
                decoration: BoxDecoration(
                  color: Appcolors.kprimarycolor.withOpacity(0.1),
                  borderRadius: BorderRadiusStyles.kradius5(),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: ResponsiveUtils.sp(3),
                      color: Appcolors.kprimarycolor,
                    ),
                    ResponsiveSizedBox.width5,
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(2.6),
                        fontWeight: FontWeight.w600,
                        color: Appcolors.kprimarycolor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // -------------------------------------------
        // USER NOT LOGGED IN → SHOW LOGIN BUTTON
        // -------------------------------------------
        return Padding(
          padding: EdgeInsets.only(
            right: ResponsiveUtils.wp(3),
            top: ResponsiveUtils.hp(0.8),
            bottom: ResponsiveUtils.hp(0.8),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            borderRadius: BorderRadiusStyles.kradius5(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.wp(4),
                vertical: ResponsiveUtils.hp(0.9),
              ),
              decoration: BoxDecoration(
                color: Appcolors.kprimarycolor,
                borderRadius: BorderRadiusStyles.kradius5(),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.login,
                    size: ResponsiveUtils.sp(3),
                    color: Appcolors.kwhitecolor,
                  ),
                  ResponsiveSizedBox.width5,
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.sp(2.6),
                      fontWeight: FontWeight.w600,
                      color: Appcolors.kwhitecolor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ],
),




      body: MultiBlocListener(
        listeners: [
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is CollectionsSuccess) {
                setState(() {
                  _collections = state.collections;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            if (productState is ProductsLoading ||
                productState is ProductInitial) {
              return const ShopifyHomeShimmer();
            }

            if (productState is ProductsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveUtils.sp(10),
                      color: Colors.grey[400],
                    ),
                    ResponsiveSizedBox.height20,
                    Text(
                      'Error: ${productState.message}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(3),
                      ),
                    ),
                    ResponsiveSizedBox.height20,
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.sp(3),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (productState is ProductsSuccess) {
              final items = productState.products;
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  // Banner Section
                  SliverToBoxAdapter(
                    child: BlocBuilder<BannerBloc, BannerState>(
                      builder: (context, bannerState) {
                        if (bannerState is BannerSuccess &&
                            bannerState.banners.isNotEmpty) {
                          return BannerCarouselWidget(
                            banners: bannerState.banners,
                            onBannerTap: _onBannerTap,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildToolbar()),
                  SliverPadding(
                    padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
                    sliver: items.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: ResponsiveUtils.hp(8),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: ResponsiveUtils.sp(12),
                                      color: Colors.grey[300],
                                    ),
                                    ResponsiveSizedBox.height20,
                                    Text(
                                      productState.query == null ||
                                              productState.query!.isEmpty
                                          ? 'No products yet'
                                          : 'No results for "${productState.query}"',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: ResponsiveUtils.sp(3.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _buildProductCard(items[i]),
                              childCount: items.length,
                            ),
                          ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.hp(2.2),
                      ),
                      child: Center(
                        child: productState.isLoadingMore
                            ? TextStyles.caption(text: 'Loading...',color: Appcolors.kprimarycolor)                            : !productState.hasNextPage && items.isNotEmpty
                                ? TextStyles.caption(
                                    text: 'You\'ve seen it all!',
                                    color: Colors.grey[500],
                                    weight: FontWeight.w500,
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Fallback for any strange state
            return const ShopifyHomeShimmer();
          },
        ),
      ),
    );
  }
}
