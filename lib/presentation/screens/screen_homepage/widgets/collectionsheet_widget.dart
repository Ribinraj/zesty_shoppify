// // lib/presentation/widgets/collections_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/data/models/collection_model.dart';



// class CollectionsSheet extends StatelessWidget {
//   final List<CollectionModel> collections;
//   final String? selectedCollection;
//   final Function(String?) onCollectionSelected;
//   final bool isLoading;

//   const CollectionsSheet({
//     super.key,
//     required this.collections,
//     this.selectedCollection,
//     required this.onCollectionSelected,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               _buildHandle(),
//               _buildHeader(context),
//               const Divider(height: 1),
//               Expanded(
//                 child: isLoading
//                     ? _buildLoadingState()
//                     : _buildCollectionsList(scrollController, context),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHandle() {
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       width: 40,
//       height: 4,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           const Text(
//             'Categories',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           if (selectedCollection != null)
//             TextButton(
//               onPressed: () {
//                 onCollectionSelected(null);
//                 Navigator.pop(context);
//               },
//               child: const Text('Clear'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(
//               Appcolors.kprimarycolor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Loading collections...',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollectionsList(
//     ScrollController scrollController,
//     BuildContext context,
//   ) {
//     return ListView(
//       controller: scrollController,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       children: [
//         _buildAllProductsOption(context),
//         const Divider(height: 1),
//         ...collections.map((collection) => 
//           _buildCollectionTile(collection, context)
//         ).toList(),
//       ],
//     );
//   }

//   Widget _buildAllProductsOption(BuildContext context) {
//     return ListTile(
//       leading: Radio<String?>(
//         value: null,
//         groupValue: selectedCollection,
//         activeColor: Appcolors.kprimarycolor,
//         onChanged: (val) {
//           onCollectionSelected(null);
//           Navigator.pop(context);
//         },
//       ),
//       title: const Text(
//         'All Products',
//         style: TextStyle(fontWeight: FontWeight.w600),
//       ),
//       onTap: () {
//         onCollectionSelected(null);
//         Navigator.pop(context);
//       },
//     );
//   }

//   Widget _buildCollectionTile(CollectionModel collection, BuildContext context) {
//     final isSelected = selectedCollection == collection.handle;
//     return ListTile(
//       leading: Radio<String?>(
//         value: collection.handle,
//         groupValue: selectedCollection,
//         activeColor: Appcolors.kprimarycolor,
//         onChanged: (val) {
//           onCollectionSelected(val);
//           Navigator.pop(context);
//         },
//       ),
//       title: Text(
//         collection.title,
//         style: TextStyle(
//           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//       trailing: Text(
//         '${collection.productsCount}',
//         style: TextStyle(
//           color: Colors.grey[600],
//           fontSize: 13,
//         ),
//       ),
//       onTap: () {
//         onCollectionSelected(collection.handle);
//         Navigator.pop(context);
//       },
//     );
//   }
// }
// lib/presentation/widgets/collections_sheet.dart

import 'package:flutter/material.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart'; // ✅ added
import 'package:zestyvibe/data/models/collection_model.dart';

class CollectionsSheet extends StatelessWidget {
  final List<CollectionModel> collections;
  final String? selectedCollection;
  final Function(String?) onCollectionSelected;
  final bool isLoading;

  const CollectionsSheet({
    super.key,
    required this.collections,
    this.selectedCollection,
    required this.onCollectionSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: BorderRadiusStyles.kradius20().topLeft, // ✅ responsive
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : _buildCollectionsList(scrollController, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: ResponsiveUtils.hp(1.2)), // ✅
      width: ResponsiveUtils.wp(14), // ~40
      height: ResponsiveUtils.hp(0.4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadiusStyles.custom(sizeFactor: 0.8), // ✅
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(1.5),
      ),
      child: Row(
        children: [
          TextStyles.subheadline(
            text: 'Categories',
            weight: FontWeight.w600,
          ),
          const Spacer(),
          if (selectedCollection != null)
            TextButton(
              onPressed: () {
                onCollectionSelected(null);
                Navigator.pop(context);
              },
              child: ResponsiveText(
                'Clear',
                sizeFactor: 0.93,
                weight: FontWeight.w500,
                color: Appcolors.kprimarycolor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Appcolors.kprimarycolor,
            ),
          ),
          ResponsiveSizedBox.height20,
          TextStyles.body(
            text: 'Loading collections...',
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsList(
    ScrollController scrollController,
    BuildContext context,
  ) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.hp(1),
      ),
      children: [
        _buildAllProductsOption(context),
        const Divider(height: 1),
        ...collections
            .map(
              (collection) => _buildCollectionTile(collection, context),
            )
            .toList(),
      ],
    );
  }

  Widget _buildAllProductsOption(BuildContext context) {
    return ListTile(
      leading: Radio<String?>(
        value: null,
        groupValue: selectedCollection,
        activeColor: Appcolors.kprimarycolor,
        onChanged: (val) {
          onCollectionSelected(null);
          Navigator.pop(context);
        },
      ),
      title: TextStyles.body(
        text: 'All Products',
        weight: FontWeight.w600,
      ),
      onTap: () {
        onCollectionSelected(null);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCollectionTile(
    CollectionModel collection,
    BuildContext context,
  ) {
    final isSelected = selectedCollection == collection.handle;
    return ListTile(
      leading: Radio<String?>(
        value: collection.handle,
        groupValue: selectedCollection,
        activeColor: Appcolors.kprimarycolor,
        onChanged: (val) {
          onCollectionSelected(val);
          Navigator.pop(context);
        },
      ),
      title: TextStyles.body(
        text: collection.title,
        weight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      trailing: ResponsiveText(
        '${collection.productsCount}',
        sizeFactor: 0.74,
        color: Colors.grey[600],
      ),
      onTap: () {
        onCollectionSelected(collection.handle);
        Navigator.pop(context);
      },
    );
  }
}
