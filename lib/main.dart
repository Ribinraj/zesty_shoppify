import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/core/colors.dart';
import 'package:zestyvibe/core/responsiveutils.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';
import 'package:zestyvibe/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:zestyvibe/presentation/blocs/bottom_navigation_bloc/bottom_navigation_bloc.dart';
import 'package:zestyvibe/presentation/blocs/cart_bloc/cart_bloc.dart';
import 'package:zestyvibe/presentation/blocs/orders_bloc/orders_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_bloc/product_bloc.dart';
import 'package:zestyvibe/presentation/blocs/product_detial_bloc/product_detail_bloc.dart';

import 'package:zestyvibe/presentation/screens/splashscreen/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        BlocProvider(create: (context) => ProductDetailBloc(repository: AppRepo.instance)),
                BlocProvider(create: (context) => CartBloc(repository: AppRepo.instance)),
                        BlocProvider(create: (context) => BottomNavigationBloc()),
                         BlocProvider(create: (context) => OrdersBloc(repository: AppRepo.instance)),
                           BlocProvider(create: (context) => AuthBloc(repository: AppRepo.instance)..add(AuthCheckRequested())),
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
