import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'Proposez-vous la livraison et la récupération sans contact ?',
      'a': 'Oui, nous proposons des options de livraison et de récupération 100% sans contact pour assurer votre sécurité.',
    },
    {
      'q': 'Combien de temps à l\'avance dois-je faire ma réservation ?',
      'a': 'Nous vous recommandons de réserver au moins 48h à l\'avance, mais des réservations de dernière minute sont possibles sous réserve de disponibilité.',
    },
    {
      'q': 'Puis-je payer au début de la réservation ?',
      'a': 'Le paiement intégral est requis au moment de la réservation pour valider celle-ci et bloquer l\'équipement pour vous.',
    },
    {
      'q': 'Quels modes de paiement acceptez-vous ?',
      'a': 'Nous acceptons les cartes de crédit/débit classiques (Visa, Mastercard) via notre plateforme sécurisée.',
    },
    {
      'q': 'Comment calculez-vous le nombre de jours de location ?',
      'a': 'Le premier et le dernier jour de location sont inclus dans le calcul. Tout matériel conservé au-delà de la date prévue sera facturé au tarif journalier.',
    },
    {
      'q': 'Y a-t-il une période de location minimale ?',
      'a': 'Oui, la période de location minimale est généralement de 3 jours pour la plupart des équipements.',
    },
    {
      'q': 'Accordez-vous des réductions pour les locations de longue durée ?',
      'a': 'Absolument ! Des réductions automatiques s\'appliquent pour les locations dépassant 7 jours et 14 jours.',
    },
    {
      'q': 'Où livrez-vous les équipements pour bébé ?',
      'a': 'Nous livrons directement à votre domicile, hôtel ou location de vacances dans notre zone de couverture.',
    },
    {
      'q': 'Combien coûte la livraison ?',
      'a': 'Les frais de livraison dépendent de votre zone. Certaines options de retrait en point relais sont gratuites.',
    },
    {
      'q': 'Qu\'est-ce qui est inclus dans les frais de livraison ?',
      'a': 'Les frais incluent la livraison à l\'adresse indiquée, l\'explication du matériel si nécessaire, et la récupération à la fin.',
    },
    {
      'q': 'Comment puis-je consulter ou modifier ma réservation ?',
      'a': 'Vous pouvez gérer vos réservations directement depuis l\'onglet "Mes réservations" dans l\'application.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 20),
              Icon(Icons.arrow_back, color: Color(0xFF1B3A57), size: 20),
            ],
          ),
        ),
        title: const Text('Foire Aux Questions',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 16, fontWeight: FontWeight.w800)),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 40),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return _FaqItem(question: faq['q']!, answer: faq['a']!);
        },
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 8),
        title: Text(
          widget.question,
          style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 13, fontWeight: FontWeight.w700),
        ),
        trailing: Icon(
          _isExpanded ? Icons.remove : Icons.add,
          color: const Color(0xFF3C82F5),
          size: 20,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
            child: Text(
              widget.answer,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
