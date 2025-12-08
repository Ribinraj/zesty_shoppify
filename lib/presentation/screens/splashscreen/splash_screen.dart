// // lib/presentation/screens/splash/splash_screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:zestyvibe/core/colors.dart';
// import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
// import 'package:zestyvibe/presentation/screens/screen_loginpage/login_screen.dart';

// import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _logoController;
//   late Animation<double> _logoAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // subtle animation
//     _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000));
//     _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack);
//     _logoController.forward();

//     // Ask AuthBloc to check stored auth state (AuthCheckRequested already triggered in main provider,
//     // but we still listen and wait a bit for UX)
//     // We'll set a timeout fallback to avoid stuck state.
//     Timer(const Duration(milliseconds: 5000), () {
//       // If bloc hasn't emitted, we rely on listener below to navigate eventually.
//       // No additional action required here.
//     });
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     super.dispose();
//   }

//   // Navigation helpers
//   void _goToMain() {
//     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ScreenMainPage()));
//   }

//   void _goToLogin() {
//     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         // when auth check completes, navigate accordingly
//         if (state is AuthAuthenticated) {
//           _goToMain();
//         } else if (state is AuthUnauthenticated) {
//           _goToLogin();
//         } else if (state is AuthError) {
//           // fallback to login if any error
//           _goToLogin();
//         }
//       },
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFF8A65), Color(0xFFD84315)], // warm orange to deep red
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: SafeArea(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ScaleTransition(
//                     scale: _logoAnimation,
//                     child: Container(
//                       width: 140,
//                       height: 140,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8)),
//                         ],
//                         gradient: const LinearGradient(colors: [Colors.white, Color(0xFFFFEDE8)]),
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Zesty',
//                           style: TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: Appcolors.kprimarycolor,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                   Text(
//                     'ZestyVibe',
//                     style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.6),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Shop the vibe — quick & simple',
//                     style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 40),

//                   // subtle progress indicator
//                   const SizedBox(
//                     width: 100,
//                     child: LinearProgressIndicator(
//                       backgroundColor: Colors.white24,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/presentation/screens/splash/splash_screen.dart

// lib/presentation/screens/splash/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zestyvibe/core/appconstants.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/constants.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/presentation/screens/screen_mainpage/screen_mainpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  double _progress = 0.0;
  Timer? _progressTimer;

  final int _totalDurationMs = 2000;
  final int _tickMs = 40;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    final int ticks = (_totalDurationMs / _tickMs).round();
    int currentTick = 0;

    _progressTimer = Timer.periodic(Duration(milliseconds: _tickMs), (timer) {
      currentTick++;
      final newProgress = (currentTick / ticks).clamp(0.0, 1.0);

      setState(() {
        _progress = newProgress;
      });

      if (currentTick >= ticks) {
        timer.cancel();

        // ⭐ Navigation added back here
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ScreenMainPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Appcolors.kprimarycolor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const Spacer(), // pushes content to center

            // ⭐ Centered logo + title block
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: ResponsiveUtils.wp(40),
                  child: Image.asset(
                    Appconstants.applogo,
                    fit: BoxFit.contain,
                  ),
                ),
                ResponsiveSizedBox.height15,
                TextStyles.headline(
                  text: "ZestyVibe",
                  color: Appcolors.kprimarycolor,
                ),
              ],
            ),
SizedBox(height: ResponsiveUtils.hp(20),),

           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 3,
                  backgroundColor: Colors.orange.shade50,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),

            ResponsiveSizedBox.height10,

            Opacity(
              opacity: 0.85,
              child: Text(
                _progress < 1.0 ? "Loading..." : "Starting…",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),

           SizedBox(height: ResponsiveUtils.hp(15)), // bottom padding
          ],
        ),
      ),
    );
  }
}
