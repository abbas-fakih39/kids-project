import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_navigator.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/register_success_screen.dart';
import 'features/main/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KitsAndKidsApp(),
    ),
  );
}

class KitsAndKidsApp extends StatelessWidget {
  const KitsAndKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kits & Kids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: appNavigatorKey,
      initialRoute: '/',
      routes: {
        '/':                  (_) => const SplashScreen(),
        '/onboarding':        (_) => const OnboardingScreen(),
        '/login':             (_) => const LoginScreen(),
        '/register':          (_) => const RegisterScreen(),
        '/register-success':  (_) => const RegisterSuccessScreen(),
        '/home':              (_) => const MainShell(),
      },
    );
  }
}
