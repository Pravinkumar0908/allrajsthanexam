import 'package:flutter/material.dart';
import '../data/scraper_service.dart';
import '../data/question_bank.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class RajasthanGkTopicsScreen extends StatefulWidget {
  const RajasthanGkTopicsScreen({super.key});

  @override
  State<RajasthanGkTopicsScreen> createState() => _RajasthanGkTopicsScreenState();
}

class _RajasthanGkTopicsScreenState extends State<RajasthanGkTopicsScreen> {
  final List<Map<String, dynamic>> _topics = [
    {
      "id": 1,
      "title": "भौतिक विशेषताएं",
      "subtitle": "Physical Features",
      "icon": Icons.terrain_rounded,
      "color": const Color(0xFF3B82F6),
    },
    {
      "id": 2,
      "title": "राजस्थान के जिले व संभाग",
      "subtitle": "Districts & Divisions",
      "icon": Icons.map_rounded,
      "color": const Color(0xFF10B981),
    },
    {
      "id": 23,
      "title": "राजस्थान की जलवायु",
      "subtitle": "Climate of Rajasthan",
      "icon": Icons.wb_sunny_rounded,
      "color": const Color(0xFFF59E0B),
    },
    {
      "id": 24,
      "title": "राजस्थान का भौतिक स्वरूप",
      "subtitle": "Physical Structure",
      "icon": Icons.landscape_rounded,
      "color": const Color(0xFF8B5CF6),
    },
    {
      "id": 26,
      "title": "राजस्थान में त्यौहार",
      "subtitle": "Festivals of Rajasthan",
      "icon": Icons.celebration_rounded,
      "color": const Color(0xFFEC4899),
    },
    {
      "id": 27,
      "title": "राजस्थान के मेले",
      "subtitle": "Fairs of Rajasthan",
      "icon": Icons.storefront_rounded,
      "color": const Color(0xFFEF4444),
    },
    {
      "id": 28,
      "title": "रीति-रिवाज एवं प्रथाएं",
      "subtitle": "Customs & Traditions",
      "icon": Icons.people_rounded,
      "color": const Color(0xFF06B6D4),
    },
    {
      "id": 29,
      "title": "राजस्थान में स्थापत्य कला",
      "subtitle": "Architecture of Rajasthan",
      "icon": Icons.account_balance_rounded,
      "color": const Color(0xFFF97316),
    },
    {
      "id": 30,
      "title": "लोक देवता व देवियाँ",
      "subtitle": "Local Deities & Gods",
      "icon": Icons.church_rounded,
      "color": const Color(0xFF14B8A6),
    },
    {
      "id": 32,
      "title": "राजस्थान की नदियां",
      "subtitle": "Rivers & Lakes",
      "icon": Icons.water_rounded,
      "color": const Color(0xFF3B82F6),
    },
    {
      "id": 33,
      "title": "राजस्थान की जनजातियां",
      "subtitle": "Tribes of Rajasthan",
      "icon": Icons.groups_rounded,
      "color": const Color(0xFF6366F1),
    },
    {
      "id": 129,
      "title": "राजस्थान की प्राचीन सभ्यताएँ",
      "subtitle": "Ancient Civilizations",
      "icon": Icons.history_edu_rounded,
      "color": const Color(0xFF8B5CF6),
    },
    {
      "id": 130,
      "title": "1857 की क्रांति",
      "subtitle": "1857 Revolution",
      "icon": Icons.gavel_rounded,
      "color": const Color(0xFFEF4444),
    },
    {
      "id": 148,
      "title": "राजस्थान का एकीकरण",
      "subtitle": "Integration of Rajasthan",
      "icon": Icons.link_rounded,
      "color": const Color(0xFF10B981),
    },
    {
      "id": 149,
      "title": "हस्तकला / हस्तशिल्प",
      "subtitle": "Handicrafts & Artistry",
      "icon": Icons.brush_rounded,
      "color": const Color(0xFFEC4899),
    },
  ];

  Future<void> _fetchAndStartQuiz(int topicId, String topicTitle) async {
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
                  'Fetching live questions...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final questions = await ScraperService.fetchLiveGkQuestions(topicId);

    if (mounted) Navigator.pop(context); // Dismiss loading dialog

    if (questions.isNotEmpty) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            categoryName: topicTitle,
            questions: questions,
            timeInMinutes: 10,
          ),
        ),
      );
    } else {
      // Fallback to local questions
      final localQs = QuestionBank.getQuestions('rajasthan_history');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load live questions. Starting offline practice mode!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            categoryName: "$topicTitle (Offline)",
            questions: localQs,
            timeInMinutes: 10,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('राजस्थान GK टॉपिक्स'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              const Text(
                'सारे सब-टॉपिक्स (Sub Topics):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Grid view of subtopics
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  return _TopicCard(
                    title: topic['title'],
                    subtitle: topic['subtitle'],
                    icon: topic['icon'],
                    color: topic['color'],
                    onTap: () => _fetchAndStartQuiz(topic['id'], topic['title']),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed ? widget.color.withValues(alpha: 0.3) : AppTheme.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
