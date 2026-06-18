import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../core/network/dio_client.dart';
import 'booking_confirmation_screen.dart';

const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textGrey  = Color(0xFF9CA3AF);

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final DateTime startDate;
  final DateTime endDate;
  final String deliveryMethod;
  final double total;
  final double deposit;
  final String? deliveryStreet;
  final String? deliveryCity;
  final String? deliveryZip;

  const PaymentScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.deliveryMethod,
    required this.total,
    required this.deposit,
    this.deliveryStreet,
    this.deliveryCity,
    this.deliveryZip,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardFormController = CardFormEditController();
  bool _cardComplete  = false;
  bool _isSubmitting  = false;

  bool get _isSimulated => Stripe.publishableKey == 'pk_test_placeholder';

  @override
  void dispose() {
    _cardFormController.dispose();
    super.dispose();
  }

  int get _nbDays => widget.endDate.difference(widget.startDate).inDays + 1;

  String _fmtDate(DateTime dt) {
    const months = ['', 'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_isSimulated && !_cardComplete) {
      _showError(messenger, 'Veuillez compléter les informations de carte');
      return;
    }

    setState(() => _isSubmitting = true);
    final nav = Navigator.of(context);
    try {
      // 1. Créer la réservation
      final bookingData = <String, dynamic>{
        'booking_start_date':      widget.startDate.toIso8601String().substring(0, 10),
        'booking_end_date':        widget.endDate.toIso8601String().substring(0, 10),
        'booking_delivery_method': widget.deliveryMethod,
        'items': [
          {'bp_product_id': widget.product['id'], 'bp_quantity': 1},
        ],
      };
      if (widget.deliveryStreet != null) bookingData['booking_delivery_street'] = widget.deliveryStreet;
      if (widget.deliveryCity != null)   bookingData['booking_delivery_city']   = widget.deliveryCity;
      if (widget.deliveryZip != null)    bookingData['booking_delivery_zip']    = widget.deliveryZip;

      final bookingRes = await DioClient.instance.post('/bookings', data: bookingData);
      final booking = bookingRes.data as Map<String, dynamic>;
      final bookingId = booking['booking_id'];

      // 2. Initier le paiement
      final intentRes = await DioClient.instance.post('/payments/initiate/$bookingId');
      final intentData = intentRes.data as Map<String, dynamic>;

      // 3. Paiement simulé (pas de clé Stripe configurée)
      if (intentData['simulated'] != true) {
        final clientSecret = intentData['client_secret'] as String;
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
      }

      if (!mounted) return;
      nav.push(MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          booking: booking,
          product: widget.product,
          startDate: widget.startDate,
          endDate: widget.endDate,
          deliveryMethod: widget.deliveryMethod,
          total: widget.total + widget.deposit,
        ),
      ));
    } on StripeException catch (e) {
      if (!mounted) return;
      _showError(messenger, e.error.localizedMessage ?? 'Paiement refusé');
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data as Map?)?['message'];
      _showError(messenger, msg is String ? msg : 'Erreur lors de la réservation');
    } catch (_) {
      if (!mounted) return;
      _showError(messenger, 'Impossible de joindre le serveur');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(ScaffoldMessengerState m, String msg) {
    m.showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      bottomNavigationBar: _buildStickyButton(),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepProgress(),
                  const SizedBox(height: 20),
                  _buildRecapCard(),
                  const SizedBox(height: 20),
                  _buildPaymentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 4, right: 20, bottom: 4,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _navy),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Paiement',
                style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    const steps = ['Dates', 'Paiement', 'Confirmé'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final filled = (i ~/ 2) < 1;
            return Expanded(child: Container(height: 2, color: filled ? _blue : _lightBlue));
          }
          final idx    = i ~/ 2;
          final done   = idx < 1;
          final active = idx == 1;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done ? _blue : (active ? _navy : _lightBlue),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Center(
                        child: Text('${idx + 1}',
                          style: TextStyle(
                            color: active ? Colors.white : _blue,
                            fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
              ),
              const SizedBox(height: 4),
              Text(steps[idx],
                  style: TextStyle(
                    fontSize: 10,
                    color: active ? _navy : _textGrey,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRecapCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Récapitulatif',
              style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _recapRow(Icons.inventory_2_outlined, 'Équipement',
              widget.product['name'] as String? ?? ''),
          const SizedBox(height: 10),
          _recapRow(Icons.calendar_today_outlined, 'Dates',
              '${_fmtDate(widget.startDate)} → ${_fmtDate(widget.endDate)}  ($_nbDays j)'),
          const SizedBox(height: 10),
          _recapRow(Icons.location_on_outlined, 'Livraison',
              widget.deliveryMethod == 'livraison' ? 'À domicile' : 'Retrait en magasin'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total à payer',
                      style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text('Dépôt de garantie inclus',
                      style: TextStyle(color: _textGrey, fontSize: 11)),
                ],
              ),
              Text(
                '${(widget.total + widget.deposit).toStringAsFixed(0)} €',
                style: const TextStyle(
                  color: _blue, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recapRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _textGrey),
        const SizedBox(width: 10),
        SizedBox(width: 80,
            child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: _navy, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Carte bancaire',
            style: TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        if (_isSimulated)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: const Row(
              children: [
                Icon(Icons.science_outlined, color: Color(0xFFEA580C), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode test activé',
                          style: TextStyle(
                            color: Color(0xFF9A3412),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                      SizedBox(height: 3),
                      Text(
                        'Aucune clé Stripe configurée. La réservation sera créée sans paiement réel.',
                        style: TextStyle(color: Color(0xFFC2410C), fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(18),
            child: CardFormField(
              controller: _cardFormController,
              onCardChanged: (details) {
                setState(() => _cardComplete = details?.complete ?? false);
              },
              style: CardFormStyle(
                backgroundColor: _offWhite,
                borderColor: const Color(0xFFE2E8F0),
                borderRadius: 12,
                borderWidth: 1,
                textColor: _navy,
                placeholderColor: _textGrey,
              ),
            ),
          ),
        const SizedBox(height: 14),

        if (!_isSimulated)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF22C55E), size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Paiement 100 % sécurisé via Stripe. Vos données bancaires ne transitent pas par nos serveurs.',
                    style: TextStyle(color: Color(0xFF15803D), fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStickyButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: (_isSubmitting || (!_cardComplete && !_isSimulated)) ? null : _submit,
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
              : const Text('Valider la réservation',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
