
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zestyvibe/presentation/blocs/bottom_navigation_bloc/bottom_navigation_bloc.dart';
import 'package:zestyvibe/presentation/screens/cart_screenpage/screen_cartpage.dart';
import 'package:zestyvibe/presentation/screens/screen_homepage/screen_homepage.dart';

import 'package:zestyvibe/presentation/screens/screen_mainpage/customnavbar.dart';
import 'package:zestyvibe/presentation/screens/screen_orderspage/screen_orderspage.dart';

import 'package:zestyvibe/presentation/screens/screen_profilepage/screen_profilepage.dart';


class ScreenMainPage extends StatefulWidget {
  const ScreenMainPage({super.key});

  @override
  State<ScreenMainPage> createState() => _ScreenMainPageState();
}

class _ScreenMainPageState extends State<ScreenMainPage> {
  final List<Widget> _pages = [ShopifyHomePage(),
CartScreen(),
OrdersScreen(),
ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return 
         Scaffold(
            //backgroundColor: const Color.fromARGB(255, 248, 232, 227),
            body: _pages[state.currentPageIndex],
            bottomNavigationBar: BottomNavigationWidget(
              onTap: (index) {
                context.read<BottomNavigationBloc>().add(
                  NavigateToPageEvent(pageIndex: index),
                );
              },
            ),
          );
        
      },
    );
  }
}
