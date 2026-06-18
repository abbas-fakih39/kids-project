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

class BookingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Map<String, dynamic> _booking;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  String get _statusLabel {
    switch (_booking['booking_status']) {
      case 'en_attente': return 'En attente';
      case 'confirmee':  return 'Confirmée';
      case 'en_cours':   return 'En cours';
      case 'terminee':   return 'Terminée';
      case 'annulee':    return 'Annulée';
      default:           return 'Inconnu';
    }
  }

  Color get _statusColor {
    switch (_booking['booking_status']) {
      case 'confirmee':
      case 'en_cours':  return _blue;
      case 'terminee':  return _success;
      case 'annulee':   return _red;
      default:          return _amber;
    }
  }

  Color get _statusBg {
    switch (_booking['booking_status']) {
      case 'confirmee':
      case 'en_cours':  return const Color(0xFFEFF6FF);
      case 'terminee':  return const Color(0xFFF0FDF4);
      case 'annulee':   return const Color(0xFFFEF2F2);
      default:          return const Color(0xFFFFFBEB);
    }
  }

  bool get _isCancellable {
    final s = _booking['booking_status'];
    return s == 'en_attente' || s == 'confirmee';
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
      final start = DateTime.parse(_booking['booking_start_date'] as String);
      final end   = DateTime.parse(_booking['booking_end_date'] as String);
      return end.difference(start).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  String _paymentStatusLabel(String? s) {
    switch (s) {
      case 'valide':    return 'Validé';
      case 'echoue':    return 'Échoué';
      case 'rembourse': return 'Remboursé';
      default:          return 'En attente';
    }
  }

  String _paymentMethodLabel(String? s) {
    switch (s) {
      case 'carte_bancaire': return 'Carte bancaire';
      case 'virement':       return 'Virement';
      case 'paypal':         return 'PayPal';
      default:               return s ?? '—';
    }
  }

  Future<void> _cancelBooking() async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler la réservation',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w800, fontSize: 17)),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non', style: TextStyle(color: _textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler',
                style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      final id = _booking['booking_id'];
      await DioClient.instance.patch('/bookings/$id/cancel');
      if (!mounted) return;
      setState(() {
        _booking = Map.from(_booking)..['booking_status'] = 'annulee';
      });
      messenger.showSnackBar(const SnackBar(
        content: Text('Réservation annulée'),
        backgroundColor: _success,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message'];
      messenger.showSnackBar(SnackBar(
        content: Text(msg is String ? msg : 'Impossible d\'annuler la réservation'),
        backgroundColor: _red,
      ));
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = (_booking['products'] as List?) ?? [];
    final payment  = _booking['payment'] as Map?;
    final nb       = _nbDays;

    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Détail de la réservation',
            style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(nb),
            const SizedBox(height: 16),
            _buildProductsCard(products),
            const SizedBox(height: 16),
            _buildDeliveryCard(),
            const SizedBox(height: 16),
            if (payment != null) ...[
              _buildPaymentCard(payment),
              const SizedBox(height: 16),
            ],
            if (_isCancellable) _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(int nb) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservation #${_booking['booking_id']}',
                      style: const TextStyle(
                        color: _navy, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créée le ${_fmtDate(_booking['booking_created_at'] as String?)}',
                      style: const TextStyle(color: _textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF0F4F8)),
          _row(Icons.calendar_today_rounded,
              '${_fmtDate(_booking['booking_start_date'] as String?)}  →  ${_fmtDate(_booking['booking_end_date'] as String?)}'),
          if (nb > 0) ...[
            const SizedBox(height: 10),
            _row(Icons.schedule_rounded, '$nb jour${nb > 1 ? 's' : ''}'),
          ],
          const SizedBox(height: 10),
          _row(Icons.payments_outlined,
              '${(double.tryParse(_booking['booking_total_amount'].toString()) ?? 0).toStringAsFixed(0)} €',
              bold: true),
        ],
      ),
    );
  }

  Widget _buildProductsCard(List products) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Équipements loués',
              style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...products.map((p) {
            final item    = p as Map;
            final product = item['product'] as Map? ?? {};
            final qty     = item['bp_quantity'] as int? ?? 1;
            final price   = double.tryParse(item['bp_price_snapshot'].toString()) ?? 0;
            final name    = product['products_name'] as String? ?? 'Équipement';
            final subtotal = price * qty * _nbDays;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.child_friendly_rounded, color: _blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                              color: _navy, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${price.toStringAsFixed(2)} €/j × $qty × $_nbDays j',
                            style: const TextStyle(color: _textGrey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    '${subtotal.toStringAsFixed(0)} €',
                    style: const TextStyle(
                      color: _navy, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    final method   = _booking['booking_delivery_method'] as String?;
    final isHome   = method == 'livraison';
    final street   = _booking['booking_delivery_street'] as String?;
    final city     = _booking['booking_delivery_city'] as String?;
    final zip      = _booking['booking_delivery_zip'] as String?;
    final country  = _booking['booking_delivery_country'] as String? ?? 'France';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Livraison',
              style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _row(
            isHome ? Icons.local_shipping_outlined : Icons.storefront_outlined,
            isHome ? 'Livraison à domicile' : 'Retrait en magasin',
          ),
          if (isHome && (street != null || city != null)) ...[
            const SizedBox(height: 10),
            _row(
              Icons.location_on_outlined,
              [
                ?street,
                if (zip != null && city != null) '$zip $city' else if (city != null) city,
                country,
              ].join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map payment) {
    final status = payment['payments_status'] as String?;
    final method = payment['payments_method'] as String?;
    final amount = double.tryParse(payment['payments_amount'].toString()) ?? 0;

    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'valide':
        statusColor = _success; statusBg = const Color(0xFFF0FDF4);
        break;
      case 'echoue':
        statusColor = _red; statusBg = const Color(0xFFFEF2F2);
        break;
      case 'rembourse':
        statusColor = _amber; statusBg = const Color(0xFFFFFBEB);
        break;
      default:
        statusColor = _textGrey; statusBg = const Color(0xFFF8FAFC);
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paiement',
                  style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(_paymentStatusLabel(status),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(Icons.credit_card_rounded, _paymentMethodLabel(method)),
          const SizedBox(height: 10),
          _row(Icons.payments_rounded, '${amount.toStringAsFixed(2)} €', bold: true),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _cancelBooking,
        style: OutlinedButton.styleFrom(
          foregroundColor: _red,
          side: const BorderSide(color: _red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isCancelling
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: _red, strokeWidth: 2.5))
            : const Text('Annuler la réservation',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _row(IconData icon, String label, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _textGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _navy,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}
