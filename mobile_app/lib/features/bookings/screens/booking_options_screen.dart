import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'payment_screen.dart';

// ─── Tokens ───────────────────────────────────────────────────
const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textGrey  = Color(0xFF9CA3AF);
const _success   = Color(0xFF22C55E);

const _monthNames = [
  '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];
const _monthNamesShort = [
  '', 'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.',
];

class BookingOptionsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const BookingOptionsScreen({
    super.key,
    required this.product,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<BookingOptionsScreen> createState() => _BookingOptionsScreenState();
}

class _BookingOptionsScreenState extends State<BookingOptionsScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _startDate;
  DateTime? _endDate;

  bool _assuranceCasse = false;
  bool _assuranceVol   = false;
  int  _selectedLocation = 1; // 0=domicile, 1=paris, 2=lyon

  final _streetCtrl = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _zipCtrl    = TextEditingController();

  bool _isHygieneAccepted = false;
  bool _isAddingToCart    = false;

  late final double _pricePerDay;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate   = widget.initialEndDate;
    final raw = widget.product['price_num'];
    if (raw is num) {
      _pricePerDay = raw.toDouble();
    } else {
      final str = (widget.product['price'] as String? ?? '')
          .replaceAll(RegExp(r'[^0-9.]'), '');
      _pricePerDay = double.tryParse(str) ?? 15.0;
    }
  }

  // ── Pricing getters ──────────────────────────────────────
  int get _days {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }
  double get _locationCost  => _pricePerDay * _days;
  double get _optionsCost   => (_assuranceCasse ? 3.0 : 0.0) * _days
                             + (_assuranceVol   ? 2.0 : 0.0) * _days;
  double get _deliveryCost  => _selectedLocation == 0 ? 3.0 : 0.0;
  double get _appFee        => (_locationCost + _optionsCost + _deliveryCost) * 0.15;
  double get _subtotal      => _locationCost + _optionsCost + _deliveryCost + _appFee;

  bool get _hasDates   => _startDate != null && _endDate != null;
  bool get _needsAddress => _selectedLocation == 0;
  bool get _addressFilled => _streetCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty &&
      _zipCtrl.text.trim().isNotEmpty;
  bool get _canSubmit  => _hasDates && _isHygieneAccepted && (!_needsAddress || _addressFilled);

  String _fmtDay(DateTime dt) =>
      '${dt.day} ${_monthNamesShort[dt.month]}';

  // ── Add to cart ──────────────────────────────────────────
  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance.post('/cart/items', data: {
        'cart_item_product_id': widget.product['id'],
        'cart_item_quantity': 1,
        'cart_item_start_date': _startDate!.toIso8601String().substring(0, 10),
        'cart_item_end_date':   _endDate!.toIso8601String().substring(0, 10),
      });
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Ajouté au panier !'),
        backgroundColor: _success,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : "Impossible d'ajouter au panier";
      messenger.showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text("Impossible d'ajouter au panier"),
        backgroundColor: Color(0xFFEF4444),
      ));
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  // ── Navigate to payment ───────────────────────────────────
  void _goToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          product: widget.product,
          startDate: _startDate!,
          endDate: _endDate!,
          deliveryMethod: _selectedLocation == 0 ? 'livraison' : 'retrait_en_magasin',
          total: _subtotal,
          deposit: 150,
          deliveryStreet: _needsAddress ? _streetCtrl.text.trim() : null,
          deliveryCity:   _needsAddress ? _cityCtrl.text.trim()   : null,
          deliveryZip:    _needsAddress ? _zipCtrl.text.trim()     : null,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductCard(),
                  const SizedBox(height: 8),
                  _buildStepProgress(step: 1),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sélectionnez vos dates', Icons.calendar_month_rounded),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  if (_hasDates) ...[
                    const SizedBox(height: 8),
                    _buildDateBanner(),
                  ],
                  const SizedBox(height: 28),
                  _buildSectionTitle('Options supplémentaires', Icons.add_circle_outline_rounded),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildOptionTile(
                          icon: Icons.shield_outlined,
                          title: 'Assurance casse',
                          subtitle: 'Couvre les dommages accidentels sur l\'équipement',
                          price: '+3 €/jour',
                          selected: _assuranceCasse,
                          onTap: () => setState(() => _assuranceCasse = !_assuranceCasse),
                        ),
                        const SizedBox(height: 10),
                        _buildOptionTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Assurance vol',
                          subtitle: 'Couvre le vol de l\'équipement pendant la location',
                          price: '+2 €/jour',
                          selected: _assuranceVol,
                          onTap: () => setState(() => _assuranceVol = !_assuranceVol),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Lieu de récupération', Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildLocationTile(
                          index: 0,
                          icon: Icons.home_outlined,
                          title: 'Livraison à domicile',
                          subtitle: 'Livraison et retour à votre adresse',
                          badge: '+3 €',
                          badgeColor: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 10),
                        _buildLocationTile(
                          index: 1,
                          icon: Icons.storefront_outlined,
                          title: 'Paris Centre',
                          subtitle: '45 Rue de Rivoli, 75001 Paris',
                          badge: 'Gratuit',
                          badgeColor: _success,
                        ),
                        const SizedBox(height: 10),
                        _buildLocationTile(
                          index: 2,
                          icon: Icons.storefront_outlined,
                          title: 'Lyon Bellecour',
                          subtitle: '12 Place Bellecour, 69002 Lyon',
                          badge: 'Gratuit',
                          badgeColor: _success,
                        ),
                      ],
                    ),
                  ),
                  if (_needsAddress) ...[
                    const SizedBox(height: 28),
                    _buildSectionTitle('Adresse de livraison', Icons.local_shipping_outlined),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildAddressFields(),
                    ),
                  ],
                  if (_hasDates) ...[
                    const SizedBox(height: 28),
                    _buildPriceSummary(),
                  ],
                  const SizedBox(height: 28),
                  _buildHygieneCheckbox(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 4,
        right: 20,
        bottom: 4,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _navy),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.product['name'] as String? ?? 'Réserver',
              style: const TextStyle(
                color: _navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Product card ─────────────────────────────────────────
  Widget _buildProductCard() {
    final imageUrl = widget.product['image'] as String? ?? '';
    final price    = _pricePerDay.toStringAsFixed(
        _pricePerDay == _pricePerDay.truncate() ? 0 : 2);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: _lightBlue),
                      errorWidget: (_, __, ___) =>
                          Container(color: _lightBlue, child: const Icon(Icons.child_care_rounded, color: _blue, size: 32)),
                    )
                  : Container(color: _lightBlue, child: const Icon(Icons.child_care_rounded, color: _blue, size: 32)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product['name'] as String? ?? '',
                  style: const TextStyle(
                    color: _navy, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$price€',
                        style: const TextStyle(
                          color: _blue, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const TextSpan(
                        text: ' / jour',
                        style: TextStyle(color: _textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step progress ─────────────────────────────────────────
  Widget _buildStepProgress({required int step}) {
    const steps = ['Dates', 'Paiement', 'Confirmé'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final filled = (i ~/ 2) < step - 1;
            return Expanded(
              child: Container(
                height: 2,
                color: filled ? _blue : _lightBlue,
              ),
            );
          }
          final idx = i ~/ 2;
          final done   = idx < step - 1;
          final active = idx == step - 1;
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
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: active ? Colors.white : _blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[idx],
                style: TextStyle(
                  fontSize: 10,
                  color: active ? _navy : _textGrey,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: _blue, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: _navy, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  // ── Date banner (shows selected dates) ───────────────────
  Widget _buildDateBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _lightBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: _blue, size: 16),
            const SizedBox(width: 10),
            Text(
              '${_fmtDay(_startDate!)} → ${_fmtDay(_endDate!)}',
              style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$_days jour${_days > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Calendar ──────────────────────────────────────────────
  Widget _buildCalendar() {
    final year  = _currentMonth.year;
    final month = _currentMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Monday=1 → offset=0, ..., Sunday=7 → offset=6
    final firstWeekday = DateTime(year, month, 1).weekday;
    final offset       = (firstWeekday - 1) % 7;
    final daysInPrev   = DateTime(year, month, 0).day;
    final today        = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            // ── Month nav ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _calNavBtn(Icons.chevron_left_rounded, () {
                  setState(() => _currentMonth = DateTime(year, month - 1));
                }),
                Text(
                  '${_monthNames[month]} $year',
                  style: const TextStyle(
                    color: _navy, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                _calNavBtn(Icons.chevron_right_rounded, () {
                  setState(() => _currentMonth = DateTime(year, month + 1));
                }),
              ],
            ),
            const SizedBox(height: 16),

            // ── Week headers (French, starts Monday) ──
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) {
                return Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      color: _textGrey, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),

            // ── Days grid ──
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: 1.1,
              children: [
                // Previous month padding
                ...List.generate(offset, (i) => Center(
                  child: Text(
                    '${daysInPrev - offset + i + 1}',
                    style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                  ),
                )),

                // Current month days
                ...List.generate(daysInMonth, (i) {
                  final day  = i + 1;
                  final date = DateTime(year, month, day);
                  final isPast = date.isBefore(today);

                  final isStart  = _startDate == date;
                  final isEnd    = _endDate == date;
                  final isMiddle = _startDate != null && _endDate != null &&
                      date.isAfter(_startDate!) && date.isBefore(_endDate!);
                  final isSelected = isStart || isEnd || isMiddle;

                  return GestureDetector(
                    onTap: isPast ? null : () {
                      setState(() {
                        if (_startDate == null || _endDate != null) {
                          _startDate = date;
                          _endDate   = null;
                        } else {
                          if (date.isBefore(_startDate!)) {
                            _startDate = date;
                          } else {
                            _endDate = date;
                          }
                        }
                      });
                    },
                    child: _CalDay(
                      day: day,
                      isPast: isPast,
                      isStart: isStart,
                      isEnd: isEnd,
                      isMiddle: isMiddle,
                      isSelected: isSelected,
                      hasEnd: _endDate != null,
                    ),
                  );
                }),

                // Next month padding
                ...List.generate(
                  (7 - (offset + daysInMonth) % 7) % 7,
                  (i) => Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _offWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _navy, size: 22),
      ),
    );
  }

  // ── Option tile ───────────────────────────────────────────
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _blue : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? _lightBlue : _offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? _blue : _textGrey, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: _navy, fontSize: 13, fontWeight: FontWeight.w700,
                        decoration: selected ? TextDecoration.none : null)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(price,
                style: TextStyle(
                  color: selected ? _blue : _textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _blue : _textGrey,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Location tile ─────────────────────────────────────────
  Widget _buildLocationTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    final selected = _selectedLocation == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedLocation = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _blue : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _blue : _textGrey,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _blue : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: selected ? _lightBlue : _offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: selected ? _blue : _textGrey, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: _navy, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Address fields ────────────────────────────────────────
  Widget _buildAddressFields() {
    const inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _blue, width: 1.5),
      ),
    );
    return Column(
      children: [
        TextField(
          controller: _streetCtrl,
          onChanged: (_) => setState(() {}),
          decoration: inputDecoration.copyWith(hintText: 'Rue et numéro'),
          style: const TextStyle(color: _navy, fontSize: 14),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _cityCtrl,
                onChanged: (_) => setState(() {}),
                decoration: inputDecoration.copyWith(hintText: 'Ville'),
                style: const TextStyle(color: _navy, fontSize: 14),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _zipCtrl,
                onChanged: (_) => setState(() {}),
                decoration: inputDecoration.copyWith(hintText: 'Code postal'),
                style: const TextStyle(color: _navy, fontSize: 14),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Price summary ─────────────────────────────────────────
  Widget _buildPriceSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _priceRow('Location $_days jour${_days > 1 ? 's' : ''}',
                      '${_locationCost.toStringAsFixed(0)} €'),
                  if (_optionsCost > 0) ...[
                    const SizedBox(height: 10),
                    _priceRow('Assurances', '${_optionsCost.toStringAsFixed(0)} €'),
                  ],
                  if (_deliveryCost > 0) ...[
                    const SizedBox(height: 10),
                    _priceRow('Livraison', '${_deliveryCost.toStringAsFixed(0)} €'),
                  ],
                  const SizedBox(height: 10),
                  _priceRow('Frais de service (15 %)', '${_appFee.toStringAsFixed(0)} €',
                      valueColor: _textGrey),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _priceRow('Sous-total', '${_subtotal.toStringAsFixed(0)} €',
                  bold: true, valueColor: _navy, fontSize: 16),
            ),
            // Deposit info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: _textGrey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Dépôt de garantie 150 € — bloqué temporairement, restitué après retour.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {
    bool bold = false,
    Color? valueColor,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: const Color(0xFF6B7280), fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(
          color: valueColor ?? _navy, fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }

  // ── Hygiene checkbox ──────────────────────────────────────
  Widget _buildHygieneCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHygieneAccepted ? _blue : const Color(0xFFE2E8F0)),
        ),
        child: GestureDetector(
          onTap: () => setState(() => _isHygieneAccepted = !_isHygieneAccepted),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _isHygieneAccepted ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isHygieneAccepted ? _blue : _textGrey,
                    width: 1.5,
                  ),
                ),
                child: _isHygieneAccepted
                    ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'J\'accepte la charte d\'hygiène',
                      style: TextStyle(
                        color: _navy, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Je m\'engage à rendre le matériel propre et en bon état.',
                      style: TextStyle(
                        color: Color(0xFF6B7280), fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasDates) ...[
            SizedBox(
              height: 46,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _navy))
                    : const Icon(Icons.shopping_cart_outlined, size: 18, color: _navy),
                label: const Text('Ajouter au panier',
                    style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _navy, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _goToPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit ? _navy : const Color(0xFFCBD5E1),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _hasDates
                        ? 'Passer au paiement — ${_subtotal.toStringAsFixed(0)} €'
                        : 'Sélectionnez vos dates',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  if (_canSubmit) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Calendar day cell ────────────────────────────────────────

class _CalDay extends StatelessWidget {
  final int  day;
  final bool isPast, isStart, isEnd, isMiddle, isSelected, hasEnd;

  const _CalDay({
    required this.day,
    required this.isPast,
    required this.isStart,
    required this.isEnd,
    required this.isMiddle,
    required this.isSelected,
    required this.hasEnd,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isPast
        ? const Color(0xFFD1D5DB)
        : isStart || isEnd
            ? Colors.white
            : isMiddle
                ? _navy
                : _navy;

    return Stack(
      children: [
        // Range background (middle days)
        if (isMiddle)
          Positioned.fill(
            child: Container(color: _lightBlue),
          ),
        // Half-backgrounds for start/end endpoints
        if (isStart && hasEnd)
          Positioned(
            right: 0, top: 0, bottom: 0,
            width: 20,
            child: Container(color: _lightBlue),
          ),
        if (isEnd && isSelected)
          Positioned(
            left: 0, top: 0, bottom: 0,
            width: 20,
            child: Container(color: _lightBlue),
          ),
        // Circle for start/end
        if (isStart || isEnd)
          Center(
            child: Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        // Day number
        Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: (isStart || isEnd) ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
