import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import '../data/firestore_service.dart';
import 'quiz_screen.dart';

class ChaptersScreen extends StatefulWidget {
  final QuizCategory category;
  final IconData icon;

  const ChaptersScreen({
    super.key,
    required this.category,
    required this.icon,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  List<Map<String, dynamic>> _displayChapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  bool _matchCategory(String testSubject, String testExam, String categoryId) {
    final sub = testSubject.toLowerCase();
    final ex = testExam.toLowerCase();
    final cat = categoryId.toLowerCase();

    // If it is a global mock test for all subjects/exams, show it under all categories
    if (sub.contains('all') || ex.contains('all') || sub.isEmpty || ex.isEmpty) {
      return true;
    }

    if (cat == 'rajasthan_gk') {
      return sub.contains('gk') || sub.contains('rajasthan') || ex.contains('rajasthan') || ex.contains('gk') || ex.contains('cet');
    }
    if (cat == 'indian_history') {
      return sub.contains('history') || sub.contains('इतिहास') || ex.contains('history');
    }
    if (cat == 'geography') {
      return sub.contains('geography') || sub.contains('भूगोल') || ex.contains('geography');
    }
    if (cat == 'polity') {
      return sub.contains('polity') || sub.contains('संविधान') || sub.contains('राजव्यवस्था') || ex.contains('polity');
    }
    if (cat == 'science') {
      return sub.contains('science') || sub.contains('विज्ञान') || ex.contains('science');
    }
    if (cat == 'economy') {
      return sub.contains('economy') || sub.contains('अर्थशास्त्र') || sub.contains('अर्थव्यवस्था') || ex.contains('economy');
    }
    if (cat == 'hindi') {
      return sub.contains('hindi') || sub.contains('हिंदी') || ex.contains('hindi');
    }
    if (cat == 'current_affairs') {
      return sub.contains('current') || sub.contains('affairs') || sub.contains('समसामयिकी') || ex.contains('current');
    }
    return false;
  }

  void _loadChapters() async {
    setState(() => _isLoading = true);

    final String catId = widget.category.id;
    final List<Map<String, dynamic>> matchingTests = [];

    if (catId == 'rajasthan_gk') {
      debugPrint("Fetching all GK chapters for Rajasthan GK category");
      final gkChapters = await FirestoreService.fetchGkChapters(null);
      matchingTests.addAll(gkChapters);
    } else if (catId == 'indian_history') {
      debugPrint("Fetching History chapters for Indian History category");
      final gkChapters = await FirestoreService.fetchGkChapters('itihas');
      matchingTests.addAll(gkChapters);
    } else if (catId == 'geography') {
      debugPrint("Fetching Geography chapters for Geography category");
      final gkChapters = await FirestoreService.fetchGkChapters('bhugol');
      matchingTests.addAll(gkChapters);
    } else if (catId == 'art_culture') {
      debugPrint("Fetching Art & Culture chapters for Art & Culture category");
      final gkChapters = await FirestoreService.fetchGkChapters('rajasthan_kala_sanskriti');
      matchingTests.addAll(gkChapters);
    } else if (catId == 'current_affairs') {
      debugPrint("Fetching Current Affairs months");
      final caMonths = await FirestoreService.fetchCurrentAffairsMonths();
      for (var m in caMonths) {
        matchingTests.add({
          'isCurrentAffairs': true,
          'isFirestore': false,
          'isGkCollection': false,
          'id': m['slug'],
          'title': m['title'],
          'subtitle': m['subtitle'],
          'questionsCount': 10,
          'time': 15,
        });
      }
    } else {
      debugPrint("Fetching general tests from collection 'tests' for category: $catId");
      final firestoreTests = await FirestoreService.fetchTests();
      for (var t in firestoreTests) {
        debugPrint("Checking test: title=${t['title']}, exam=${t['exam']}, subject=${t['subject']}");
        if (_matchCategory(t['subject'] ?? '', t['exam'] ?? '', catId)) {
          debugPrint("Match found for category $catId!");
          matchingTests.add({
            'isFirestore': true,
            'isGkCollection': false,
            'id': t['id'],
            'title': t['title'],
            'subtitle': '${t['exam']} • ${t['subject']}',
            'questionsCount': t['totalQuestions'],
            'time': t['duration'],
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _displayChapters = matchingTests;
        _isLoading = false;
      });
    }
  }

  void _startQuiz(Map<String, dynamic> chapter) async {
    if (chapter['isCurrentAffairs'] == true) {
      // Show full-screen loading dialog while fetching questions from Firestore current_affairs collection
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(
                    'Fetching current affairs...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final questions = await FirestoreService.fetchCurrentAffairsQuestions(chapter['id']);
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Current Affairs questions available for this month.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          _slideRoute(QuizScreen(
            categoryName: chapter['title'],
            questions: questions,
            timeInMinutes: chapter['time'] ?? 15,
          )),
        );
      }
    } else if (chapter['isGkCollection'] == true) {
      // Questions are already parsed and stored in the map!
      final List<Question> questions = List<Question>.from(chapter['questions']);
      
      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No questions available in this chapter yet.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        _slideRoute(QuizScreen(
          categoryName: chapter['title'],
          questions: questions,
          timeInMinutes: chapter['time'],
        )),
      );
    } else if (chapter['isFirestore'] == true) {
      // Show full-screen loading dialog while fetching questions from Firestore tests collection
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text(
                    'Fetching questions...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final questions = await FirestoreService.fetchTestQuestions(chapter['id']);
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load questions. Please check your internet connection.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          _slideRoute(QuizScreen(
            categoryName: chapter['title'],
            questions: questions,
            timeInMinutes: chapter['time'],
          )),
        );
      }
    }
  }

  PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      appBar: AppBar(
        title: Text(widget.category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadChapters,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading tests from Firestore...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Category Info Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(widget.icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.category.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.category.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Select Chapter Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(
                        'Select Mock Test',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  if (_displayChapters.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppTheme.border, width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.assignment_late_outlined,
                                  color: AppTheme.primary,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'No Mock Tests Found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'There are no active tests matching this category on the website yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadChapters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Refresh / Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Chapters List
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          _displayChapters.map((chapter) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => _startQuiz(chapter),
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppTheme.border, width: 1.0),
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chapter['title'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              chapter['subtitle'],
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.assignment_outlined, size: 14, color: AppTheme.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${chapter['questionsCount']} Questions',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                const Icon(Icons.timer_outlined, size: 14, color: AppTheme.primary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${chapter['time']} Min',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: AppTheme.primary,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
