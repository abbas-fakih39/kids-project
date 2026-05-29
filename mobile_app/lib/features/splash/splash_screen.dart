import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/widgets/app_logo.dart';
import '../auth/providers/auth_provider.dart';

// Splash animation sequence (matching maquette frames):
// 1. Black screen
// 2. Logo drops from top to center (gravity ease-in)
// 3. Logo bounces (scale up then settle)
// 4. "Kits & Kids" text fades in from the right
// 5. Hold → Navigate

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _dropCtrl;
  late final AnimationController _bounceCtrl;
  late final AnimationController _textCtrl;

  late final Animation<double> _dropAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // --- Drop: logo falls from top ---
    _dropCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _dropAnim = Tween<double>(begin: -0.75, end: 0.0).animate(
      CurvedAnimation(parent: _dropCtrl, curve: Curves.easeIn),
    );

    // --- Bounce: land then settle ---
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.22), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.22, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    // --- Text: fade + slide from right ---
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _dropCtrl.forward();
    await _bounceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    final token = await SecureStorage.getToken();

    if (!mounted) return;

    if (token != null) {
      // Fire-and-forget: populate AuthProvider._user so ProfileScreen shows name/email
      context.read<AuthProvider>().loadUser();
      Navigator.pushReplacementNamed(context, '/home');
    } else if (!seenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _dropCtrl.dispose();
    _bounceCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_dropCtrl, _bounceCtrl, _textCtrl]),
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, _dropAnim.value * h),
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo icon (white scheme on black bg)
                    const AppLogo(size: 52, whiteScheme: true),
                    const SizedBox(width: 10),
                    // Text slides in after bounce
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: const Text(
                          'Kits & Kids',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
