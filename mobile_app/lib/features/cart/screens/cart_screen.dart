import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/dio_client.dart';
import '../../bookings/screens/booking_options_screen.dart';
import '../../search/screens/search_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  String? _error;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await DioClient.instance.get('/cart');
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List? ?? []).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger le panier';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    setState(() => _deletingId = cartItemId);
    try {
      await DioClient.instance.delete('/cart/items/$cartItemId');
      if (!mounted) return;
      await _loadCart();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de supprimer cet article'),
        backgroundColor: Color(0xFFEF4444),
      ));
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider le panier',
            style: TextStyle(color: Color(0xFF1B3A57), fontWeight: FontWeight.w800)),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous les articles de votre panier ?',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Vider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DioClient.instance.delete('/cart');
      if (!mounted) return;
      await _loadCart();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de vider le panier'),
        backgroundColor: Color(0xFFEF4444),
      ));
    }
  }

  void _reserveItem(Map<String, dynamic> item) {
    final product = _mapProduct(item);
    DateTime? startDate;
    DateTime? endDate;
    try {
      final rawStart = item['cart_item_start_date'] as String?;
      final rawEnd = item['cart_item_end_date'] as String?;
      if (rawStart != null) startDate = DateTime.parse(rawStart);
      if (rawEnd != null) endDate = DateTime.parse(rawEnd);
    } catch (_) {}
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingOptionsScreen(
          product: product,
          initialStartDate: startDate,
          initialEndDate: endDate,
        ),
      ),
    );
  }

  Map<String, dynamic> _mapProduct(Map<String, dynamic> item) {
    final p = item['product'] as Map<String, dynamic>? ?? {};
    final images = p['images'] as List?;
    return {
      'id': p['products_id'],
      'name': p['products_name'] as String? ?? '',
      'price': '${p['products_price_per_day']}€',
      'image': (images != null && images.isNotEmpty)
          ? images[0]['image_url'] as String? ?? ''
          : '',
      'category': p['products_category'] as String? ?? '',
      'stock': p['products_stock'] ?? 0,
      'description': p['products_description'] as String? ?? '',
    };
  }

  double get _total => _items.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item['cart_item_price_snapshot'].toString()) ?? 0.0));

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'
      ];
      return '${dt.day} ${months[dt.month]}';
    } catch (_) {
      return '—';
    }
  }

  int _nbDays(String? start, String? end) {
    if (start == null || end == null) return 0;
    try {
      return DateTime.parse(end).difference(DateTime.parse(start)).inDays.abs() + 1;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mon Panier',
                style: TextStyle(
                    color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w800)),
            if (_items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3C82F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_items.length}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9CA3AF)),
              onPressed: _clearCart,
              tooltip: 'Vider le panier',
            ),
        ],
      ),
      bottomNavigationBar: _items.isNotEmpty ? _buildSummaryBar() : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3C82F5)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A57),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Réessayer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCart,
      color: const Color(0xFF3C82F5),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _CartItemCard(
          item: _items[i],
          isDeleting: _deletingId == (_items[i]['cart_item_id'] as int?),
          formatDate: _formatDate,
          nbDays: _nbDays,
          onRemove: () => _removeItem(_items[i]['cart_item_id'] as int),
          onReserve: () => _reserveItem(_items[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE4F0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 52, color: Color(0xFF3C82F5)),
            ),
            const SizedBox(height: 24),
            const Text('Votre panier est vide',
                style: TextStyle(
                    color: Color(0xFF1B3A57), fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez des équipements depuis la recherche pour commencer une location.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A57),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                label: const Text('Parcourir les équipements',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total estimé',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    '${_total.toStringAsFixed(0)} €',
                    style: const TextStyle(
                        color: Color(0xFF1B3A57), fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${_items.length} article${_items.length > 1 ? 's' : ''}',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cart Item Card ────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDeleting;
  final String Function(String?) formatDate;
  final int Function(String?, String?) nbDays;
  final VoidCallback onRemove;
  final VoidCallback onReserve;

  const _CartItemCard({
    required this.item,
    required this.isDeleting,
    required this.formatDate,
    required this.nbDays,
    required this.onRemove,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final images = product['images'] as List?;
    final imageUrl = (images != null && images.isNotEmpty)
        ? images[0]['image_url'] as String? ?? ''
        : '';
    final name = product['products_name'] as String? ?? 'Équipement';
    final startRaw = item['cart_item_start_date'] as String?;
    final endRaw = item['cart_item_end_date'] as String?;
    final days = nbDays(startRaw, endRaw);
    final price = double.tryParse(item['cart_item_price_snapshot'].toString()) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: const Color(0xFFEEF3FA)),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFFEEF3FA),
                        child: const Icon(Icons.broken_image,
                            color: Colors.black26, size: 32),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFEEF3FA),
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.black26, size: 32),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            color: Color(0xFF1B3A57),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF9CA3AF)))
                        : GestureDetector(
                            onTap: onRemove,
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Color(0xFF9CA3AF), size: 20),
                          ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      '${formatDate(startRaw)} – ${formatDate(endRaw)}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined,
                        size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text(
                      '$days jour${days > 1 ? 's' : ''}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} €',
                      style: const TextStyle(
                          color: Color(0xFF3C82F5),
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        onPressed: onReserve,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1B3A57), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          'Réserver',
                          style: TextStyle(
                              color: Color(0xFF1B3A57),
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
