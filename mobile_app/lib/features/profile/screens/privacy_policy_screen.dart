import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: const Text(
          'Politique de confidentialité',
          style: TextStyle(color: Color(0xFF1B3A57), fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Politique de Confidentialité',
              style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kits & Kids',
              style: TextStyle(color: Color(0xFF3C82F5), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildSection('Bienvenue',
                'Kits & Kids s\'engage à protéger vos données personnelles. Cette politique explique comment nous collectons, utilisons et protégeons vos informations conformément au Règlement Général sur la Protection des Données (RGPD) et à la législation française en vigueur.'),
            _buildSection('1. Responsable du traitement',
                'Kits & Kids est responsable du traitement de vos données personnelles. Pour toute question relative à la protection de vos données, vous pouvez nous contacter à : privacy@kitsandkids.fr'),
            _buildSection('2. Données collectées',
                'Identification : Nom, prénom, adresse email et numéro de téléphone.\n\nDonnées de transaction : Adresses de livraison, historique des réservations, informations de paiement (tokenisées, jamais stockées en clair).\n\nDonnées d\'utilisation : Logs de connexion, préférences de l\'application.'),
            _buildSection('3. Pourquoi collectons-nous ces données ?',
                'Gérer vos réservations : Traitement des commandes, livraisons et communications liées à votre location.\n\nAméliorer nos services : Analyse anonymisée de l\'utilisation pour améliorer l\'expérience utilisateur.\n\nL\'amélioration du service : Kits & Kids est responsable de l\'application et de son amélioration continue.'),
            _buildSection('4. Durée de conservation',
                'Vos données sont conservées pendant la durée de votre relation contractuelle avec Kits & Kids, puis archivées pendant 3 ans conformément aux obligations légales.'),
            _buildSection('5. Partage des données',
                'Kits & Kids ne vend pas vos données personnelles à des tiers. Nous pouvons partager vos données avec des prestataires de services (paiement, livraison) uniquement dans le cadre de l\'exécution de votre réservation.'),
            _buildSection('6. Vos droits',
                'Conformément au RGPD, vous disposez des droits suivants :\n\n• Droit d\'accès à vos données\n• Droit de rectification\n• Droit à l\'effacement (« droit à l\'oubli »)\n• Droit à la portabilité\n• Droit d\'opposition\n\nPour exercer ces droits, contactez-nous à privacy@kitsandkids.fr'),
            _buildSection('7. Contact',
                'Pour toute question concernant cette politique ou pour exercer vos droits, contactez notre délégué à la protection des données à l\'adresse privacy@kitsandkids.fr ou via le formulaire de contact dans l\'application.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1B3A57),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
