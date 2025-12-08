import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';

class ShopifyHomeShimmer extends StatelessWidget {
  const ShopifyHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Search bar shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.wp(4),
              vertical: ResponsiveUtils.hp(1.2),
            ),
            child: _shimmerContainer(
              height: ResponsiveUtils.hp(5.5),
              borderRadius: BorderRadiusStyles.kradius10(),
            ),
          ),
        ),

        // Banner shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.wp(4),
              vertical: ResponsiveUtils.hp(0.5),
            ),
            child: _shimmerContainer(
              height: ResponsiveUtils.hp(24),
              borderRadius: BorderRadiusStyles.kradius20(),
            ),
          ),
        ),

        // Toolbar shimmer (3 buttons)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.wp(4),
              vertical: ResponsiveUtils.hp(1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _shimmerContainer(
                    height: ResponsiveUtils.hp(4.8),
                    borderRadius: BorderRadiusStyles.kradius10(),
                  ),
                ),
                ResponsiveSizedBox.width5,
                Expanded(
                  child: _shimmerContainer(
                    height: ResponsiveUtils.hp(4.8),
                    borderRadius: BorderRadiusStyles.kradius10(),
                  ),
                ),
                ResponsiveSizedBox.width5,
                Expanded(
                  child: _shimmerContainer(
                    height: ResponsiveUtils.hp(4.8),
                    borderRadius: BorderRadiusStyles.kradius10(),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid shimmer for products
        SliverPadding(
          padding: EdgeInsets.all(ResponsiveUtils.wp(4)),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ProductCardShimmer(),
              childCount: 8, // show 8 skeleton items
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerContainer({
    double? height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadiusStyles.kradius10(),
        ),
      ),
    );
  }
}

class _ProductCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadiusStyles.kradius10(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadiusStyles.kradius10(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.wp(3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor
                  Container(
                    height: ResponsiveUtils.hp(1),
                    width: ResponsiveUtils.wp(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadiusStyles.kradius5(),
                    ),
                  ),
                  ResponsiveSizedBox.height5,
                  // Title line 1
                  Container(
                    height: ResponsiveUtils.hp(1.2),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadiusStyles.kradius5(),
                    ),
                  ),
                  ResponsiveSizedBox.height5,
                  // Title line 2
                  Container(
                    height: ResponsiveUtils.hp(1.2),
                    width: ResponsiveUtils.wp(40),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadiusStyles.kradius5(),
                    ),
                  ),
                  ResponsiveSizedBox.height10,
                  // Price row
                  Row(
                    children: [
                      Container(
                        height: ResponsiveUtils.hp(1.4),
                        width: ResponsiveUtils.wp(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadiusStyles.kradius5(),
                        ),
                      ),
                      ResponsiveSizedBox.width5,
                      Container(
                        height: ResponsiveUtils.hp(1.2),
                        width: ResponsiveUtils.wp(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadiusStyles.kradius5(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
