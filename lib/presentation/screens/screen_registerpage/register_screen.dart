// // lib/presentation/screens/auth/register_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';
// import 'package:zestyvibe/widgets/customnavigation.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _firstCtl = TextEditingController();
//   final _lastCtl = TextEditingController();
//   final _emailCtl = TextEditingController();
//   final _passCtl = TextEditingController();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register'), backgroundColor: Appcolors.kprimarycolor),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: BlocListener<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthLoading) setState(() => _loading = true);
//             else setState(() => _loading = false);

//             if (state is AuthAuthenticated) {
//        CustomNavigation.pushReplaceWithTransition(context,ScreenMainPage());
//             }

//             if (state is AuthError) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
//             }
//           },
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(controller: _firstCtl, decoration: const InputDecoration(labelText: 'First name')),
//                 const SizedBox(height: 12),
//                 TextField(controller: _lastCtl, decoration: const InputDecoration(labelText: 'Last name')),
//                 const SizedBox(height: 12),
//                 TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
//                 const SizedBox(height: 12),
//                 TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _loading
//                       ? null
//                       : () {
//                           final first = _firstCtl.text.trim();
//                           final last = _lastCtl.text.trim();
//                           final email = _emailCtl.text.trim();
//                           final pass = _passCtl.text;
//                           context.read<AuthBloc>().add(AuthRegisterRequested(
//                                 firstName: first,
//                                 lastName: last.isEmpty ? null : last,
//                                 email: email,
//                                 password: pass,
//                               ));
//                         },
//                   style: ElevatedButton.styleFrom(backgroundColor: Appcolors.kprimarycolor),
//                   child: _loading ? const CircularProgressIndicator() : const Text('Register'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';
import 'package:zestyvibe/widgets/customnavigation.dart';
import 'package:zestyvibe/widgets/custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtl = TextEditingController();
  final _lastCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstCtl.dispose();
    _lastCtl.dispose();
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
              message: 'Registration successful!',
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
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(4),
                  vertical: ResponsiveUtils.hp(2),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Appcolors.kwhitecolor,
                        borderRadius: BorderRadiusStyles.kradius10(),
                        boxShadow: [
                          BoxShadow(
                            color: Appcolors.kblackcolor.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Appcolors.kprimarycolor,
                          size: ResponsiveUtils.sp(5),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.wp(4)),
                    TextStyles.subheadline(
                      text: 'Create Account',
                      color: Appcolors.kprimarycolor,
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: ResponsiveUtils.hp(2)),

                      // Logo Section
                      Center(
                        child: Container(
                          width: ResponsiveUtils.wp(25),
                          height: ResponsiveUtils.wp(25),
                          decoration: BoxDecoration(
                            color: Appcolors.kprimarycolor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add,
                            size: ResponsiveUtils.wp(12),
                            color: Appcolors.kprimarycolor,
                          ),
                        ),
                      ),

                      SizedBox(height: ResponsiveUtils.hp(3)),

                      // Subtitle
                      Center(
                        child: TextStyles.body(
                          text: 'Fill in your details to get started',
                          color: Appcolors.kgreyColor,
                          weight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: ResponsiveUtils.hp(4)),

                      // First Name Field
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
                          controller: _firstCtl,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(3.5),
                            color: Appcolors.kblackcolor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'First name',
                            labelStyle: TextStyle(
                              fontSize: ResponsiveUtils.sp(3.5),
                              color: Appcolors.kgreyColor,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
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

                      SizedBox(height: ResponsiveUtils.hp(2)),

                      // Last Name Field
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
                          controller: _lastCtl,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.sp(3.5),
                            color: Appcolors.kblackcolor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            labelStyle: TextStyle(
                              fontSize: ResponsiveUtils.sp(3.5),
                              color: Appcolors.kgreyColor,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
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

                      SizedBox(height: ResponsiveUtils.hp(2)),

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

                      SizedBox(height: ResponsiveUtils.hp(2)),

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

                      // Register Button
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
                                  final first = _firstCtl.text.trim();
                                  final last = _lastCtl.text.trim();
                                  final email = _emailCtl.text.trim();
                                  final pass = _passCtl.text;
                                  context.read<AuthBloc>().add(
                                    AuthRegisterRequested(
                                      firstName: first,
                                      lastName: last.isEmpty ? null : last,
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
                                  text: 'Register',
                                  color: Appcolors.kwhitecolor,
                                  weight: FontWeight.bold,
                                ),
                        ),
                      ),

                      SizedBox(height: ResponsiveUtils.hp(2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
