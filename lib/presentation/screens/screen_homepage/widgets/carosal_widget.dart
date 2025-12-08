// // lib/presentation/widgets/banner_carousel_widget.dart

// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/data/models/bannermodel.dart';



// class BannerCarouselWidget extends StatefulWidget {
//   final List<BannerModel> banners;
//   final Function(String? collectionHandle)? onBannerTap;

//   const BannerCarouselWidget({
//     super.key,
//     required this.banners,
//     this.onBannerTap,
//   });

//   @override
//   State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
// }

// class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
//   int _currentIndex = 0;
//   final CarouselSliderController _carouselController = CarouselSliderController();

//   @override
//   Widget build(BuildContext context) {
//     if (widget.banners.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       children: [
//         CarouselSlider.builder(
//           carouselController: _carouselController,
//           itemCount: widget.banners.length,
//           itemBuilder: (context, index, realIndex) {
//             final banner = widget.banners[index];
//             return _buildBannerCard(banner);
//           },
//           options: CarouselOptions(
//             height: 200,
//             viewportFraction: 0.92,
//             autoPlay: widget.banners.length > 1,
//             autoPlayInterval: const Duration(seconds: 5),
//             autoPlayAnimationDuration: const Duration(milliseconds: 800),
//             autoPlayCurve: Curves.fastOutSlowIn,
//             enlargeCenterPage: true,
//             enlargeFactor: 0.15,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//         ),
//         if (widget.banners.length > 1) ...[
//           const SizedBox(height: 12),
//           _buildIndicators(),
//         ],
//         const SizedBox(height: 8),
//       ],
//     );
//   }

//   Widget _buildBannerCard(BannerModel banner) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Background Image
//             CachedNetworkImage(
//               imageUrl: banner.imageUrl,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => Container(
//                 color: Colors.grey[200],
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Appcolors.kprimarycolor,
//                     ),
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 color: Colors.grey[200],
//                 child: Icon(
//                   Icons.broken_image_outlined,
//                   size: 60,
//                   color: Colors.grey[400],
//                 ),
//               ),
//             ),
            
//             // Gradient Overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withOpacity(0.7),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Content
//             Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () => widget.onBannerTap?.call(banner.actionHandle),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         banner.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               offset: Offset(0, 1),
//                               blurRadius: 3,
//                               color: Colors.black45,
//                             ),
//                           ],
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         banner.subtitle,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           shadows: [
//                             Shadow(
//                               offset: Offset(0, 1),
//                               blurRadius: 3,
//                               color: Colors.black45,
//                             ),
//                           ],
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Appcolors.kprimarycolor,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           banner.actionText,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIndicators() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: widget.banners.asMap().entries.map((entry) {
//         final isActive = _currentIndex == entry.key;
//         return GestureDetector(
//           onTap: () => _carouselController.animateToPage(entry.key),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: isActive ? 24 : 8,
//             height: 8,
//             margin: const EdgeInsets.symmetric(horizontal: 4),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(4),
//               color: isActive 
//                   ? Appcolors.kprimarycolor 
//                   : Colors.grey[300],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
// lib/presentation/widgets/banner_carousel_widget.dart

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart'; // ✅ added
import 'package:zestyvibe/data/models/bannermodel.dart';

class BannerCarouselWidget extends StatefulWidget {
  final List<BannerModel> banners;
  final Function(String? collectionHandle)? onBannerTap;

  const BannerCarouselWidget({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            return _buildBannerCard(banner);
          },
          options: CarouselOptions(
            height: ResponsiveUtils.hp(24), // ✅ responsive height
            viewportFraction: 0.92,
            autoPlay: widget.banners.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          ResponsiveSizedBox.height10, // instead of 12
          _buildIndicators(),
        ],
        ResponsiveSizedBox.height10, // instead of 8
      ],
    );
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(1.2), // ✅ instead of 4
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusStyles.kradius20(), // ✅ responsive radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusStyles.kradius20(), // ✅
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Appcolors.kprimarycolor,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image_outlined,
                  size: ResponsiveUtils.sp(7), // ✅ responsive
                  color: Colors.grey[400],
                ),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onBannerTap?.call(banner.actionHandle),
                child: Padding(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.wp(5), // ✅ instead of 20
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        banner.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.sp(4.5), // ✅ ~24
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ResponsiveSizedBox.height5,
                      // Subtitle
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.sp(2.8), // ✅ ~14
                          fontWeight: FontWeight.w400,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ResponsiveSizedBox.height10,
                      // CTA Button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(4),
                          vertical: ResponsiveUtils.hp(0.8),
                        ),
                        decoration: BoxDecoration(
                          color: Appcolors.kprimarycolor,
                          borderRadius: BorderRadiusStyles.kradius10(), // ✅
                        ),
                        child: Text(
                          banner.actionText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.sp(2.8), // ✅ ~13
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        final isActive = _currentIndex == entry.key;
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? ResponsiveUtils.wp(6) : ResponsiveUtils.wp(2.5),
            height: ResponsiveUtils.hp(0.7),
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.wp(1),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusStyles.kradius5(), // ✅
              color: isActive
                  ? Appcolors.kprimarycolor
                  : Colors.grey[300],
            ),
          ),
        );
      }).toList(),
    );
  }
}

