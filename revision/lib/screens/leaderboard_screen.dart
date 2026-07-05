import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      _Player(rank: 1, name: 'Aakash Sharma', score: 98, tests: 62, icon: Icons.workspace_premium_rounded, color: const Color(0xFFFFB800)),
      _Player(rank: 2, name: 'Priya Meena', score: 94, tests: 58, icon: Icons.military_tech_rounded, color: const Color(0xFF8892A4)),
      _Player(rank: 3, name: 'Ravi Gupta', score: 91, tests: 55, icon: Icons.military_tech_rounded, color: const Color(0xFFCD7F32)),
      _Player(rank: 4, name: 'Sunita Yadav', score: 88, tests: 47, icon: Icons.star_rounded, color: AppTheme.primary),
      _Player(rank: 5, name: 'You', score: 85, tests: 47, icon: Icons.person_rounded, color: const Color(0xFF6C63FF)),
      _Player(rank: 6, name: 'Deepak Kumar', score: 82, tests: 43, icon: Icons.star_rounded, color: AppTheme.primary),
      _Player(rank: 7, name: 'Kavita Singh', score: 79, tests: 38, icon: Icons.star_rounded, color: AppTheme.primary),
      _Player(rank: 8, name: 'Mohan Lal', score: 76, tests: 35, icon: Icons.star_rounded, color: AppTheme.primary),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Color(0xFFFFB800), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rankings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Top performers this week',
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Top 3 podium
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _PodiumItem(name: players[1].name, score: players[1].score, rank: 2, height: 70),
                      _PodiumItem(name: players[0].name, score: players[0].score, rank: 1, height: 95),
                      _PodiumItem(name: players[2].name, score: players[2].score, rank: 3, height: 55),
                    ],
                  ),
                ),
              ),
            ),

            // List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = players[i];
                    final isMe = p.name == 'You';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppTheme.primary.withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: isMe
                            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1.5)
                            : Border.all(color: AppTheme.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              '#${p.rank}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: p.rank <= 3
                                    ? const Color(0xFFFFB800)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: p.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p.icon, color: p.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isMe
                                        ? AppTheme.primary
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.tests} tests taken',
                                  style: const TextStyle(
                                      fontSize: 13, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${p.score}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: players.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Player {
  final int rank;
  final String name;
  final int score;
  final int tests;
  final IconData icon;
  final Color color;
  const _Player({
    required this.rank,
    required this.name,
    required this.score,
    required this.tests,
    required this.icon,
    required this.color,
  });
}

class _PodiumItem extends StatelessWidget {
  final String name;
  final int score;
  final int rank;
  final double height;

  const _PodiumItem({
    required this.name,
    required this.score,
    required this.rank,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color medalColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : const Color(0xFFCD7F32);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.workspace_premium_rounded, color: medalColor, size: rank == 1 ? 38 : 28),
        const SizedBox(height: 6),
        Text(
          name.split(' ').first,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text('$score%',
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: 65,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}
