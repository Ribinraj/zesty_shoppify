

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  Icons.dashboard_outlined,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  Icons.dashboard_rounded,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.note_add_outlined,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  Icons.note_add_rounded,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.assignment_outlined,
                  size: ResponsiveUtils.wp(7),
                ),
                activeIcon: Icon(
                  Icons.assignment_rounded,
                  size: ResponsiveUtils.wp(7),
                ),
                label: "profile",
              ),
            ],
          ),
        );
      },
    );
  }
}