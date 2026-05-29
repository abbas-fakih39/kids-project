import 'package:flutter/material.dart';
import '../../search/screens/search_screen.dart';

const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _success   = Color(0xFF22C55E);
const _textGrey  = Color(0xFF9CA3AF);

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final String deliveryMethod;
  final double total;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.deliveryMethod,
    required this.total,
  });

  int get _nbDays => endDate.difference(startDate).inDays + 1;

  String _fmtDate(DateTime dt) {
    const months = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String get _bookingRef {
    final id = booking['booking_id'] ?? booking['id'];
    if (id != null) return 'KB${id.toString().padLeft(8, '0')}';
    return 'KB${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: Column(
        children: [
          // ── Hero ──
          _buildHero(context),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  // Step indicator (all done)
                  _buildStepDone(),
                  const SizedBox(height: 20),

                  // Booking ref
                  _buildRefCard(),
                  const SizedBox(height: 14),

                  // Booking details
                  _buildDetailsCard(),
                  const SizedBox(height: 14),

                  // Total
                  _buildTotalCard(),
                  const SizedBox(height: 28),

                  // CTAs
                  _buildCTAs(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero (success header) ─────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 32,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3C82F5), Color(0xFF1B3A57)],
        ),
      ),
      child: Column(
        children: [
          // Animated check circle
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 18),
          const Text(
            'Réservation confirmée !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Votre équipement est réservé.\nUn email de confirmation a été envoyé.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── All steps done ────────────────────────────────────────
  Widget _buildStepDone() {
    const steps = ['Dates', 'Paiement', 'Confirmé'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) return Expanded(child: Container(height: 2, color: _blue));
          final idx = i ~/ 2;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(height: 4),
              Text(steps[idx],
                  style: const TextStyle(
                    fontSize: 10, color: _blue, fontWeight: FontWeight.w700)),
            ],
          );
        }),
      ),
    );
  }

  // ── Booking ref card ──────────────────────────────────────
  Widget _buildRefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: _success, size: 22),
          ),
          const SizedBox(height: 10),
          const Text('Numéro de réservation',
              style: TextStyle(color: _textGrey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            _bookingRef,
            style: const TextStyle(
              color: _navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Details card ──────────────────────────────────────────
  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Détails de la location',
              style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _detailRow(Icons.inventory_2_outlined, 'Équipement',
              product['name'] as String? ?? ''),
          const SizedBox(height: 12),
          _detailRow(Icons.calendar_month_rounded, 'Dates',
              'Du ${_fmtDate(startDate)}\nau ${_fmtDate(endDate)}\n$_nbDays jour${_nbDays > 1 ? 's' : ''}'),
          const SizedBox(height: 12),
          _detailRow(Icons.location_on_outlined, 'Livraison',
              deliveryMethod == 'livraison'
                  ? 'Livraison à domicile'
                  : 'Retrait en magasin'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _blue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: _textGrey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    color: _navy, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Total card ────────────────────────────────────────────
  Widget _buildTotalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Montant débité',
                    style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 12, color: _success),
                    const SizedBox(width: 4),
                    const Text('Paiement sécurisé',
                        style: TextStyle(color: _textGrey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(0)} €',
            style: const TextStyle(
              color: _blue, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  // ── CTAs ──────────────────────────────────────────────────
  Widget _buildCTAs(BuildContext context) {
    return Column(
      children: [
        // Voir mes réservations
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: const Icon(Icons.event_note_outlined, color: Colors.white, size: 20),
            label: const Text('Voir mes réservations',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        // Continuer mes achats → SearchScreen
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
              (route) => route.isFirst,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _navy, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.search_rounded, color: _navy, size: 20),
            label: const Text('Continuer ma recherche',
                style: TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
