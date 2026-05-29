import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

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
        title: const Text('Comment ça marche',
            style: TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 60),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Comment ça marche',
                style: TextStyle(color: Color(0xFF1B3A57), fontSize: 26, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFB1D1FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 48),

            _buildStep(
              icon: Icons.smartphone_rounded,
              title: 'Choisissez',
              description: 'Sélectionnez votre matériel et vos dates de location sur l\'application.',
            ),
            const SizedBox(height: 24),

            _buildStep(
              icon: Icons.edit_calendar_rounded,
              title: 'Réservez',
              description: 'Retrait en agence ou livraison à domicile, gare, aéroport partout en France.',
            ),
            const SizedBox(height: 24),

            _buildStep(
              icon: Icons.local_shipping_outlined,
              title: 'Profitez',
              description: 'Paiement sécurisé. Le matériel vous attend, propre et prêt à l\'emploi.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF3C82F5), size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // align baselines
              Text(title, style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        )
      ],
    );
  }
}
