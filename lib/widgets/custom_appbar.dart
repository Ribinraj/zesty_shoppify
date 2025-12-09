import 'package:flutter/material.dart';
import 'package:zestyvibe/core/appconstants.dart';
import 'package:zestyvibe/core/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 227, 224, 224),
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.white,

      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Image.asset(
            Appconstants.applogo,
            height: 35,
            fit: BoxFit.contain,
          ),
        ),
      ),

      // TITLE PARAMETER
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontSize: 17,
          color: Appcolors.kprimarycolor,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
