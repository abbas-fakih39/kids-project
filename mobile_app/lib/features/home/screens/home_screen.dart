import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../search/screens/search_filter_screen.dart';
import '../../search/screens/search_screen.dart';

// ─── Tokens (miroir du design system CLAUDE.md) ───────────────
const _navy      = Color(0xFF1B3A57);
const _blue      = Color(0xFF3C82F5);
const _lightBlue = Color(0xFFDDE9FE);
const _offWhite  = Color(0xFFF4F7FA);
const _textDark  = Color(0xFF334155);
const _textGrey  = Color(0xFF9CA3AF);
const _amber     = Color(0xFFF59E0B);

// ─── Données statiques ────────────────────────────────────────

class _Category {
  final String label;
  final String imageUrl;
  final String? searchValue;
  const _Category(this.label, this.imageUrl, {this.searchValue});
}

const _categories = [
  _Category(
    'Repas &\nAlimentation',
    'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=600&q=80',
    searchValue: 'Repas',
  ),
  _Category(
    'Poussettes &\nChariots',
    'https://images.unsplash.com/photo-1591129938363-f24cb7340dcd?w=600&q=80',
    searchValue: 'Poussettes',
  ),
  _Category(
    'Lits &\nSommeil',
    'https://images.unsplash.com/photo-1544126592-807ade215a0b?w=600&q=80',
    searchValue: 'Lits',
  ),
  _Category(
    'Sièges Auto',
    'https://images.unsplash.com/photo-1512497676759-4bf5d39bb3e3?w=600&q=80',
    searchValue: 'Sièges auto',
  ),
  _Category(
    'Jouets & Jeux',
    'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=600&q=80',
    searchValue: 'Jouets',
  ),
  _Category(
    'Packs',
    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
  ),
];

class _Step {
  final IconData icon;
  final String number;
  final String title;
  final String desc;
  const _Step(this.icon, this.number, this.title, this.desc);
}

const _steps = [
  _Step(
    Icons.smartphone_rounded,
    '01',
    'Choisissez',
    'Sélectionnez votre matériel et vos dates de location sur l\'application.',
  ),
  _Step(
    Icons.calendar_month_rounded,
    '02',
    'Réservez',
    'Retrait en agence ou livraison à domicile, gare ou aéroport partout en France.',
  ),
  _Step(
    Icons.verified_rounded,
    '03',
    'Profitez',
    'Paiement sécurisé en ligne. Le matériel vous attend, propre et prêt à l\'emploi.',
  ),
];

const _reviews = [
  {
    'name': 'Natacha D.',
    'location': 'San Francisco, California',
    'stars': 5,
    'text': '"They saved our Disney experience when our stroller got a flat tire. Wonderful and friendly service. Stroller was clean and worked perfectly. Will definitely use them in the future again!"',
  },
  {
    'name': 'Thomas M.',
    'location': 'Paris, France',
    'stars': 5,
    'text': '"Livraison rapide, matériel propre et en excellent état. Je recommande vivement Kits & Kids pour tous vos voyages en famille !"',
  },
  {
    'name': 'Nina S.',
    'location': 'Lyon, France',
    'stars': 4,
    'text': '"Très bonne expérience globale. Le siège auto était conforme à la description et parfaitement installé."',
  },
];

// ─── Screen ───────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _buildCategories(context),
                const SizedBox(height: 36),
                _buildHowItWorks(),
                const SizedBox(height: 36),
                _buildStats(),
                const SizedBox(height: 24),
                _buildTrustBadge(),
                const SizedBox(height: 36),
                _buildReviews(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: _lightBlue,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: 24,
          right: 24,
          bottom: 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo row
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'K.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kits & Kids',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Location d\'équipements bébé',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search bar
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const SearchFilterScreen(),
                ),
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, color: _textGrey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Qu'avez-vous besoin d'équipements ?",
                        style: const TextStyle(
                          color: _textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: _blue,
                        size: 18,
                      ),
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

  // ── Nos catégories ─────────────────────────────────────────
  Widget _buildCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nos catégories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) => _CategoryCard(
              cat: _categories[i],
              onTap: () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) =>
                      SearchScreen(initialCategory: _categories[i].searchValue),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Comment ça marche ──────────────────────────────────────
  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Comment ça marche',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _navy,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          _steps.length,
          (i) => _StepRow(step: _steps[i], isLast: i == _steps.length - 1),
        ),
      ],
    );
  }

  // ── Stats ──────────────────────────────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              iconColor: _amber,
              iconBg: const Color(0xFFFEF3C7),
              number: '22 000+',
              label: 'avis 5 étoiles',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.event_available_rounded,
              iconColor: _blue,
              iconBg: _lightBlue,
              number: '47 000+',
              label: 'réservations',
            ),
          ),
        ],
      ),
    );
  }

  // ── Propre, Sûr & Assuré ──────────────────────────────────
  Widget _buildTrustBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Propre, Sûr & Assuré',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tout le matériel est nettoyé, vérifié et assuré avant chaque location. Votre sécurité, notre priorité.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.55,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'En savoir plus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reviews ────────────────────────────────────────────────
  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Ce que disent nos clients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _navy,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ReviewCard(review: _reviews[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Category Card ────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final _Category cat;
  final VoidCallback onTap;
  const _CategoryCard({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            CachedNetworkImage(
              imageUrl: cat.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: _lightBlue),
              errorWidget: (_, __, ___) => Container(color: _lightBlue),
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            // Label
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                cat.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  shadows: [
                    Shadow(color: Color(0x40000000), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step Row ─────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final _Step step;
  final bool isLast;
  const _StepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + connector
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _lightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(step.icon, color: _blue, size: 24),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Text(
                          step.number,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String number;
  final String label;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _navy,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = review['stars'] as int;
    return Container(
      width: 272,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 15,
                color: i < stars ? _amber : const Color(0xFFE5E7EB),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Review text
          Expanded(
            child: Text(
              review['text'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: _textDark,
                height: 1.55,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            ),
          ),
          const SizedBox(height: 12),
          // Reviewer
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: _lightBlue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (review['name'] as String)[0],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    if ((review['location'] as String?)?.isNotEmpty == true)
                      Text(
                        review['location'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _textGrey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
