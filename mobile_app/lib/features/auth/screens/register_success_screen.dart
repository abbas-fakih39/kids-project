import 'package:flutter/material.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Checkmark ──
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF22C55E),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Title ──
                const Text(
                  'Compte créé avec succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B3A57),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Subtitle ──
                const Text(
                  'Bienvenue dans la famille Kits & Kids. Vous pouvez maintenant vous connecter et commencer à louer vos équipements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 52),

                // ── CTA ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3A57),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Voir les équipements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Login link ──
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Se connecter →',
                    style: TextStyle(
                      color: Color(0xFF3C82F5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
