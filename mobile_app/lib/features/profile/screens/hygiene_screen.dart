import 'package:flutter/material.dart';

class HygieneScreen extends StatelessWidget {
  const HygieneScreen({super.key});

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
          'Hygiène',
          style: TextStyle(color: Color(0xFF1B3A57), fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE9FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3C82F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Charte d\'hygiène Kits & Kids',
                      style: TextStyle(
                        color: Color(0xFF1B3A57),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Notre engagement',
              content:
                  'Kits & Kids s\'engage à fournir du matériel propre, sûr et en parfait état de fonctionnement. Chaque équipement est inspecté, nettoyé et désinfecté après chaque location, conformément à nos standards d\'hygiène stricts.',
            ),
            _buildSection(
              title: 'Protocole de nettoyage',
              content:
                  'Tous nos équipements sont nettoyés avec des produits désinfectants homologués, sans danger pour les bébés et les jeunes enfants. Les textiles (housses, harnais) sont lavés à haute température (60°C minimum) entre chaque location.',
            ),
            _buildSection(
              title: 'Contrôle qualité',
              content:
                  'Avant chaque nouvelle location, notre équipe vérifie l\'état général de chaque équipement : stabilité, propreté, absence de pièces manquantes ou endommagées. Tout article non conforme est retiré de la flotte.',
            ),
            _buildSection(
              title: 'Engagement du locataire',
              content:
                  'En louant du matériel Kits & Kids, vous vous engagez à :\n\n• Utiliser l\'équipement de manière appropriée et conforme à son usage\n• Restituer le matériel dans un état de propreté raisonnable\n• Signaler tout dommage ou dysfonctionnement constaté\n• Ne pas sous-louer le matériel à des tiers',
            ),
            _buildSection(
              title: 'Signalement d\'un problème',
              content:
                  'Si vous constatez un problème d\'hygiène ou un défaut sur le matériel lors de la réception, contactez immédiatement notre service client. Nous nous engageons à vous proposer un remplacement dans les meilleurs délais.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
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
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
