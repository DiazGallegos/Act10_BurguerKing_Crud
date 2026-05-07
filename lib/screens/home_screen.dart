import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/firebase_service.dart';
import '../theme/bk_theme.dart';
import 'crud_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userEmail;
  bool _seeding = true;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseService.currentUser?.email;
    _seedAndLoad();
  }

  Future<void> _seedAndLoad() async {
    try {
      await FirebaseService.seedDemoData();
    } catch (_) {}
    if (mounted) setState(() => _seeding = false);
  }

  void _signOut() async {
    await FirebaseService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0A00), Color(0xFF2D0800), Color(0xFF1A0A00)],
              ),
            ),
          ),

          // ── Decorative flame shapes ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAAD62300), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar row ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BK ADMIN',
                            style: TextStyle(
                              color: BKColors.yellow,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            _userEmail ?? '',
                            style: const TextStyle(
                              color: BKColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: BKColors.yellow),
                        tooltip: 'Cerrar sesión',
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ── Hero BK Logo ──
                        _HeroBKLogo()
                            .animate()
                            .fadeIn(duration: 700.ms)
                            .scale(begin: const Offset(0.6, 0.6)),
                        const SizedBox(height: 16),

                        Text(
                          'BURGER KING®',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: BKColors.yellow,
                            letterSpacing: 5,
                            shadows: [
                              Shadow(
                                  color: BKColors.red.withOpacity(0.9),
                                  blurRadius: 16)
                            ],
                          ),
                        ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3),

                        const SizedBox(height: 4),
                        Text(
                          'Sistema de Gestión Administrativo',
                          style: TextStyle(
                            color: BKColors.textSecondary,
                            fontSize: 13,
                            letterSpacing: 1.5,
                          ),
                        ).animate(delay: 250.ms).fadeIn(),

                        const SizedBox(height: 40),

                        // ── Stats Row ──
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.lunch_dining,
                              label: 'Hamburguesas',
                              color: BKColors.red,
                              onTap: () => _goToCrud('hamburguesa'),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.fastfood,
                              label: 'Combos',
                              color: BKColors.yellow,
                              onTap: () => _goToCrud('combo'),
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              icon: Icons.store,
                              label: 'Sucursales',
                              color: BKColors.brown,
                              onTap: () => _goToCrud('sucursal'),
                            ),
                          ],
                        )
                            .animate(delay: 350.ms)
                            .fadeIn()
                            .slideY(begin: 0.2),
                        const SizedBox(height: 32),

                        // ── Main CTA Button ──
                        _seeding
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: BKColors.yellow))
                            : SizedBox(
                                width: double.infinity,
                                height: 64,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.inventory_2_rounded,
                                      size: 26),
                                  label: const Text(
                                    'GESTIONAR INVENTARIO / SUCURSALES',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BKColors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    shadowColor:
                                        BKColors.red.withOpacity(0.5),
                                    elevation: 12,
                                  ),
                                  onPressed: () => _goToCrud(null),
                                ),
                              ).animate(delay: 450.ms).fadeIn().scale(
                                begin: const Offset(0.9, 0.9)),

                        const SizedBox(height: 20),

                        // ── Category quick buttons ──
                        Row(
                          children: [
                            Expanded(
                              child: _CategoryButton(
                                label: '🍔 Hamburguesas',
                                onTap: () => _goToCrud('hamburguesa'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CategoryButton(
                                label: '🍟 Combos',
                                onTap: () => _goToCrud('combo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CategoryButton(
                                label: '🏬 Locales',
                                onTap: () => _goToCrud('sucursal'),
                              ),
                            ),
                          ],
                        ).animate(delay: 550.ms).fadeIn(),

                        const SizedBox(height: 40),

                        // ── Slogan ──
                        Text(
                          '"Have it your way"',
                          style: TextStyle(
                            color: BKColors.textSecondary,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1,
                          ),
                        ).animate(delay: 600.ms).fadeIn(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToCrud(String? categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CrudScreen(filtroCategoria: categoria)),
    );
  }
}

// ── Hero BK Logo ────────────────────────────────────────────────────────────

class _HeroBKLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFE000), Color(0xFFF5A623), Color(0xFFE8940B)],
        ),
        boxShadow: [
          BoxShadow(
              color: BKColors.yellow.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 6),
          BoxShadow(
              color: BKColors.red.withOpacity(0.4),
              blurRadius: 50,
              spreadRadius: 10),
        ],
      ),
      child: const Center(
        child: Text(
          'BK',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: BKColors.red,
            letterSpacing: -3,
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: BKColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 12),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: BKColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Button ──────────────────────────────────────────────────────────

class _CategoryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: BKColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BKColors.brown.withOpacity(0.6)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: BKColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
