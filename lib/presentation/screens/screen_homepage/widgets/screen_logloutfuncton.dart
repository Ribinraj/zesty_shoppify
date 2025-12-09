import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        "Logout",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Appcolors.kprimarycolor,
        ),
      ),
      content: Text(
        "Are you sure you want to logout?",
        style: TextStyle(fontSize: ResponsiveUtils.sp(3.2)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(color: Appcolors.kgreyColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Appcolors.kprimarycolor,
          ),
          child: const Text("Logout"),
        ),
      ],
    );
  }
}

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const LogoutConfirmationDialog(),
  );
}
