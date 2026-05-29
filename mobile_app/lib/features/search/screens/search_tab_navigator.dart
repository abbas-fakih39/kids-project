import 'package:flutter/material.dart';
import 'search_screen.dart';

class SearchTabNavigator extends StatelessWidget {
  const SearchTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        );
      },
    );
  }
}
