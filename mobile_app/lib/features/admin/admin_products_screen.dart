import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textGrey  = Color(0xFF9CA3AF);

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await DioClient.instance.get('/products', queryParameters: {'limit': 100});
      final items = ((res.data as Map)['items'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() { _products = items; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger les produits'; _isLoading = false; });
    }
  }

  void _showStockDialog(Map<String, dynamic> product) {
    final id    = product['products_id'] as int;
    final stock = product['products_stock'] as int? ?? 0;
    final ctrl  = TextEditingController(text: '$stock');

    showDialog(
      context: context,
      builder: (_) {
        final messenger = ScaffoldMessenger.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            product['products_name'] as String? ?? 'Produit',
            style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stock disponible',
                  style: TextStyle(color: _textGrey, fontSize: 13)),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: _blue, width: 1.5)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { ctrl.dispose(); Navigator.pop(context); },
              child: const Text('Annuler', style: TextStyle(color: _textGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () async {
                final newStock = int.tryParse(ctrl.text.trim());
                if (newStock == null || newStock < 0) return;
                Navigator.pop(context);
                ctrl.dispose();
                try {
                  await DioClient.instance.patch('/products/$id',
                      data: {'products_stock': newStock});
                  if (!mounted) return;
                  setState(() {
                    final idx = _products.indexWhere((p) => p['products_id'] == id);
                    if (idx >= 0) _products[idx] = {..._products[idx], 'products_stock': newStock};
                  });
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Stock mis à jour'),
                    backgroundColor: Color(0xFF22C55E),
                    behavior: SnackBarBehavior.floating,
                  ));
                } on DioException catch (e) {
                  final msg = (e.response?.data is Map && e.response!.data['message'] is String)
                      ? e.response!.data['message'] as String
                      : 'Erreur lors de la mise à jour';
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text(msg),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating));
                }
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStatusDialog(Map<String, dynamic> product) {
    final id     = product['products_id'] as int;
    final messenger = ScaffoldMessenger.of(context);

    const statuses = ['disponible', 'indisponible', 'maintenance'];
    const labels   = {'disponible': 'Disponible', 'indisponible': 'Indisponible', 'maintenance': 'Maintenance'};
    const colors   = <String, Color>{'disponible': Color(0xFF22C55E), 'indisponible': Color(0xFFEF4444), 'maintenance': Color(0xFFF59E0B)};

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Changer le statut',
                style: TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...statuses.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await DioClient.instance.patch('/products/$id',
                          data: {'products_status': s});
                      if (!mounted) return;
                      setState(() {
                        final idx = _products.indexWhere((p) => p['products_id'] == id);
                        if (idx >= 0) _products[idx] = {..._products[idx], 'products_status': s};
                      });
                      messenger.showSnackBar(SnackBar(
                        content: Text('Statut mis à jour : ${labels[s]}'),
                        backgroundColor: const Color(0xFF22C55E),
                        behavior: SnackBarBehavior.floating,
                      ));
                    } on DioException catch (e) {
                      final msg = (e.response?.data is Map && e.response!.data['message'] is String)
                          ? e.response!.data['message'] as String : 'Erreur';
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text(msg),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors[s] ?? _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(labels[s] ?? s,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Produits & Stock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadProducts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: _navy)))
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildProductCard(_products[i]),
                  ),
                ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> p) {
    final status      = p['products_status'] as String? ?? 'disponible';
    final stock       = p['products_stock'] as int? ?? 0;
    final price       = (p['products_price_per_day'] as num?)?.toDouble() ?? 0.0;

    const statusColors = <String, Color>{
      'disponible':   Color(0xFF22C55E),
      'indisponible': Color(0xFFEF4444),
      'maintenance':  Color(0xFFF59E0B),
    };
    const statusLabels = <String, String>{
      'disponible':   'Disponible',
      'indisponible': 'Indisponible',
      'maintenance':  'Maintenance',
    };

    final sColor = statusColors[status] ?? _textGrey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p['products_name'] as String? ?? '',
                  style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabels[status] ?? status,
                    style: TextStyle(color: sColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 13, color: _textGrey),
              const SizedBox(width: 5),
              Text(p['products_category'] as String? ?? '',
                  style: const TextStyle(color: _textGrey, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.euro_rounded, size: 13, color: _textGrey),
              const SizedBox(width: 3),
              Text('${price.toStringAsFixed(0)} €/j',
                  style: const TextStyle(color: _textGrey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F6FB)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Stock display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: stock > 0 ? _lightBlue : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 13,
                        color: stock > 0 ? _blue : const Color(0xFFEF4444)),
                    const SizedBox(width: 5),
                    Text('Stock : $stock',
                        style: TextStyle(
                          color: stock > 0 ? _blue : const Color(0xFFEF4444),
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStockDialog(p),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Modifier stock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    side: const BorderSide(color: _navy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _showStatusDialog(p),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textGrey,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                child: const Icon(Icons.more_vert_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
