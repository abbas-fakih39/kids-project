import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/admin_dashboard_screen.dart';
import '../../../core/network/dio_client.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'how_it_works_screen.dart';
import 'hygiene_screen.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final name    = auth.user?['user_prenom'] as String? ?? 'Utilisateur';
    final email   = auth.user?['user_email'] as String? ?? '';
    final isAdmin = auth.user?['user_role'] == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 72, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, $name !',
              style: const TextStyle(
                color: Color(0xFF1B3A57),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            const SizedBox(height: 40),

            // ── Admin ──
            if (isAdmin) ...[
              _sectionTitle('Administration'),
              const SizedBox(height: 12),
              _buildSection(context, [
                _MenuItem(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Espace Admin',
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
            ],

            // ── Compte ──
            _sectionTitle('Compte'),
            const SizedBox(height: 12),
            _buildSection(context, [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Profil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 28),

            // ── Support ──
            _sectionTitle('Support'),
            const SizedBox(height: 12),
            _buildSection(context, [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Comment ça marche',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.shield_outlined,
                label: 'Hygiène',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HygieneScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.info_outline_rounded,
                label: 'FAQ',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Contacter le support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 28),

            // ── Légal ──
            _sectionTitle('Légal'),
            const SizedBox(height: 12),
            _buildSection(context, [
              _MenuItem(
                icon: Icons.description_outlined,
                label: 'Conditions d\'utilisation',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Politique de confidentialité',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 40),

            // ── Se déconnecter ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushReplacementNamed('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A57),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Supprimer mon compte ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF6B7280), size: 20),
                label: const Text(
                  'Supprimer mon compte',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text(
                        'Supprimer le compte',
                        style: TextStyle(color: Color(0xFF1B3A57), fontWeight: FontWeight.w800),
                      ),
                      content: const Text(
                        'Cette action est irréversible. Toutes vos données seront supprimées. Voulez-vous continuer ?',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    try {
                      await DioClient.instance.delete('/users/me');
                    } catch (_) {}
                    if (context.mounted) {
                      await context.read<AuthProvider>().logout();
                    }
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushReplacementNamed('/login');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1B3A57),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F6FB), width: 1),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(e.value.icon, color: const Color(0xFF6B7280), size: 22),
                title: Text(
                  e.value.label,
                  style: const TextStyle(
                    color: Color(0xFF1B3A57),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 14,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: e.value.onTap,
              ),
              if (!isLast)
                const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF3F6FB)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
