import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/dio_client.dart';
import 'search_filter_screen.dart';
import 'product_detail_screen.dart';

// ─── Tokens ───────────────────────────────────────────────────
const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textGrey  = Color(0xFF9CA3AF);
const _amber     = Color(0xFFF59E0B);

// ─── Widget ───────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialCategory;

  const SearchScreen({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategory,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedCategoryIndex = 0;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  static const _categories = [
    {'label': 'Tous',        'value': null,           'icon': Icons.grid_view_rounded},
    {'label': 'Repas',       'value': 'Repas',        'icon': Icons.chair_alt_rounded},
    {'label': 'Poussettes',  'value': 'Poussettes',   'icon': Icons.child_care_rounded},
    {'label': 'Lits',        'value': 'Lits',         'icon': Icons.bed_rounded},
    {'label': 'Sièges auto', 'value': 'Sièges auto',  'icon': Icons.event_seat_rounded},
    {'label': 'Jouets',      'value': 'Jouets',       'icon': Icons.toys_rounded},
  ];

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _error;
  bool _hasActiveFilter = false;

  @override
  void initState() {
    super.initState();
    _filterStartDate = widget.initialStartDate;
    _filterEndDate   = widget.initialEndDate;
    _hasActiveFilter = widget.initialStartDate != null || widget.initialEndDate != null;

    if (widget.initialCategory != null) {
      final idx = _categories.indexWhere(
        (c) => c['value'] == widget.initialCategory,
      );
      if (idx >= 0) _selectedCategoryIndex = idx;
    }
    _fetchProducts(category: _categories[_selectedCategoryIndex]['value'] as String?);
  }

  // ── Parse Decimal safely (handles num, String, and Prisma decimal.js object)
  static double _parseDecimal(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0.0;
    if (raw is Map) {
      // decimal.js {s, e, d} — extract via string round-trip
      final str = raw['toJSON']?.toString() ?? raw.toString();
      final parsed = double.tryParse(str);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  Future<void> _fetchProducts({String? category, String? q}) async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final queryParams = <String, dynamic>{'limit': 50};
      if (category != null) queryParams['category'] = category;
      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (_filterStartDate != null) {
        queryParams['start_date'] = _filterStartDate!.toIso8601String().substring(0, 10);
      }
      if (_filterEndDate != null) {
        queryParams['end_date'] = _filterEndDate!.toIso8601String().substring(0, 10);
      }

      final res = await DioClient.instance.get('/products', queryParameters: queryParams);
      final data  = res.data as Map<String, dynamic>;
      final items = (data['items'] as List? ?? []).cast<Map<String, dynamic>>();

      if (!mounted) return;
      setState(() {
        _products = items.map((p) {
          final images  = p['images'] as List?;
          final imageUrl = (images != null && images.isNotEmpty)
              ? (images[0]['image_url'] as String? ?? '')
              : '';
          final price = _parseDecimal(p['products_price_per_day']);
          return {
            'id':           p['products_id'],
            'name':         p['products_name'] as String? ?? '',
            'price':        '${price.toStringAsFixed(price == price.truncate() ? 0 : 2)}€',
            'price_num':    price,
            'image':        imageUrl,
            'category':     p['products_category'] as String? ?? '',
            'stock':        p['products_stock'] ?? 0,
            'description':  p['products_description'] as String? ?? '',
            'avg_rating':   (p['avg_rating'] as num?)?.toDouble() ?? 0.0,
            'review_count': p['review_count'] as int? ?? 0,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger les produits'; _isLoading = false; });
    }
  }

  void _onCategoryTap(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _fetchProducts(category: _categories[index]['value'] as String?);
  }

  Future<void> _openFilter() async {
    final filters = await Navigator.of(context, rootNavigator: true).push<Map<String, dynamic>>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const SearchFilterScreen()),
    );
    if (filters != null && mounted) {
      setState(() {
        _filterStartDate = filters['start_date'] as DateTime?;
        _filterEndDate   = filters['end_date'] as DateTime?;
        _hasActiveFilter = _filterStartDate != null || _filterEndDate != null;
      });
      _fetchProducts(category: _categories[_selectedCategoryIndex]['value'] as String?);
    }
  }

  void _clearFilter() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate   = null;
      _hasActiveFilter = false;
    });
    _fetchProducts(category: _categories[_selectedCategoryIndex]['value'] as String?);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            if (_hasActiveFilter) _buildFilterBanner(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    final title = _categories[_selectedCategoryIndex]['label'] as String;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: _navy),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Text(
            '${_products.length} produit${_products.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12, color: _textGrey),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _openFilter,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded, color: _textGrey, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Rechercher un équipement…',
                  style: TextStyle(color: _textGrey, fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(7),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: _blue, size: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = i == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => _onCategoryTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _navy : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                cat['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Active filter banner ────────────────────────────────────
  Widget _buildFilterBanner() {
    String dateRange = '';
    if (_filterStartDate != null && _filterEndDate != null) {
      dateRange = '${_fmt(_filterStartDate!)} → ${_fmt(_filterEndDate!)}';
    } else if (_filterStartDate != null) {
      dateRange = 'Dès le ${_fmt(_filterStartDate!)}';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _lightBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: _blue, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dateRange,
                style: const TextStyle(fontSize: 12, color: _navy, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: _clearFilter,
              child: const Icon(Icons.close_rounded, color: _navy, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_error != null) return _buildError();
    if (_products.isEmpty) return _buildEmpty();
    return _buildGrid();
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Impossible de charger les produits',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vérifiez votre connexion et réessayez.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 46,
              child: ElevatedButton(
                onPressed: () => _fetchProducts(
                  category: _categories[_selectedCategoryIndex]['value'] as String?,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Réessayer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.search_off_rounded, size: 36, color: _blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun équipement trouvé',
              style: TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez une autre catégorie\nou modifiez vos filtres.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textGrey, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      onRefresh: () => _fetchProducts(
        category: _categories[_selectedCategoryIndex]['value'] as String?,
      ),
      color: _blue,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.64,
        ),
        itemCount: _products.length,
        itemBuilder: (ctx, i) => _ProductCard(product: _products[i]),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  static List<Widget> _buildStarIcons(double rating) {
    final full    = rating.floor();
    final hasHalf = (rating - full) >= 0.3;
    final empty   = 5 - full - (hasHalf ? 1 : 0);
    return [
      ...List.generate(full,  (_) => const Icon(Icons.star_rounded,      size: 11, color: _amber)),
      if (hasHalf)                    const Icon(Icons.star_half_rounded, size: 11, color: _amber),
      ...List.generate(empty, (_) => const Icon(Icons.star_rounded,      size: 11, color: Color(0xFFE5E7EB))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final name        = product['name'] as String;
    final price       = product['price'] as String;
    final imageUrl    = product['image'] as String;
    final stock       = (product['stock'] as int?) ?? 0;
    final avgRating   = (product['avg_rating']   as double?) ?? 0.0;
    final reviewCount = (product['review_count'] as int?)    ?? 0;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ──
            Expanded(
              flex: 58,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox.expand(
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: _lightBlue),
                              errorWidget: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                  // Stock badge
                  if (stock <= 2 && stock > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Derniers $stock',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ),
                  if (stock == 0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Indisponible',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ──
            Expanded(
              flex: 42,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.3,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Stars + price row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ..._buildStarIcons(avgRating),
                            const SizedBox(width: 4),
                            Text(
                              reviewCount > 0 ? avgRating.toStringAsFixed(1) : 'Nouveau',
                              style: TextStyle(
                                fontSize: 10,
                                color: _textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Price + reserve
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: price,
                                    style: const TextStyle(
                                      color: _navy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/j',
                                    style: TextStyle(
                                      color: _textGrey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _blue,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: _lightBlue,
    child: const Center(
      child: Icon(Icons.child_care_rounded, color: _blue, size: 36),
    ),
  );
}

// ─── Skeleton loader ──────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 58,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEEF3FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            flex: 42,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(height: 12, width: double.infinity),
                  const SizedBox(height: 6),
                  _shimmer(height: 12, width: 80),
                  const Spacer(),
                  _shimmer(height: 8, width: 60),
                  const SizedBox(height: 8),
                  _shimmer(height: 16, width: double.infinity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({required double height, required double width}) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: const Color(0xFFEEF3FA),
      borderRadius: BorderRadius.circular(6),
    ),
  );
}
