import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _pwVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();

    final success = await context.read<AuthProvider>().register(
          prenom: _prenomCtrl.text.trim(),
          nom: _nomCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/register-success');
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
                const SizedBox(height: 48),

                // ── Logo ──
                const AppLogo(size: 72),
                const SizedBox(height: 24),

                // ── Title ──
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B3A57),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rejoignez-nous dès maintenant',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 30),

                // ── Prénom ──
                _Field(
                  ctrl: _prenomCtrl,
                  hint: 'Prénom',
                  icon: Icons.person_outline_rounded,
                  action: TextInputAction.next,
                  validator: (v) => v!.isEmpty ? 'Veuillez entrer votre prénom' : null,
                ),
                const SizedBox(height: 12),

                // ── Nom ──
                _Field(
                  ctrl: _nomCtrl,
                  hint: 'Nom',
                  icon: Icons.person_outline_rounded,
                  action: TextInputAction.next,
                  validator: (v) => v!.isEmpty ? 'Veuillez entrer votre nom' : null,
                ),
                const SizedBox(height: 12),

                // ── Email ──
                _Field(
                  ctrl: _emailCtrl,
                  hint: 'Email',
                  icon: Icons.mail_outline_rounded,
                  type: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez entrer votre email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Téléphone ──
                _Field(
                  ctrl: _phoneCtrl,
                  hint: 'Numéro de téléphone',
                  icon: Icons.phone_outlined,
                  type: TextInputType.phone,
                  action: TextInputAction.next,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)) {
                      return 'Numéro de téléphone invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Mot de passe ──
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_pwVisible,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _pwVisible = !_pwVisible),
                      icon: Icon(
                        _pwVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez entrer un mot de passe';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) return 'Au moins une majuscule requise';
                    if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) return 'Au moins un chiffre requis';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Confirmer mot de passe ──
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: !_confirmVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    hintText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF)),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
                      icon: Icon(
                        _confirmVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez confirmer le mot de passe';
                    if (v != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
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
                const SizedBox(height: 24),

                // ── Créer mon compte button ──
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3A57),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            'Créer mon compte',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── "Se connecter" link ──
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Vous avez déjà un compte ? ',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Se connecter',
                          style: TextStyle(
                            color: Color(0xFF3C82F5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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

// Simple text field wrapper to reduce repetition
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType? type;
  final TextInputAction? action;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.type,
    this.action,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      textInputAction: action,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
      ),
      validator: validator,
    );
  }
}
