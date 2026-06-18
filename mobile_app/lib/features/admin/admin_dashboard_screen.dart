import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import 'admin_bookings_screen.dart';
import 'admin_products_screen.dart';

const _navy     = Color(0xFF1B3A57);
const _blue     = Color(0xFF3C82F5);
const _offWhite = Color(0xFFF4F7FA);
const _textGrey = Color(0xFF9CA3AF);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await DioClient.instance.get('/admin/stats');
      if (!mounted) return;
      setState(() { _stats = res.data as Map<String, dynamic>; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger les statistiques'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Administration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Statistiques'),
                        const SizedBox(height: 12),
                        _buildStatsGrid(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('Gestion'),
                        const SizedBox(height: 12),
                        _buildNavCard(
                          icon: Icons.event_note_rounded,
                          title: 'Réservations',
                          subtitle: 'Voir et gérer toutes les réservations',
                          color: const Color(0xFF8B5CF6),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildNavCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'Produits & Stock',
                          subtitle: 'Modifier les produits et ajuster les stocks',
                          color: const Color(0xFF059669),
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminProductsScreen())),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(backgroundColor: _navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800));
  }

  Widget _buildStatsGrid() {
    final s = _stats!;
    final cards = [
      _StatCard(label: 'Réservations',    value: '${s['total_bookings']}',    icon: Icons.event_note_rounded,      color: _blue),
      _StatCard(label: 'En attente',       value: '${s['pending_bookings']}',  icon: Icons.hourglass_top_rounded,   color: const Color(0xFFF59E0B)),
      _StatCard(label: 'En cours',         value: '${s['active_bookings']}',   icon: Icons.play_circle_rounded,     color: const Color(0xFF22C55E)),
      _StatCard(label: 'Confirmées',       value: '${s['confirmed_bookings']}',icon: Icons.check_circle_rounded,    color: const Color(0xFF8B5CF6)),
      _StatCard(label: 'Utilisateurs',     value: '${s['total_users']}',       icon: Icons.group_rounded,           color: const Color(0xFF06B6D4)),
      _StatCard(label: 'Chiffre d\'aff.', value: '${(s['total_revenue'] as num).toStringAsFixed(0)} €', icon: Icons.euro_rounded, color: const Color(0xFF059669)),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards.map(_buildStatTile).toList(),
    );
  }

  Widget _buildStatTile(_StatCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(card.icon, color: card.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.value,
                  style: TextStyle(color: card.color, fontSize: 22, fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              Text(card.label,
                  style: const TextStyle(color: _textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(color: _textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: _textGrey, size: 14),
          ],
        ),
      ),
    );
  }
}

class _StatCard {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
}
