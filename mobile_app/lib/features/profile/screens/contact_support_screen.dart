import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _helpCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _helpCtrl.dispose();
    _orderCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      await DioClient.instance.post('/support', data: {
        'email': _emailCtrl.text.trim(),
        'prenom': _prenomCtrl.text.trim(),
        'nom': _nomCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        if (_orderCtrl.text.trim().isNotEmpty) 'order_ref': _orderCtrl.text.trim(),
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Message envoyé',
              style: TextStyle(color: Color(0xFF1B3A57), fontWeight: FontWeight.w800)),
          content: const Text(
              'Votre message a bien été reçu. Notre équipe vous répondra dans les plus brefs délais.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: Color(0xFF3C82F5))),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Contactez-nous directement',
              style: TextStyle(color: Color(0xFF1B3A57), fontWeight: FontWeight.w800)),
          content: const Text(
              'Le service de messagerie est temporairement indisponible.\n\nContactez-nous directement à :\nsupport@kitsandkids.fr',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer', style: TextStyle(color: Color(0xFF3C82F5))),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
        title: const Text('Contacter le support',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 60),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Email', isRequired: true),
              _buildFormField(_emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Email invalide';
                    return null;
                  }),

              _buildLabel('Prénom', isRequired: true),
              _buildFormField(_prenomCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null),

              _buildLabel('Nom', isRequired: true),
              _buildFormField(_nomCtrl,
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null),

              _buildLabel('Comment pouvons-nous vous aider aujourd\'hui ?'),
              _buildFormField(_helpCtrl),

              _buildLabel('Numéro de commande (si applicable)'),
              _buildFormField(_orderCtrl, keyboardType: TextInputType.number),

              _buildLabel('Sujet'),
              _buildFormField(_subjectCtrl),

              _buildLabel('Message', isRequired: true),
              _buildFormField(_messageCtrl, maxLines: 5,
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                width: 140,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: const Color(0x33000000),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Envoyer',
                          style:
                              TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
              color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w600),
          children: [
            if (isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: maxLines > 1 ? 12 : 14),
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
            borderSide: const BorderSide(color: Color(0xFF3C82F5), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
