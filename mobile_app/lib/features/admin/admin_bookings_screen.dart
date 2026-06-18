import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

const _navy     = Color(0xFF1B3A57);
const _offWhite = Color(0xFFF4F7FA);
const _textGrey = Color(0xFF9CA3AF);

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final _scroll = ScrollController();

  static const _statusLabels = {
    'en attente':  'En attente',
    'confirmée':   'Confirmée',
    'en cours':    'En cours',
    'terminée':    'Terminée',
    'annulée':     'Annulée',
  };

  static const _statusColors = {
    'en attente': Color(0xFFF59E0B),
    'confirmée':  Color(0xFF3C82F5),
    'en cours':   Color(0xFF22C55E),
    'terminée':   Color(0xFF6B7280),
    'annulée':    Color(0xFFEF4444),
  };

  static const _nextStatuses = {
    'en attente': ['confirmée', 'annulée'],
    'confirmée':  ['en cours',  'annulée'],
    'en cours':   ['terminée'],
    'terminée':   <String>[],
    'annulée':    <String>[],
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
        !_isLoadingMore && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadBookings() async {
    setState(() { _isLoading = true; _error = null; _page = 1; });
    try {
      final res = await DioClient.instance.get('/bookings', queryParameters: {'page': 1, 'limit': 20});
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _bookings = items;
        _hasMore  = data['page'] < data['totalPages'];
        _page     = 2;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger les réservations'; _isLoading = false; });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final res = await DioClient.instance.get('/bookings',
          queryParameters: {'page': _page, 'limit': 20});
      final data = res.data as Map<String, dynamic>;
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() {
        _bookings.addAll(items);
        _hasMore = _page < (data['totalPages'] as int);
        _page++;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _changeStatus(Map<String, dynamic> booking, String newStatus) async {
    final id = booking['booking_id'] as int;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DioClient.instance.patch('/bookings/$id/status', data: {'status': newStatus});
      if (!mounted) return;
      setState(() {
        final idx = _bookings.indexWhere((b) => b['booking_id'] == id);
        if (idx >= 0) _bookings[idx] = {..._bookings[idx], 'booking_status': newStatus};
      });
      messenger.showSnackBar(SnackBar(
        content: Text('Statut mis à jour : ${_statusLabels[newStatus] ?? newStatus}'),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map && e.response!.data['message'] is String)
          ? e.response!.data['message'] as String
          : 'Erreur lors de la mise à jour';
      messenger.showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating));
    }
  }

  void _showStatusDialog(Map<String, dynamic> booking) {
    final current    = booking['booking_status'] as String? ?? '';
    final nextList   = _nextStatuses[current] ?? [];
    if (nextList.isEmpty) return;

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
            Text('Réservation #${booking['booking_id']}',
                style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Changer le statut', style: const TextStyle(color: _textGrey, fontSize: 13)),
            const SizedBox(height: 20),
            ...nextList.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeStatus(booking, s);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _statusColors[s] ?? _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(_statusLabels[s] ?? s,
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
        title: const Text('Réservations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadBookings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: _navy)))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length + (_isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      if (i == _bookings.length) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      return _buildBookingCard(_bookings[i]);
                    },
                  ),
                ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status     = booking['booking_status'] as String? ?? '';
    final statusColor = _statusColors[status] ?? _textGrey;
    final user       = booking['user'] as Map<String, dynamic>?;
    final userName   = user != null
        ? '${user['user_prenom'] ?? ''} ${user['user_nom'] ?? ''}'.trim()
        : 'Utilisateur inconnu';
    final payment    = booking['payment'] as Map<String, dynamic>?;
    final amount     = (payment?['payments_amount'] as num?)?.toStringAsFixed(0) ?? '-';
    final canChange  = (_nextStatuses[status] ?? []).isNotEmpty;

    final start = booking['booking_start_date'] as String? ?? '';
    final end   = booking['booking_end_date']   as String? ?? '';
    final startFmt = start.length >= 10 ? start.substring(0, 10) : start;
    final endFmt   = end.length   >= 10 ? end.substring(0, 10)   : end;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${booking['booking_id']}',
                  style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusLabels[status] ?? status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: _textGrey),
              const SizedBox(width: 6),
              Expanded(child: Text(userName,
                  style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: _textGrey),
              const SizedBox(width: 6),
              Text('$startFmt → $endFmt',
                  style: const TextStyle(color: _textGrey, fontSize: 12)),
              const Spacer(),
              Text('$amount €',
                  style: const TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          if (canChange) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F6FB)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton(
                onPressed: () => _showStatusDialog(booking),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _navy),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Changer le statut',
                    style: TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
