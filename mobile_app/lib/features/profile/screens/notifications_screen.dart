import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = false;
  bool _promoMessages = false;
  bool _transactionalAlerts = false;

  void _onToggle(String label, bool value) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label ${value ? 'activé' : 'désactivé'}'),
      duration: const Duration(seconds: 1),
      backgroundColor: value ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
    ));
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
        title: const Text('Notifications',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
        child: Column(
          children: [
            _buildToggleItem(
              title: 'Notifications Push',
              subtitle: null,
              value: _pushNotifications,
              onChanged: (v) {
                _pushNotifications = v;
                _onToggle('Notifications Push', v);
              },
            ),
            const SizedBox(height: 32),
            _buildToggleItem(
              title: 'Messages promotionnels',
              subtitle: 'Offres spéciales, soldes saisonnières et campagnes marketing.',
              value: _promoMessages,
              onChanged: (v) {
                _promoMessages = v;
                _onToggle('Messages promotionnels', v);
              },
            ),
            const SizedBox(height: 32),
            _buildToggleItem(
              title: 'Alertes transactionnelles',
              subtitle: 'Confirmations de réservation, reçus de paiement et mises à jour de location.',
              value: _transactionalAlerts,
              onChanged: (v) {
                _transactionalAlerts = v;
                _onToggle('Alertes transactionnelles', v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 15, fontWeight: FontWeight.w800)),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF3C82F5),
        ),
      ],
    );
  }
}
