import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryName;
  final List<Question> questions;
  final int timeInMinutes;

  const QuizScreen({
    super.key,
    required this.categoryName,
    required this.questions,
    required this.timeInMinutes,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeInMinutes * 60;
    _startTimer();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitQuiz();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String get _timeDisplay {
    final min = _remainingSeconds ~/ 60;
    final sec = _remainingSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds <= 60) return AppTheme.error;
    if (_remainingSeconds <= 180) return AppTheme.warning;
    return AppTheme.textPrimary;
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedAnswers[_currentIndex] = optionIndex;
    });
  }

  void _goToQuestion(int index) {
    _slideController.reset();
    setState(() {
      _currentIndex = index;
    });
    _slideController.forward();
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      _goToQuestion(_currentIndex + 1);
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      _goToQuestion(_currentIndex - 1);
    }
  }

  void _submitQuiz() {
    _timer?.cancel();

    final timeTaken = Duration(
      seconds: (widget.timeInMinutes * 60) - _remainingSeconds,
    );

    final attempts = <QuestionAttempt>[];
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final selected = _selectedAnswers[i];
      final attempt = QuestionAttempt(
        question: widget.questions[i],
        selectedIndex: selected,
      );
      attempts.add(attempt);

      if (selected == null) {
        unanswered++;
      } else if (selected == widget.questions[i].correctIndex) {
        correct++;
      } else {
        wrong++;
      }
    }

    final result = QuizResult(
      categoryName: widget.categoryName,
      totalQuestions: widget.questions.length,
      correctAnswers: correct,
      wrongAnswers: wrong,
      unanswered: unanswered,
      timeTaken: timeTaken,
      attempts: attempts,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: result),
      ),
    );
  }

  void _showSubmitDialog() {
    final answered = _selectedAnswers.length;
    final total = widget.questions.length;
    final unanswered = total - answered;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Submit Test?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Answered', '$answered', AppTheme.success),
            const SizedBox(height: 8),
            _buildDialogRow(
                'Unanswered', '$unanswered', AppTheme.textSecondary),
            const SizedBox(height: 8),
            _buildDialogRow('Time Left', _timeDisplay, _timerColor),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  void _showQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jump to Question',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendDot(AppTheme.primary, 'Current'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.success, 'Answered'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.border, 'Not Answered'),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(widget.questions.length, (i) {
                final isSelected = _selectedAnswers.containsKey(i);
                final isCurrent = i == _currentIndex;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _goToQuestion(i);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary
                          : isSelected
                              ? AppTheme.success.withValues(alpha: 0.12)
                              : AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primary
                            : isSelected
                                ? AppTheme.success
                                : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Colors.white
                              : isSelected
                                  ? AppTheme.success
                                  : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final selectedOption = _selectedAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
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
                      onTap: _showExitDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timerColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 16, color: _timerColor),
                          const SizedBox(width: 6),
                          Text(
                            _timeDisplay,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _timerColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showQuestionNavigator,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: const Icon(Icons.grid_view_rounded,
                            size: 18, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Progress ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primary),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Question + Options ──
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: AppTheme.border, width: 1.0),
                            ),
                            child: Text(
                              question.question,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Options
                          ...List.generate(question.options.length, (i) {
                            final isSelected = selectedOption == i;
                            final optionLetter =
                                String.fromCharCode(65 + i); // A, B, C, D

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => _selectOption(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary.withValues(alpha: 0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.border,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.primaryLight,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            optionLetter,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          question.options[i],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.primary
                                                : AppTheme.textPrimary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.primary,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom Navigation ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppTheme.border, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    // Previous
                    if (_currentIndex > 0)
                      GestureDetector(
                        onTap: _prevQuestion,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back_ios_rounded,
                                  size: 14, color: AppTheme.primary),
                              SizedBox(width: 6),
                              Text(
                                'Prev',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    // Next or Submit
                    GestureDetector(
                      onTap: _currentIndex == widget.questions.length - 1
                          ? _showSubmitDialog
                          : _nextQuestion,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentIndex == widget.questions.length - 1
                                  ? 'Submit'
                                  : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _currentIndex == widget.questions.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Test?',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _timer?.cancel();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
