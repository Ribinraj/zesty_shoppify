// // lib/presentation/widgets/sort_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/data/models/collection_model.dart';



// class SortSheet extends StatelessWidget {
//   final ProductSortKey currentSortKey;
//   final Function(ProductSortKey) onSortSelected;

//   const SortSheet({
//     super.key,
//     required this.currentSortKey,
//     required this.onSortSelected,
//   });

//   String _getSortLabel(ProductSortKey key) {
//     switch (key) {
//       case ProductSortKey.relevance:
//         return 'Relevance';
//       case ProductSortKey.bestSelling:
//         return 'Best Selling';
//       case ProductSortKey.price:
//         return 'Price: Low to High';
//       case ProductSortKey.created:
//         return 'Newest First';
//       case ProductSortKey.title:
//         return 'Alphabetical';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildHandle(),
//           _buildHeader(context),
//           ...ProductSortKey.values.map((key) {
//             final isSelected = currentSortKey == key;
//             return ListTile(
//               leading: Radio<ProductSortKey>(
//                 value: key,
//                 groupValue: currentSortKey,
//                 activeColor: Appcolors.kprimarycolor,
//                 onChanged: (val) {
//                   if (val != null) {
//                     onSortSelected(val);
//                     Navigator.pop(context);
//                   }
//                 },
//               ),
//               title: Text(
//                 _getSortLabel(key),
//                 style: TextStyle(
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//               onTap: () {
//                 onSortSelected(key);
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//           const SizedBox(height: 16),
//         ],
//       ),
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
//             'Sort By',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/presentation/widgets/sort_sheet.dart

import 'package:flutter/material.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart'; // ✅ added
import 'package:zestyvibe/data/models/collection_model.dart';

class SortSheet extends StatelessWidget {
  final ProductSortKey currentSortKey;
  final Function(ProductSortKey) onSortSelected;

  const SortSheet({
    super.key,
    required this.currentSortKey,
    required this.onSortSelected,
  });

  String _getSortLabel(ProductSortKey key) {
    switch (key) {
      case ProductSortKey.relevance:
        return 'Relevance';
      case ProductSortKey.bestSelling:
        return 'Best Selling';
      case ProductSortKey.price:
        return 'Price: Low to High';
      case ProductSortKey.created:
        return 'Newest First';
      case ProductSortKey.title:
        return 'Alphabetical';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          ...ProductSortKey.values.map((key) {
            final isSelected = currentSortKey == key;
            return ListTile(
              leading: Radio<ProductSortKey>(
                value: key,
                groupValue: currentSortKey,
                activeColor: Appcolors.kprimarycolor,
                onChanged: (val) {
                  if (val != null) {
                    onSortSelected(val);
                    Navigator.pop(context);
                  }
                },
              ),
              title: TextStyles.body(
                text: _getSortLabel(key),
                weight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onTap: () {
                onSortSelected(key);
                Navigator.pop(context);
              },
            );
          }).toList(),
          ResponsiveSizedBox.height20, // ✅ instead of SizedBox(height: 16)
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: ResponsiveUtils.hp(1.2)), // ✅ responsive
      width: ResponsiveUtils.wp(14), // ~40 on many devices
      height: ResponsiveUtils.hp(0.4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadiusStyles.custom(
          sizeFactor: 0.8, // ✅ small pill-like
        ),
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
            text: 'Sort By',
            weight: FontWeight.w600,
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText(
              'Done',
              sizeFactor: 0.93,
              weight: FontWeight.w500,
              color: Appcolors.kprimarycolor,
            ),
          ),
        ],
      ),
    );
  }
}
