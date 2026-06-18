import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/screens/home_screen.dart';
import '../cart/screens/cart_screen.dart';
import '../bookings/screens/bookings_screen.dart';
import '../search/screens/search_tab_navigator.dart';
import '../profile/screens/profile_tab_navigator.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    SearchTabNavigator(),
    CartScreen(),
    BookingsScreen(),
    ProfileTabNavigator(),
  ];

  void _onTabTap(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _FloatingPillNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

// ── Navy bottom navigation bar with floating pill active indicator ─────────────

class _FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingPillNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,          iconSelected: Icons.home_rounded,          label: 'Accueil'),
    _NavItem(icon: Icons.search_rounded,         iconSelected: Icons.search_rounded,        label: 'Rechercher'),
    _NavItem(icon: Icons.shopping_cart_outlined, iconSelected: Icons.shopping_cart_rounded, label: 'Panier'),
    _NavItem(icon: Icons.event_note_outlined,    iconSelected: Icons.event_note_rounded,    label: 'Réservation'),
    _NavItem(icon: Icons.person_outline,         iconSelected: Icons.person_rounded,        label: 'Profil'),
  ];

  static const _navy = Color(0xFF1B3A57);
  static const _inactiveColor = Color(0x70FFFFFF);

  // Pill diameter that floats above the bar
  static const double _pillSize = 50.0;
  // How much the pill extends above the bar top edge
  static const double _pillOverlap = 14.0;
  // Bar body height (below pill overlap zone)
  static const double _barHeight = 62.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: _barHeight + _pillOverlap + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Bar background ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _barHeight + bottomPadding,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _navy,
                boxShadow: [
                  BoxShadow(color: Color(0x28000000), blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
            ),
          ),

          // ── Tab items ──
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding,
            height: _barHeight,
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final selected = i == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: SizedBox(
                      height: _barHeight,
                      child: selected
                          ? _ActiveTabItem(item: item, pillSize: _pillSize, pillOverlap: _pillOverlap, barHeight: _barHeight)
                          : _InactiveTabItem(item: item, inactiveColor: _inactiveColor),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTabItem extends StatelessWidget {
  final _NavItem item;
  final double pillSize;
  final double pillOverlap;
  final double barHeight;

  const _ActiveTabItem({
    required this.item,
    required this.pillSize,
    required this.pillOverlap,
    required this.barHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Floating pill (overflows above bar) ──
        Positioned(
          top: -(pillOverlap),
          child: Container(
            width: pillSize,
            height: pillSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              item.iconSelected,
              size: 24,
              color: const Color(0xFF1B3A57),
            ),
          ),
        ),
        // ── Label below the pill area ──
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _InactiveTabItem extends StatelessWidget {
  final _NavItem item;
  final Color inactiveColor;

  const _InactiveTabItem({required this.item, required this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, size: 22, color: inactiveColor),
        const SizedBox(height: 3),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: inactiveColor,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  const _NavItem({required this.icon, required this.iconSelected, required this.label});
}
