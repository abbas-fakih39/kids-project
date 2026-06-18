import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications    = false;
  bool _promoMessages        = false;
  bool _transactionalAlerts  = true;
  bool _isLoading            = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final res = await DioClient.instance.get('/users/me/preferences');
      final data = res.data as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _pushNotifications   = data['user_notif_push']          as bool? ?? false;
        _promoMessages       = data['user_notif_promo']         as bool? ?? false;
        _transactionalAlerts = data['user_notif_transactional'] as bool? ?? true;
        _isLoading           = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePref(String key, bool value) async {
    try {
      await DioClient.instance.patch('/users/me/preferences', data: {key: value});
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : 'Impossible de sauvegarder la préférence';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)),
      );
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
        title: const Text('Notifications',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C82F5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F6FB)),
                ),
                child: Column(
                  children: [
                    _buildToggleItem(
                      icon: Icons.notifications_active_rounded,
                      title: 'Notifications Push',
                      subtitle: 'Activez les notifications pour rester informé en temps réel.',
                      value: _pushNotifications,
                      isLast: false,
                      onChanged: (v) {
                        setState(() => _pushNotifications = v);
                        _updatePref('push', v);
                        _showSnack('Notifications Push', v);
                      },
                    ),
                    _buildToggleItem(
                      icon: Icons.campaign_rounded,
                      title: 'Messages promotionnels',
                      subtitle: 'Offres spéciales, soldes saisonnières et campagnes marketing.',
                      value: _promoMessages,
                      isLast: false,
                      onChanged: (v) {
                        setState(() => _promoMessages = v);
                        _updatePref('promo', v);
                        _showSnack('Messages promotionnels', v);
                      },
                    ),
                    _buildToggleItem(
                      icon: Icons.receipt_long_rounded,
                      title: 'Alertes transactionnelles',
                      subtitle: 'Confirmations de réservation, reçus de paiement et mises à jour de location.',
                      value: _transactionalAlerts,
                      isLast: true,
                      onChanged: (v) {
                        setState(() => _transactionalAlerts = v);
                        _updatePref('transactional', v);
                        _showSnack('Alertes transactionnelles', v);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showSnack(String label, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label ${value ? 'activé' : 'désactivé'}'),
      duration: const Duration(seconds: 1),
      backgroundColor: value ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
    ));
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isLast,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE9FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF3C82F5), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Color(0xFF1B3A57),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: const Color(0xFF3C82F5),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF3F6FB)),
      ],
    );
  }
}
