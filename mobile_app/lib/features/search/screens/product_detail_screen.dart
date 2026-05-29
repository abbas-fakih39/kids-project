import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/dio_client.dart';
import '../../bookings/screens/booking_options_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _showDetails = true;

  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });
    try {
      final res = await DioClient.instance
          .get('/reviews/product/${widget.product['id']}');
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List? ?? []).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _reviews = items;
        _isLoadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviewsError = 'Impossible de charger les avis';
        _isLoadingReviews = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inDays < 1) return "aujourd'hui";
    if (diff.inDays == 1) return '1 jour';
    if (diff.inDays < 7) return '${diff.inDays} jours';
    if (diff.inDays < 14) return '1 semaine';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} semaines';
    if (diff.inDays < 60) return '1 mois';
    return '${(diff.inDays / 30).floor()} mois';
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold<int>(0, (s, r) => s + (r['review_rating'] as int? ?? 0));
    return sum / _reviews.length;
  }

  double _starPercent(int star) {
    if (_reviews.isEmpty) return 0;
    return _reviews.where((r) => r['review_rating'] == star).length / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildReserveButton(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Header ──
            Container(
              height: 380,
              width: double.infinity,
              color: const Color(0xFFDDE9FE),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: (widget.product['image'] as String? ?? '').isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.product['image'] as String,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 1.5),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 64, color: Colors.black26),
                              )
                            : const Icon(Icons.image_not_supported, size: 64, color: Colors.black26),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0x15000000), blurRadius: 10, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.close_rounded, color: Color(0xFF1B3A57), size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3A57),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.product['price']!,
                          style: const TextStyle(
                              color: Color(0xFF3C82F5), fontWeight: FontWeight.w800, fontSize: 26),
                        ),
                        const TextSpan(
                          text: ' / jour',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Custom Segmented Control (Détails / Avis) ──
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showDetails = true),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _showDetails ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _showDetails
                                    ? const [
                                        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Détails',
                                style: TextStyle(
                                  color: const Color(0xFF1B3A57),
                                  fontWeight: _showDetails ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showDetails = false),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: !_showDetails ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: !_showDetails
                                    ? const [
                                        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Avis',
                                style: TextStyle(
                                  color: const Color(0xFF1B3A57),
                                  fontWeight: !_showDetails ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Tab Content ──
                  if (_showDetails) _buildDetails() else _buildAvis(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky reserve button ──
  Widget _buildReserveButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingOptionsScreen(product: widget.product),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B3A57),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
          label: const Text(
            'Réserver maintenant',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ── Tab 1: Détails ──
  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1B3A57)),
        ),
        const SizedBox(height: 12),
        Text(
          (widget.product['description'] as String? ?? '').isNotEmpty
              ? widget.product['description'] as String
              : 'Aucune description disponible.',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 24),
        const Text(
          'Caractéristiques',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1B3A57)),
        ),
        const SizedBox(height: 16),
        _buildBullet('Livraison et retour gratuits'),
        const SizedBox(height: 10),
        _buildBullet('Nettoyé et désinfecté après chaque location'),
        const SizedBox(height: 10),
        _buildBullet('Support client 7j/7'),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 12.0),
          child: CircleAvatar(radius: 2.5, backgroundColor: Color(0xFF3C82F5)),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Avis ──
  Widget _buildAvis() {
    if (_isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF3C82F5)),
        ),
      );
    }

    if (_reviewsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_reviewsError!, style: const TextStyle(color: Color(0xFF6B7280))),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aucun avis pour ce produit.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    _avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF1B3A57)),
                  ),
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < _avgRating.round()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 16,
                            )),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_reviews.length} avis',
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1]
                      .map((s) => _buildBar(s, _starPercent(s)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(_reviews.length, (i) {
          final r = _reviews[i];
          final user = r['user'] as Map<String, dynamic>? ?? {};
          final nom = user['user_nom'] as String? ?? '';
          final prenom = user['user_prenom'] as String? ?? '';
          final initials = '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
              .toUpperCase();
          final date = _formatDate(r['review_created_at'] as String? ?? DateTime.now().toIso8601String());
          final comment = r['review_comment'] as String? ?? '';
          final rating = r['review_rating'] as int? ?? 0;

          return Column(
            children: [
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFF3F6FB), height: 1),
                ),
              _buildReview(initials, '$prenom $nom', date, comment, rating),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBar(int star, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFFF59E0B),
              minHeight: 5,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(String initials, String name, String date, String text, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE4F0FF),
              child: Text(
                initials,
                style: const TextStyle(color: Color(0xFF1B3A57), fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Color(0xFF1B3A57), fontSize: 13)),
                  Text('Il y a $date', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                ],
              ),
            ),
            Row(
              children: List.generate(
                  5,
                  (i) => Icon(
                        i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 14,
                      )),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5)),
      ],
    );
  }
}
