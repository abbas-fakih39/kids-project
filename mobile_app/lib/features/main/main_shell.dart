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
        bottomNavigationBar: _SimpleNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

// ── Navy bottom navigation bar (matches Figma maquette) ──────────────────────

class _SimpleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SimpleNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,          iconSelected: Icons.home_rounded,          label: 'Accueil'),
    _NavItem(icon: Icons.search_rounded,         iconSelected: Icons.search_rounded,        label: 'Rechercher'),
    _NavItem(icon: Icons.shopping_cart_outlined, iconSelected: Icons.shopping_cart_rounded, label: 'Panier'),
    _NavItem(icon: Icons.event_note_outlined,    iconSelected: Icons.event_note_rounded,    label: 'Réservation'),
    _NavItem(icon: Icons.person_outline,         iconSelected: Icons.person_rounded,        label: 'Profil'),
  ];

  static const _navy = Color(0xFF1B3A57);
  static const _activeColor = Colors.white;
  static const _inactiveColor = Color(0x80FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _navy,
        boxShadow: [
          BoxShadow(color: Color(0x30000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: Colors.white10,
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.iconSelected : item.icon,
                            key: ValueKey(selected),
                            size: 22,
                            color: selected ? _activeColor : _inactiveColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected ? _activeColor : _inactiveColor,
                            fontFamily: 'Inter',
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  const _NavItem({required this.icon, required this.iconSelected, required this.label});
}
