import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Onboarding data model
class _OBPage {
  final String title;
  final String description;
  final String imageUrl;

  const _OBPage(this.title, this.description, this.imageUrl);
}

// 3 onboarding slides (replace image URLs with your own assets if preferred)
const _pages = [
  _OBPage(
    'Choisissez',
    'Sélectionnez votre matériel\net vos dates de location sur\nl\'application.',
    'https://images.unsplash.com/photo-1591129938363-f24cb7340dcd?w=1080&q=80',
  ),
  _OBPage(
    'Réservez',
    'Retrait en agence ou livraison à\ndomicile, gare, aéroport\npartout en France.',
    'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=1080&q=80',
  ),
  _OBPage(
    'Profitez',
    'Paiement sécurisé. Le matériel\nvous attend, propre et prêt à\nl\'emploi.',
    'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=1080&q=80',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  Future<void> _next() async {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await _markSeenAndNavigate('/register');
    }
  }

  Future<void> _skip() async => await _markSeenAndNavigate('/login');

  Future<void> _markSeenAndNavigate(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen PageView with background photos
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
          ),

          // "Passer" (Skip) button — top right
          Positioned(
            top: 56,
            right: 28,
            child: GestureDetector(
              onTap: _skip,
              child: const Text(
                'Passer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom: dots + CTA button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 52),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0D1D2E)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Next / Start button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A57),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _current < _pages.length - 1 ? 'Suivant' : 'Commencer',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_current < _pages.length - 1) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right_rounded, size: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Single onboarding page with full-screen image + dark gradient overlay
class _OnboardingPageWidget extends StatelessWidget {
  final _OBPage page;
  const _OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background photo
        Image.network(
          page.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1B3A57)),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : Container(color: Colors.black),
        ),

        // Dark gradient overlay — heavier at bottom (where text lives)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000), // 20% black at top
                Color(0x77000000), // 47% at middle
                Color(0xEE050E18), // 93% dark navy at bottom
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // Title + description — above the dots/button area
        Positioned(
          left: 28,
          right: 28,
          bottom: 185,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                page.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.65,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
