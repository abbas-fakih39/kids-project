import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal info
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _email = '';

  // Password
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  bool _isLoading = false;
  bool _isFetching = true;
  String? _errorMessage;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await DioClient.instance.get(ApiConstants.profile);
      final data = res.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _userId = data['user_id'] as int?;
        _email = data['user_email'] as String? ?? '';
        _nomCtrl.text = data['user_nom'] as String? ?? '';
        _prenomCtrl.text = data['user_prenom'] as String? ?? '';
        _phoneCtrl.text = data['user_number'] as String? ?? '';
        _isFetching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFetching = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    // Validate password fields if any are filled
    final hasPasswordChange = _currentPwCtrl.text.isNotEmpty ||
        _newPwCtrl.text.isNotEmpty ||
        _confirmPwCtrl.text.isNotEmpty;
    if (hasPasswordChange) {
      if (_currentPwCtrl.text.isEmpty) {
        setState(() => _errorMessage = 'Veuillez saisir votre mot de passe actuel');
        return;
      }
      if (_newPwCtrl.text.length < 8) {
        setState(() => _errorMessage = 'Le nouveau mot de passe doit contenir au moins 8 caractères');
        return;
      }
      if (!RegExp(r'(?=.*[A-Z])(?=.*[0-9])').hasMatch(_newPwCtrl.text)) {
        setState(() =>
            _errorMessage = 'Le mot de passe doit contenir au moins 1 majuscule et 1 chiffre');
        return;
      }
      if (_newPwCtrl.text != _confirmPwCtrl.text) {
        setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Update profile info
      await DioClient.instance.patch(
        '/users/$_userId',
        data: {
          'nom': _nomCtrl.text.trim(),
          'prenom': _prenomCtrl.text.trim(),
          if (_phoneCtrl.text.trim().isNotEmpty) 'number': _phoneCtrl.text.trim(),
        },
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message'];
      setState(() {
        _isLoading = false;
        _errorMessage = msg is String ? msg : 'Erreur lors de la mise à jour du profil';
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de joindre le serveur';
      });
      return;
    }

    // Step 2: Update password (separate error handling — profile was already saved)
    if (hasPasswordChange) {
      try {
        await DioClient.instance.patch(
          '/users/profile/password',
          data: {
            'current_password': _currentPwCtrl.text,
            'new_password': _newPwCtrl.text,
          },
        );
      } on DioException catch (e) {
        if (!mounted) return;
        final msg = (e.response?.data as Map?)?['message'];
        setState(() {
          _isLoading = false;
          _errorMessage = msg is String
              ? msg
              : 'Le profil a été enregistré, mais le changement de mot de passe a échoué';
        });
        return;
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Le profil a été enregistré, mais impossible de changer le mot de passe';
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour avec succès'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1B3A57)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Modifier le profil',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildStickyButton(),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C82F5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section : Informations personnelles ──
                    _buildSectionTitle('Informations personnelles'),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildFormField(
                            label: 'Email',
                            hint: _email.isNotEmpty ? _email : 'email@exemple.com',
                            controller: null,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Prénom',
                            hint: 'Votre prénom',
                            controller: _prenomCtrl,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Champ requis' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Nom',
                            hint: 'Votre nom',
                            controller: _nomCtrl,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Champ requis' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Numéro de téléphone',
                            hint: '+33 6 00 00 00 00',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v != null &&
                                  v.isNotEmpty &&
                                  !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)) {
                                return 'Numéro invalide';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Section : Mot de passe ──
                    _buildSectionTitle('Mot de passe'),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildPasswordField(
                            label: 'Mot de passe actuel',
                            hint: '••••••••',
                            controller: _currentPwCtrl,
                            showPassword: _showCurrentPw,
                            onToggle: () =>
                                setState(() => _showCurrentPw = !_showCurrentPw),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Nouveau mot de passe',
                            hint: '••••••••',
                            controller: _newPwCtrl,
                            showPassword: _showNewPw,
                            onToggle: () =>
                                setState(() => _showNewPw = !_showNewPw),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Confirmez nouveau mot de passe',
                            hint: '••••••••',
                            controller: _confirmPwCtrl,
                            showPassword: _showConfirmPw,
                            onToggle: () =>
                                setState(() => _showConfirmPw = !_showConfirmPw),
                          ),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: Color(0xFFDC2626), fontSize: 13)),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Color(0xFF1B3A57), fontSize: 16, fontWeight: FontWeight.w800));
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(
              color: readOnly
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF1B3A57),
              fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: readOnly
                ? const Color(0xFFF3F6FB)
                : const Color(0xFFF3F6FB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF3C82F5), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          validator: readOnly ? null : validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F6FB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF3C82F5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, -4))
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, 12 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B3A57),
            disabledBackgroundColor: const Color(0xFF9CA3AF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text('Enregistrer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
