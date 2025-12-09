import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/presentation/blocs/bottom_navigation_bloc/bottom_navigation_bloc.dart';


class BottomNavigationWidget extends StatelessWidget {
  final void Function(int)? onTap;
  const BottomNavigationWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Appcolors.kwhitecolor,
            boxShadow: [
              BoxShadow(
                color: Appcolors.kprimarycolor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: state.currentPageIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Appcolors.kwhitecolor,
            selectedItemColor: Appcolors.kprimarycolor,
            unselectedItemColor: Appcolors.kgreyColor.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  IconlyLight.home,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  IconlyBold.home,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  IconlyLight.bag,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  IconlyBold.bag,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  IconlyLight.document,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  IconlyBold.document,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  IconlyLight.profile,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  IconlyBold.profile,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}