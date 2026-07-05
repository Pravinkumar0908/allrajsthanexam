import 'package:flutter/material.dart';
import 'dart:async';
import '../data/question_bank.dart';
import '../theme/app_theme.dart';
import 'chapters_screen.dart';

// Map category IDs to real icons
const Map<String, IconData> _categoryIcons = {
  'rajasthan_gk': Icons.account_balance_rounded,
  'history': Icons.history_edu_rounded,
  'art_culture': Icons.palette_rounded,
  'geography': Icons.public_rounded,
  'polity': Icons.gavel_rounded,
  'science': Icons.science_rounded,
  'economy': Icons.show_chart_rounded,
  'hindi': Icons.translate_rounded,
  'current_affairs': Icons.newspaper_rounded,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlide;

  int _currentSlide = 0;
  late PageController _pageController;
  Timer? _timer;

  final List<String> _sliderImages = const [
    'assets/images/slider_one.png',
    'assets/images/slider_two.png',
    'assets/images/slider_three.png',
  ];

  // Mock stats data

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _headerController.forward();

    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentSlide < 2) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    _headerController.dispose();
    super.dispose();
  }



  void _startCategoryTest(int index) {
    final cat = QuestionBank.categories[index];
    final iconData = _categoryIcons[cat.id] ?? Icons.quiz_rounded;
    Navigator.push(
      context,
      _slideRoute(ChaptersScreen(
        category: cat,
        icon: iconData,
      )),
    );
  }

  PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(),
                ),
              ),

              // ── Stats Row ──

              // ── Image Slider ──
              SliverToBoxAdapter(child: _buildImageSlider()),


              // ── Categories Section ──
              SliverToBoxAdapter(child: _buildSectionTitle()),

              // ── Category Grid ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = QuestionBank.categories[index];
                      final color = AppTheme.categoryColors[
                          index % AppTheme.categoryColors.length];
                      final iconData = _categoryIcons[cat.id] ?? Icons.quiz_rounded;
                      return _CategoryCard(
                        name: cat.name,
                        icon: iconData,
                        description: cat.description,
                        questionCount: cat.questionCount,
                        color: color,
                        onTap: () => _startCategoryTest(index),
                        delay: index * 80,
                      );
                    },
                    childCount: QuestionBank.categories.length,
                  ),
                ),
              ),

              // ── Tips Banner ──
              SliverToBoxAdapter(child: _buildTipsBanner()),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ExamPrep Pro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Competitive Exam Mock Tests',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Notification Bell
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_outlined, color: AppTheme.primary, size: 24)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5757),
                      shape: BoxShape.circle,
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



  // ─────────────────────────────────────────
  // IMAGE SLIDER
  // ─────────────────────────────────────────
  Widget _buildImageSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
                itemCount: _sliderImages.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _sliderImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
              // Dots indicator inside card
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _sliderImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentSlide == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentSlide == index
                            ? AppTheme.primary
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ─────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────
  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '• Choose by topic',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // TIPS BANNER
  // ─────────────────────────────────────────
  Widget _buildTipsBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE4A0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Center(child: Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFFFB800),
                size: 22,
              )),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exam Tip of the Day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Attempt all questions — no negative marking in this test series!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A6500),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────
// CATEGORY CARD WIDGET
// ─────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final String description;
  final int questionCount;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.description,
    required this.questionCount,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pressed
                    ? widget.color.withValues(alpha: 0.3)
                    : AppTheme.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}