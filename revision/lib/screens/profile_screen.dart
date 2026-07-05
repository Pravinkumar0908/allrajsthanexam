import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Pravin Kumar Verma',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rajasthan Exam Aspirant',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfileStat(label: 'Tests', value: '47'),
                          _vDivider(),
                          _ProfileStat(label: 'Best', value: '88%'),
                          _vDivider(),
                          _ProfileStat(label: 'Streak', value: '5d'),
                          _vDivider(),
                          _ProfileStat(label: 'Rank', value: '#5'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Achievements
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _AchievementBadge(
                      icon: Icons.local_fire_department_rounded,
                      label: '5 Day\nStreak',
                      color: Color(0xFFFF5757),
                    ),
                    _AchievementBadge(
                      icon: Icons.military_tech_rounded,
                      label: 'First\nTest',
                      color: Color(0xFFFFB800),
                    ),
                    _AchievementBadge(
                      icon: Icons.speed_rounded,
                      label: 'Speed\nDemon',
                      color: Color(0xFF6C63FF),
                    ),
                    _AchievementBadge(
                      icon: Icons.verified_rounded,
                      label: '10 Tests\nDone',
                      color: AppTheme.primary,
                    ),
                    _AchievementBadge(
                      icon: Icons.star_rounded,
                      label: 'Top 10\nRanker',
                      color: Color(0xFF14B8A6),
                    ),
                  ],
                ),
              ),
            ),

            // Settings / Options
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: false,
                      onChanged: (_) {},
                      activeThumbColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsItem(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    trailing: const Text(
                      'Hindi',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About App',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _SettingsItem(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppTheme.error),
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (e) {
                        debugPrint("Error signing out: $e");
                      }
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(opacity: anim, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _vDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
