import 'package:flutter/material.dart';
import '../data/scraper_service.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class LiveScraperScreen extends StatefulWidget {
  const LiveScraperScreen({super.key});

  @override
  State<LiveScraperScreen> createState() => _LiveScraperScreenState();
}

class _LiveScraperScreenState extends State<LiveScraperScreen> {
  final TextEditingController _customIdController = TextEditingController(text: "1");
  bool _isLoading = false;
  String _loadingMessage = "";
  List<Question> _scrapedQuestions = [];
  String _selectedTopicTitle = "भौतिक विशेषताएं";

  // Pre-configured high-yield topics matching RajasthanGyan topic IDs
  final List<Map<String, dynamic>> _predefinedTopics = [
    {"id": 1, "title": "भौतिक विशेषताएं (Physical Features)"},
    {"id": 2, "title": "राजस्थान के जिले व संभाग (Districts & Divisions)"},
    {"id": 23, "title": "राजस्थान की जलवायु (Climate of Rajasthan)"},
    {"id": 24, "title": "राजस्थान का भौतिक स्वरूप (Physical Structure)"},
    {"id": 26, "title": "राजस्थान में त्यौहार (Festivals)"},
    {"id": 27, "title": "राजस्थान के मेले (Fairs of Rajasthan)"},
    {"id": 28, "title": "रीति-रिवाज एवं प्रथाएं (Customs & Traditions)"},
    {"id": 29, "title": "राजस्थान में स्थापत्य कला (Architecture)"},
    {"id": 30, "title": "लोक देवता व देवियाँ (Local Deities)"},
    {"id": 32, "title": "राजस्थान की नदियां (Rivers of Rajasthan)"},
    {"id": 33, "title": "राजस्थान की जनजातियां (Tribes of Rajasthan)"},
    {"id": 129, "title": "राजस्थान की प्राचीन सभ्यताएँ (Ancient Civilizations)"},
    {"id": 130, "title": "1857 की क्रांति (1857 Revolution)"},
    {"id": 148, "title": "राजस्थान का एकीकरण (Integration of Rajasthan)"},
    {"id": 149, "title": "हस्तकला / हस्तशिल्प (Handicrafts)"},
  ];

  int _selectedTopicId = 1;

  Future<void> _startScraping(int topicId, String topicTitle) async {
    setState(() {
      _isLoading = true;
      _scrapedQuestions = [];
      _loadingMessage = "Connecting to RajasthanGyan...";
      _selectedTopicTitle = topicTitle;
    });

    // Step 2: Fetch and Parse HTML
    setState(() {
      _loadingMessage = "Fetching HTML & extracting questions...";
    });
    
    final questions = await ScraperService.fetchLiveGkQuestions(topicId);

    setState(() {
      _isLoading = false;
      _scrapedQuestions = questions;
    });

    if (questions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to extract questions. Please check the Topic ID or your connection.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _launchScrapedQuiz() {
    if (_scrapedQuestions.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          categoryName: "Scraped: $_selectedTopicTitle",
          questions: _scrapedQuestions,
          timeInMinutes: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Live MCQ Scraper & Test'),
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
              // Header Card
              Container(
                width: double.infinity,
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Website MCQ Extractor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Directly extract live GK questions from RajasthanGyan and practice them instantly as a mock test!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Configuration Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Select pre-configured topic:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedTopicId,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                          items: _predefinedTopics.map((topic) {
                            return DropdownMenuItem<int>(
                              value: topic['id'],
                              child: Text(
                                topic['title'],
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTopicId = val;
                                _customIdController.text = val.toString();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Or enter custom Topic ID:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customIdController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 1, 23, 129',
                              fillColor: AppTheme.background,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  final id = int.tryParse(_customIdController.text) ?? 1;
                                  // Look up title if custom ID matches a predefined topic
                                  final match = _predefinedTopics.firstWhere(
                                    (t) => t['id'] == id,
                                    orElse: () => {"id": id, "title": "Custom Topic #$id"},
                                  );
                                  _startScraping(id, match['title']);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Extract data', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Loading or Results Section
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_scrapedQuestions.isNotEmpty) ...[
                // Start Quiz CTA Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.offline_pin_rounded, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Successfully Extracted ${_scrapedQuestions.length} Questions!',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _launchScrapedQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.play_circle_filled_rounded, size: 20),
                        label: const Text(
                          'START MOCK TEST NOW',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Scraped Data Preview Header
                const Text(
                  'Extracted Questions Preview:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Scraped Questions List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _scrapedQuestions.length,
                  itemBuilder: (context, index) {
                    final q = _scrapedQuestions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}: ${q.question}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(q.options.length, (optIdx) {
                            final isCorrect = optIdx == q.correctIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCorrect ? const Color(0xFF10B981).withValues(alpha: 0.08) : AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCorrect ? const Color(0xFF10B981).withValues(alpha: 0.3) : AppTheme.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                    size: 14,
                                    color: isCorrect ? const Color(0xFF10B981) : AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      q.options[optIdx],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                        color: isCorrect ? const Color(0xFF065F46) : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (q.explanation != null) ...[
                            const SizedBox(height: 10),
                            const Divider(color: AppTheme.border, height: 1),
                            const SizedBox(height: 10),
                            Text(
                              'Explanation: ${q.explanation}',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.blueGrey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
