import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/question.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.result.percentage)
        .animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '${min}m ${sec}s';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final isPassed = r.percentage >= 40;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.close,
                          size: 20, color: AppTheme.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── Score Circle ──
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, _) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: AppTheme.border, width: 1.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                r.categoryName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: CustomPaint(
                                        painter: _ScoreRingPainter(
                                          progress:
                                              _scoreAnimation.value / 100,
                                          color: isPassed
                                              ? AppTheme.success
                                              : AppTheme.error,
                                          bgColor: AppTheme.border,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_scoreAnimation.value.toInt()}%',
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.w800,
                                            color: isPassed
                                                ? AppTheme.success
                                                : AppTheme.error,
                                          ),
                                        ),
                                        Text(
                                          r.grade,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? AppTheme.success
                                          .withValues(alpha: 0.08)
                                      : AppTheme.error
                                          .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isPassed ? '🎉 Passed' : '📖 Keep Practicing',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isPassed
                                        ? AppTheme.success
                                        : AppTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Stats Row ──
                    Row(
                      children: [
                        _StatCard(
                          label: 'Correct',
                          value: '${r.correctAnswers}',
                          color: AppTheme.success,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Wrong',
                          value: '${r.wrongAnswers}',
                          color: AppTheme.error,
                          icon: Icons.cancel_outlined,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Skipped',
                          value: '${r.unanswered}',
                          color: AppTheme.textSecondary,
                          icon: Icons.remove_circle_outline_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Time taken
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.border, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 20, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            'Time: ${_formatDuration(r.timeTaken)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Show Details Toggle ──
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showDetails = !_showDetails),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppTheme.border, width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showDetails
                                  ? 'Hide Answer Review'
                                  : 'Show Answer Review',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _showDetails
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Answer Details ──
                    if (_showDetails) ...[
                      const SizedBox(height: 16),
                      ...List.generate(r.attempts.length, (i) {
                        final attempt = r.attempts[i];
                        return _AnswerReviewCard(
                          index: i,
                          attempt: attempt,
                        );
                      }),
                    ],

                        // ── Go Home Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
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

// ── Stat Card Widget ──
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1.0),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Answer Review Card ──
class _AnswerReviewCard extends StatelessWidget {
  final int index;
  final QuestionAttempt attempt;

  const _AnswerReviewCard({required this.index, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final q = attempt.question;
    final isCorrect = attempt.isCorrect;
    final isAttempted = attempt.isAttempted;

    Color statusColor;
    IconData statusIcon;
    if (!isAttempted) {
      statusColor = AppTheme.textSecondary;
      statusIcon = Icons.remove_circle_outline_rounded;
    } else if (isCorrect) {
      statusColor = AppTheme.success;
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = AppTheme.error;
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, size: 22, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Correct answer
          _answerRow(
            'Correct',
            q.options[q.correctIndex],
            AppTheme.success,
          ),
          if (isAttempted && !isCorrect) ...[
            const SizedBox(height: 6),
            _answerRow(
              'Your Answer',
              q.options[attempt.selectedIndex!],
              AppTheme.error,
            ),
          ],
          if (!isAttempted) ...[
            const SizedBox(height: 6),
            _answerRow('Your Answer', 'Not Answered', AppTheme.textSecondary),
          ],

          // Explanation
          if (q.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                q.explanation!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Score Ring Painter ──
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
