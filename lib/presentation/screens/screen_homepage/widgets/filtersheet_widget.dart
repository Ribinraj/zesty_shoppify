// // lib/presentation/widgets/filter_sheet.dart

// import 'package:flutter/material.dart';
// import 'package:zestyvibe/core/colors.dart';


// class FilterSheet extends StatefulWidget {
//   final bool initialAvailableOnly;
//   final String? initialMinPrice;
//   final String? initialMaxPrice;
//   final Function(bool availableOnly, String? minPrice, String? maxPrice) onApply;

//   const FilterSheet({
//     super.key,
//     required this.initialAvailableOnly,
//     this.initialMinPrice,
//     this.initialMaxPrice,
//     required this.onApply,
//   });

//   @override
//   State<FilterSheet> createState() => _FilterSheetState();
// }

// class _FilterSheetState extends State<FilterSheet> {
//   late bool _availableOnly;
//   late TextEditingController _minPriceController;
//   late TextEditingController _maxPriceController;

//   @override
//   void initState() {
//     super.initState();
//     _availableOnly = widget.initialAvailableOnly;
//     _minPriceController = TextEditingController(text: widget.initialMinPrice);
//     _maxPriceController = TextEditingController(text: widget.initialMaxPrice);
//   }

//   @override
//   void dispose() {
//     _minPriceController.dispose();
//     _maxPriceController.dispose();
//     super.dispose();
//   }

//   void _clearAll() {
//     setState(() {
//       _availableOnly = false;
//       _minPriceController.clear();
//       _maxPriceController.clear();
//     });
//   }

//   void _apply() {
//     widget.onApply(
//       _availableOnly,
//       _minPriceController.text.isEmpty ? null : _minPriceController.text,
//       _maxPriceController.text.isEmpty ? null : _maxPriceController.text,
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,
//       minChildSize: 0.5,
//       maxChildSize: 0.85,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               _buildHandle(),
//               _buildHeader(),
//               const Divider(height: 1),
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     _buildAvailabilityFilter(),
//                     const SizedBox(height: 16),
//                     _buildPriceRangeFilter(),
//                   ],
//                 ),
//               ),
//               _buildActionButtons(),
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

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           const Text(
//             'Filters',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () {
//               _clearAll();
//               _apply();
//             },
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAvailabilityFilter() {
//     return _buildFilterSection(
//       'Availability',
//       [
//         CheckboxListTile(
//           title: const Text('In Stock Only'),
//           value: _availableOnly,
//           onChanged: (val) {
//             setState(() => _availableOnly = val ?? false);
//           },
//           activeColor: Appcolors.kprimarycolor,
//           contentPadding: EdgeInsets.zero,
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceRangeFilter() {
//     return _buildFilterSection(
//       'Price Range',
//       [
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _minPriceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Min',
//                   prefixText: '₹',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextField(
//                 controller: _maxPriceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Max',
//                   prefixText: '₹',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 8),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () => Navigator.pop(context),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Cancel'),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _apply,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Appcolors.kprimarycolor,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Apply Filters'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
////////////////////////////
// lib/presentation/widgets/filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart'; // ✅ added

class FilterSheet extends StatefulWidget {
  final bool initialAvailableOnly;
  final String? initialMinPrice;
  final String? initialMaxPrice;
  final Function(bool availableOnly, String? minPrice, String? maxPrice)
      onApply;

  const FilterSheet({
    super.key,
    required this.initialAvailableOnly,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late bool _availableOnly;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _availableOnly = widget.initialAvailableOnly;
    _minPriceController = TextEditingController(text: widget.initialMinPrice);
    _maxPriceController = TextEditingController(text: widget.initialMaxPrice);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _availableOnly = false;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    widget.onApply(
      _availableOnly,
      _minPriceController.text.isEmpty ? null : _minPriceController.text,
      _maxPriceController.text.isEmpty ? null : _maxPriceController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.85,
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
              _buildHeader(),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(ResponsiveUtils.wp(4)), // ✅
                  children: [
                    _buildAvailabilityFilter(),
                    ResponsiveSizedBox.height20,
                    _buildPriceRangeFilter(),
                  ],
                ),
              ),
              _buildActionButtons(),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(4),
        vertical: ResponsiveUtils.hp(1.5),
      ),
      child: Row(
        children: [
          TextStyles.subheadline(
            text: 'Filters',
            weight: FontWeight.w600,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              _clearAll();
              _apply();
            },
            child: ResponsiveText(
              'Clear All',
              sizeFactor: 0.93,
              weight: FontWeight.w500,
              color: Appcolors.kprimarycolor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    return _buildFilterSection(
      'Availability',
      [
        CheckboxListTile(
          title: TextStyles.body(
            text: 'In Stock Only',
            weight: FontWeight.w500,
          ),
          value: _availableOnly,
          onChanged: (val) {
            setState(() => _availableOnly = val ?? false);
          },
          activeColor: Appcolors.kprimarycolor,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return _buildFilterSection(
      'Price Range',
      [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                decoration: InputDecoration(
                  labelText: 'Min',
                  labelStyle: TextStyle(
                    fontSize: ResponsiveUtils.sp(2.6),
                  ),
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadiusStyles.kradius10(), // ✅
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(2.8),
                ),
              ),
            ),
            ResponsiveSizedBox.width10, // ✅ instead of 16
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                decoration: InputDecoration(
                  labelText: 'Max',
                  labelStyle: TextStyle(
                    fontSize: ResponsiveUtils.sp(2.6),
                  ),
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadiusStyles.kradius10(), // ✅
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(2.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextStyles.body(
          text: title,
          weight: FontWeight.w600,
        ),
        ResponsiveSizedBox.height10,
        ...children,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.hp(1.8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(), // ✅
                ),
              ),
              child: ResponsiveText(
                'Cancel',
                sizeFactor: 0.93,
                weight: FontWeight.w500,
              ),
            ),
          ),
          ResponsiveSizedBox.width10,
          Expanded(
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.kprimarycolor,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.hp(1.8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusStyles.kradius10(), // ✅
                ),
              ),
              child: ResponsiveText(
                'Apply Filters',
                sizeFactor: 0.93,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
