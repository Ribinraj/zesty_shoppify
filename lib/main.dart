import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';
import 'package:zestyvibe/domain/repositories/pushnotification_controller.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/presentation/blocs/banner_bloc/banner_bloc.dart';
import 'package:zestyvibe/presentation/blocs/bottom_navigation_bloc/bottom_navigation_bloc.dart';
import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';

import 'package:zestyvibe/presentation/blocs/orders_bloc/orders_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_bloc/product_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_detial_bloc/product_detail_bloc.dart';

import 'package:zestyvibe/presentation/screens/splashscreen/splash_screen.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Optional: initialize firebase here if you need (only if you use Firebase in background)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotifications.backgroundMessageHandler(message);
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
        // Initialize Firebase
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize PushNotifications helper (this will request permissions, create channel, etc.)
  // It's okay to await this so notifications are ready by the time the app runs.
  await PushNotifications.instance.init();

  // Optional: request permissions again for iOS if you want explicit control here
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }
  await AppRepo.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ResponsiveUtils().init(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductBloc(repository: AppRepo.instance),
        ),
        BlocProvider(
          create: (context) => ProductDetailBloc(repository: AppRepo.instance),
        ),
        BlocProvider(
          create: (context) => CartBloc(repository: AppRepo.instance),
        ),
        BlocProvider(create: (context) => BottomNavigationBloc()),
        BlocProvider(
          create: (context) => OrdersBloc(repository: AppRepo.instance),
        ),
        BlocProvider(
          create: (context) =>
              AuthBloc(repository: AppRepo.instance)..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => BannerBloc(repository: AppRepo.instance),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
          fontFamily: 'Helvetica',
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          scaffoldBackgroundColor: Appcolors.kbackgroundcolor,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
