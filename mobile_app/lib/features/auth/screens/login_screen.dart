import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();

    final success = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 52),

                // ── Logo ──
                const AppLogo(size: 80),
                const SizedBox(height: 28),

                // ── Title ──
                const Text(
                  'Bienvenue sur\nKits & Kids',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3A57),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour commencer',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 36),

                // ── Email field ──
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: Color(0xFF9CA3AF)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez entrer votre email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Password field ──
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Veuillez entrer votre mot de passe' : null,
                ),

                // ── Error banner ──
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      auth.errorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ── Se connecter button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3A57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── "S'inscrire" link ──
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Vous n\'avez pas de compte ? ',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: TextStyle(
                            color: Color(0xFF3C82F5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Terms ──
                Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation\net notre Politique de confidentialité',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.5),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

