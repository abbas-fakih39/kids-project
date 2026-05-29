import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textGrey  = Color(0xFF9CA3AF);
const _success   = Color(0xFF22C55E);
const _amber     = Color(0xFFF59E0B);
const _red       = Color(0xFFEF4444);

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchBookings();
  }

  Future<List<dynamic>> _fetchBookings() async {
    final res = await DioClient.instance.get('/bookings/mine');
    return res.data as List<dynamic>;
  }

  void _refresh() => setState(() => _future = _fetchBookings());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  }
                  if (snapshot.hasError) return _buildError();
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) return _buildEmpty(context);
                  return _buildList(bookings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Mes réservations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: _refresh,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: _navy, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() => const Center(
    child: CircularProgressIndicator(color: _blue),
  );

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: _red),
            ),
            const SizedBox(height: 20),
            const Text('Impossible de charger les réservations',
                textAlign: TextAlign.center,
                style: TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Vérifiez votre connexion.',
                style: TextStyle(color: _textGrey, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(
                color: _lightBlue, shape: BoxShape.circle),
              child: const Icon(
                Icons.baby_changing_station_rounded, size: 48, color: _blue),
            ),
            const SizedBox(height: 24),
            const Text(
              "Aucune réservation pour l'instant",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: _navy, height: 1.3),
            ),
            const SizedBox(height: 10),
            const Text(
              'Louez des lits, sièges auto, poussettes et bien plus pour votre prochain voyage en famille.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.55),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Commencer ma location',
                        style: TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> bookings) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: _blue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _BookingCard(
          booking: bookings[i] as Map<String, dynamic>,
          onReviewSubmitted: _refresh,
        ),
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onReviewSubmitted;

  const _BookingCard({required this.booking, required this.onReviewSubmitted});

  String get _productName {
    final products = booking['products'] as List?;
    if (products == null || products.isEmpty) return 'Équipement';
    final first   = products[0] as Map?;
    final product = first?['product'] as Map?;
    return product?['products_name'] as String? ?? 'Équipement';
  }

  int? get _productId {
    final products = booking['products'] as List?;
    if (products == null || products.isEmpty) return null;
    return (products[0] as Map?)?['bp_product_id'] as int?;
  }

  bool get _isTerminee => booking['booking_status'] == 'terminee';
  bool get _hasReview  => booking['review'] != null;

  String get _statusLabel {
    switch (booking['booking_status']) {
      case 'en_attente': return 'En attente';
      case 'confirmee':  return 'Confirmée';
      case 'en_cours':   return 'En cours';
      case 'terminee':   return 'Terminée';
      case 'annulee':    return 'Annulée';
      default:           return 'Inconnu';
    }
  }

  _StatusStyle get _statusStyle {
    switch (booking['booking_status']) {
      case 'confirmee':  return _StatusStyle(_blue,    const Color(0xFFEFF6FF));
      case 'en_cours':   return _StatusStyle(_blue,    const Color(0xFFEFF6FF));
      case 'terminee':   return _StatusStyle(_success, const Color(0xFFF0FDF4));
      case 'annulee':    return _StatusStyle(_red,     const Color(0xFFFEF2F2));
      default:           return _StatusStyle(_amber,   const Color(0xFFFFFBEB));
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'jan.', 'fév.', 'mar.', 'avr.', 'mai',
          'juin', 'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  int get _nbDays {
    try {
      final start = DateTime.parse(booking['booking_start_date'] as String);
      final end   = DateTime.parse(booking['booking_end_date'] as String);
      return end.difference(start).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  void _showReviewSheet(BuildContext context) {
    final productId = _productId;
    if (productId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        bookingId: booking['booking_id'] as int,
        productId: productId,
        productName: _productName,
        onSubmitted: onReviewSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle;
    final nb    = _nbDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: name + status ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _productName,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: _navy, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: style.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Date row ──
                Row(
                  children: [
                    _infoChip(
                      Icons.calendar_today_rounded,
                      '${_fmtDate(booking['booking_start_date'] as String?)} '
                      '→ ${_fmtDate(booking['booking_end_date'] as String?)}',
                    ),
                    if (nb > 0) ...[
                      const SizedBox(width: 8),
                      _infoChip(Icons.schedule_rounded, '$nb jour${nb > 1 ? 's' : ''}'),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // ── Delivery row ──
                _infoChip(
                  booking['booking_delivery_method'] == 'livraison'
                      ? Icons.local_shipping_outlined
                      : Icons.storefront_outlined,
                  booking['booking_delivery_method'] == 'livraison'
                      ? 'Livraison à domicile'
                      : 'Retrait en magasin',
                ),
              ],
            ),
          ),

          // ── Review (only for completed) ──
          if (_isTerminee) ...[
            const Divider(height: 1, color: Color(0xFFF3F6FB)),
            GestureDetector(
              onTap: _hasReview ? null : () => _showReviewSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _hasReview
                      ? [
                          const Icon(Icons.check_circle_rounded,
                              color: _success, size: 16),
                          const SizedBox(width: 6),
                          const Text('Avis publié',
                              style: TextStyle(
                                color: _success,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                        ]
                      : [
                          const Icon(Icons.star_border_rounded,
                              color: _amber, size: 16),
                          const SizedBox(width: 6),
                          const Text('Laisser un avis',
                              style: TextStyle(
                                color: _amber,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: _amber, size: 11),
                        ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _textGrey),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      ],
    );
  }
}

class _StatusStyle {
  final Color color;
  final Color bg;
  const _StatusStyle(this.color, this.bg);
}

// ─── Review Bottom Sheet ──────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  final int bookingId;
  final int productId;
  final String productName;
  final VoidCallback onSubmitted;

  const _ReviewSheet({
    required this.bookingId,
    required this.productId,
    required this.productName,
    required this.onSubmitted,
  });

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating         = 0;
  final _commentCtrl  = TextEditingController();
  bool _isSubmitting  = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String _ratingLabel(int r) => switch (r) {
    1 => 'Très mauvais 😕',
    2 => 'Mauvais',
    3 => 'Correct',
    4 => 'Bien 👍',
    5 => 'Excellent ! ⭐',
    _ => '',
  };

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez sélectionner une note'),
        backgroundColor: _red,
      ));
      return;
    }
    setState(() => _isSubmitting = true);
    final nav       = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance.post('/reviews', data: {
        'review_booking_id': widget.bookingId,
        'review_product_id': widget.productId,
        'review_rating':     _rating,
        if (_commentCtrl.text.trim().isNotEmpty)
          'review_comment': _commentCtrl.text.trim(),
      });
      if (!mounted) return;
      nav.pop();
      widget.onSubmitted();
      messenger.showSnackBar(const SnackBar(
        content: Text('Merci pour votre avis !'),
        backgroundColor: _success,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message'];
      messenger.showSnackBar(SnackBar(
        content: Text(msg is String ? msg : 'Erreur lors de la publication'),
        backgroundColor: _red,
      ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),

            const Text('Votre avis',
                style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(widget.productName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 13)),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: _amber, size: 40),
                  ),
                );
              }),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _rating > 0
                  ? Padding(
                      key: ValueKey(_rating),
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_ratingLabel(_rating),
                          style: const TextStyle(
                            color: _amber, fontSize: 13, fontWeight: FontWeight.w600)),
                    )
                  : const SizedBox(key: ValueKey(0), height: 8),
            ),
            const SizedBox(height: 20),

            // Comment
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              style: const TextStyle(color: _navy, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience (optionnel)…',
                hintStyle: const TextStyle(color: _textGrey, fontSize: 13),
                filled: true,
                fillColor: _offWhite,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _blue, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Publier mon avis',
                        style: TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
