import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Conditions d\'utilisation',
          style: TextStyle(color: Color(0xFF1B3A57), fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions Générales d\'Utilisation et de Vente',
              style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kits & Kids',
              style: TextStyle(color: Color(0xFF3C82F5), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            _buildSection('1. Objet du Service',
                'La société Kits & Kids propose via son application mobile une plateforme de location de matériel de puériculture en France. Tout utilisateur doit avoir plus de 18 ans et accepter les présentes conditions pour utiliser l\'application.'),
            _buildSection('2. Réservation et Paiement',
                'Délai : La réservation doit être effectuée au minimum 48 heures à l\'avance.\n\nDurée : La durée minimale de location est de 3 jours.\n\nPaiement : L\'intégralité du montant est due lors de la confirmation. La caution (dépôt de garantie) est temporairement bloquée sur votre carte et sera libérée après restitution du matériel en bon état.'),
            _buildSection('3. La Caution (Dépôt de garantie)',
                'Un dépôt de garantie de 150 € est requis pour chaque location. Ce montant est bloqué sur votre carte bancaire et libéré dans un délai de 5 à 10 jours ouvrés après retour du matériel, sous réserve de l\'absence de dommages.'),
            _buildSection('4. Livraison et Restitution',
                'Livraison à domicile : Kits & Kids livre et récupère le matériel à votre adresse. Des frais de livraison s\'appliquent selon les modalités tarifaires en vigueur.\n\nPoints de Retrait & Partenaires : Le retrait et la restitution en agence partenaire sont gratuits.\n\nKits & Kids est responsable de la livraison du matériel dans les délais convenus.'),
            _buildSection('5. Annulation et Remboursement',
                'Annulation plus de 48h avant la location : Remboursement à 100%.\n\nAnnulation entre 24h et 48h avant : Remboursement à 50%.\n\nAnnulation moins de 24h avant : Aucun remboursement.\n\nEn cas d\'annulation par Kits & Kids : Remboursement intégral.'),
            _buildSection('6. Assurance, Casse et Vol',
                'Les dommages esthétiques mineurs (légères rayures) n\'entraînent pas de facturation. Les dommages majeurs sont à la charge du locataire dans la limite de la caution.\n\nLe matériel et le locataire sont couverts par notre assurance responsabilité civile. Des options d\'assurance complémentaire sont disponibles lors de la réservation.'),
            _buildSection('7. Protocole d\'Hygiène "Pure-Kits"',
                'Kits & Kids s\'engage à livrer du matériel propre et désinfecté. Chaque équipement est nettoyé après chaque utilisation selon notre protocole d\'hygiène certifié.\n\nObligation du client : Le matériel doit être retourné dans un état de propreté raisonnable, sous peine de frais de nettoyage supplémentaires.'),
            _buildSection('8. Propriété intellectuelle',
                'L\'application, son contenu et sa marque sont la propriété exclusive de Kits & Kids. Toute reproduction ou utilisation non autorisée est strictement interdite.'),
            _buildSection('9. Droit applicable',
                'Les présentes conditions sont régies par le droit français. Tout litige sera soumis aux tribunaux compétents du ressort du siège social de Kits & Kids.'),
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
