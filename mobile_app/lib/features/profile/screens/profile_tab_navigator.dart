import 'package:flutter/material.dart';
import 'profile_screen.dart';

class ProfileTabNavigator extends StatelessWidget {
  const ProfileTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        );
      },
    );
  }
}
