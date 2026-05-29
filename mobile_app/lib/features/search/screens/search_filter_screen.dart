import 'package:flutter/material.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _destinationCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _destinationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? now.add(const Duration(days: 1)))
          : (_endDate ?? (_startDate ?? now).add(const Duration(days: 3))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B3A57),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'jj/mm/aaaa';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _search() {
    Navigator.pop(context, {
      'start_date': _startDate,
      'end_date': _endDate,
      'destination': _destinationCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F6FB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF1B3A57)),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Recherche',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1B3A57),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF3F6FB)),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Où ? ──
                    _SectionLabel(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFF3C82F5),
                      label: 'Où ?',
                    ),
                    const SizedBox(height: 10),
                    _InputField(
                      controller: _destinationCtrl,
                      hint: 'Sélectionnez votre destination',
                    ),
                    const SizedBox(height: 28),

                    // ── Quand ? ──
                    _SectionLabel(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF3C82F5),
                      label: 'Quand ?',
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date de début',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _pickDate(isStart: true),
                                child: _DateBox(label: _formatDate(_startDate)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date de fin',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _pickDate(isStart: false),
                                child: _DateBox(label: _formatDate(_endDate)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom button ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Rechercher l\'équipement',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SectionLabel({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1B3A57),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _InputField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF1B3A57), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  const _DateBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        label,
        style: TextStyle(
          color: label == 'jj/mm/aaaa' ? const Color(0xFF9CA3AF) : const Color(0xFF1B3A57),
          fontSize: 13,
        ),
      ),
    );
  }
}
