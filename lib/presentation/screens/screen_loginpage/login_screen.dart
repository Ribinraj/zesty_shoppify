// // lib/presentation/screens/auth/login_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
// import 'package:zestyvibe/core/colors.dart';

// import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';
// import 'package:zestyvibe/presentation/screens/screen_registerpage/register_screen.dart';
// import 'package:zestyvibe/widgets/customnavigation.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailCtl = TextEditingController();
//   final _passCtl = TextEditingController();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login'), backgroundColor: Appcolors.kprimarycolor),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: BlocListener<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthLoading) setState(() => _loading = true);
//             else setState(() => _loading = false);

//             if (state is AuthAuthenticated) {
//             CustomNavigation.pushReplaceWithTransition(context, ScreenMainPage());
//             }

//             if (state is AuthError) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
//             }
//           },
//           child: Column(
//             children: [
//               TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
//               const SizedBox(height: 12),
//               TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _loading
//                     ? null
//                     : () {
//                         final email = _emailCtl.text.trim();
//                         final pass = _passCtl.text;
//                         context.read<AuthBloc>().add(AuthLoginRequested(email: email, password: pass));
//                       },
//                 style: ElevatedButton.styleFrom(backgroundColor: Appcolors.kprimarycolor),
//                 child: _loading ? const CircularProgressIndicator() : const Text('Login'),
//               ),
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
//                 },
//                 child: const Text("Don't have account? Register"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
/////////////////////////////
// lib/presentation/screens/auth/login_screen.dart
// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/appconstants.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';

import 'package:zestyvibe/presentation/screens/screen_registerpage/register_screen.dart';
import 'package:zestyvibe/widgets/customnavigation.dart';
import 'package:zestyvibe/widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.kbackgroundcolor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _loading = true);
          } else {
            setState(() => _loading = false);
          }

          if (state is AuthAuthenticated) {
            CustomSnackbar.show(
              context,
              message: 'Login successful!',
              type: SnackbarType.success,
            );
            navigateToMainPage(context, 3);
          }

          if (state is AuthError) {
            CustomSnackbar.show(
              context,
              message: state.message,
              type: SnackbarType.error,
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.wp(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Section
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: ResponsiveUtils.wp(35),
                      height: ResponsiveUtils.wp(35),
                      decoration: BoxDecoration(
                        color: Appcolors.kwhitecolor,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        Appconstants.applogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(4)),

                  // Welcome Text
                  Center(
                    child: TextStyles.headline(
                      text: 'Welcome Back!',
                      color: Appcolors.kprimarycolor,
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(1)),

                  Center(
                    child: TextStyles.body(
                      text: 'Sign in to continue',
                      color: Appcolors.kgreyColor,
                      weight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(5)),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Appcolors.kwhitecolor,
                      borderRadius: BorderRadiusStyles.kradius15(),
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors.kblackcolor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(3.5),
                        color: Appcolors.kblackcolor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.sp(3.5),
                          color: Appcolors.kgreyColor,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Appcolors.kprimarycolor,
                          size: ResponsiveUtils.sp(5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadiusStyles.kradius15(),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Appcolors.kwhitecolor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(4),
                          vertical: ResponsiveUtils.hp(2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(2.5)),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Appcolors.kwhitecolor,
                      borderRadius: BorderRadiusStyles.kradius15(),
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors.kblackcolor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passCtl,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.sp(3.5),
                        color: Appcolors.kblackcolor,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: ResponsiveUtils.sp(3.5),
                          color: Appcolors.kgreyColor,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Appcolors.kprimarycolor,
                          size: ResponsiveUtils.sp(5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Appcolors.kgreyColor,
                            size: ResponsiveUtils.sp(5),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadiusStyles.kradius15(),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Appcolors.kwhitecolor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(4),
                          vertical: ResponsiveUtils.hp(2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(4)),

                  // Login Button
                  Container(
                    height: ResponsiveUtils.hp(6.5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Appcolors.kprimarycolor,
                          Appcolors.kprimarycolor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadiusStyles.kradius15(),
                      boxShadow: [
                        BoxShadow(
                          color: Appcolors.kprimarycolor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              final email = _emailCtl.text.trim();
                              final pass = _passCtl.text;
                              context.read<AuthBloc>().add(
                                AuthLoginRequested(
                                  email: email,
                                  password: pass,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusStyles.kradius15(),
                        ),
                      ),
                      child: _loading
                          ? SizedBox(
                              height: ResponsiveUtils.sp(5),
                              width: ResponsiveUtils.sp(5),
                              child: const CircularProgressIndicator(
                                color: Appcolors.kwhitecolor,
                                strokeWidth: 2.5,
                              ),
                            )
                          : TextStyles.subheadline(
                              text: 'Login',
                              color: Appcolors.kwhitecolor,
                              weight: FontWeight.bold,
                            ),
                    ),
                  ),

                  SizedBox(height: ResponsiveUtils.hp(3)),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextStyles.body(
                        text: "Don't have account? ",
                        color: Appcolors.kgreyColor,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: TextStyles.body(
                          text: 'Register',
                          color: Appcolors.kprimarycolor,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
