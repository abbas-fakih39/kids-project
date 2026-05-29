import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'booking_confirmation_screen.dart';

// ─── Tokens ───────────────────────────────────────────────────
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

  const PaymentScreen({
    super.key,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.deliveryMethod,
    required this.total,
    required this.deposit,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl   = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();
  bool _isSubmitting    = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
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

    final cardNumber = _cardNumberCtrl.text.replaceAll(' ', '');
    final cardName   = _cardNameCtrl.text.trim();
    final expiry     = _expiryCtrl.text.trim();
    final cvv        = _cvvCtrl.text.trim();

    if (cardNumber.length != 16) {
      _showError(messenger, 'Numéro de carte invalide (16 chiffres requis)');
      return;
    }
    if (cardName.isEmpty) {
      _showError(messenger, 'Veuillez saisir le nom sur la carte');
      return;
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry)) {
      _showError(messenger, "Date d'expiration invalide (MM/AA)");
      return;
    }
    if (cvv.length != 3) {
      _showError(messenger, 'CVV invalide (3 chiffres)');
      return;
    }

    setState(() => _isSubmitting = true);
    final nav = Navigator.of(context);
    try {
      final res = await DioClient.instance.post('/bookings', data: {
        'booking_start_date':    widget.startDate.toIso8601String().substring(0, 10),
        'booking_end_date':      widget.endDate.toIso8601String().substring(0, 10),
        'booking_delivery_method': widget.deliveryMethod,
        'items': [
          {'bp_product_id': widget.product['id'], 'bp_quantity': 1}
        ],
      });
      final booking = res.data as Map<String, dynamic>;
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

  // ── Header ────────────────────────────────────────────────
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
            child: Text(
              'Paiement',
              style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────
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

  // ── Recap card ────────────────────────────────────────────
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
              widget.deliveryMethod == 'livraison'
                  ? 'À domicile'
                  : 'Retrait en magasin'),
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
                  color: _blue, fontSize: 22, fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
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
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                color: _navy, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Payment section ───────────────────────────────────────
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Méthode de paiement',
            style: TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        // Wallet buttons
        Row(
          children: [
            Expanded(child: _walletBtn(Icons.apple, ' Pay', isBlack: true)),
            const SizedBox(width: 12),
            Expanded(child: _walletBtn(Icons.g_mobiledata_rounded, 'G Pay', isBlack: false)),
          ],
        ),
        const SizedBox(height: 16),

        // Or divider
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ],
        ),
        const SizedBox(height: 16),

        // Card form
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Carte bancaire',
                  style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _cardField(
                controller: _cardNumberCtrl,
                label: 'Numéro de carte',
                hint: '1234  5678  9012  3456',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                prefixIcon: Icons.credit_card_rounded,
              ),
              const SizedBox(height: 12),
              _cardField(
                controller: _cardNameCtrl,
                label: 'Nom sur la carte',
                hint: 'JEAN DUPONT',
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  UpperCaseTextFormatter(),
                ],
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _cardField(
                      controller: _expiryCtrl,
                      label: 'Expiration',
                      hint: 'MM/AA',
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        _ExpiryFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _cardField(
                        controller: _cvvCtrl,
                        label: 'CVV',
                        hint: '•••',
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Security note
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
                  'Paiement 100 % sécurisé et crypté. Vos données bancaires ne sont pas stockées.',
                  style: TextStyle(
                    color: Color(0xFF15803D), fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletBtn(IconData icon, String label, {required bool isBlack}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isBlack ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBlack ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isBlack ? Colors.white : _navy, size: 22),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color: isBlack ? Colors.white : _navy,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }

  Widget _cardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textGrey, fontSize: 14, fontWeight: FontWeight.w400),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: _textGrey, size: 18)
                : null,
            filled: true,
            fillColor: _offWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sticky button ─────────────────────────────────────────
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
              : const Text('Valider la réservation',
                  style: TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ─── Formatters ────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final digits = value.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return value.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    var text = value.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    return value.copyWith(text: value.text.toUpperCase());
  }
}
