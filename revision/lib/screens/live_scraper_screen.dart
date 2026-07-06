import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/scraper_service.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class LiveScraperScreen extends StatefulWidget {
  const LiveScraperScreen({super.key});

  @override
  State<LiveScraperScreen> createState() => _LiveScraperScreenState();
}

class _LiveScraperScreenState extends State<LiveScraperScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Live MCQs States
  final TextEditingController _customIdController = TextEditingController(text: "1");
  bool _isLoadingMcq = false;
  String _loadingMcqMessage = "";
  List<Question> _scrapedQuestions = [];
  String _selectedTopicTitle = "भौतिक विशेषताएं";
  int _selectedTopicId = 1;

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

  // Tab 2: GK Tricks States
  bool _isLoadingTricks = false;
  List<Map<String, String>> _tricksList = [];

  // Tab 3: Study Notes States
  bool _isLoadingNotes = false;
  List<Map<String, String>> _notesList = [];

  // Tab 4: Important Days States
  bool _isLoadingDays = false;
  List<Map<String, String>> _daysList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _loadTabContent(_tabController.index);
    });

    // Load first tab data or prefetch
    _loadTabContent(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customIdController.dispose();
    super.dispose();
  }

  void _loadTabContent(int index) {
    if (index == 1 && _tricksList.isEmpty) {
      _fetchTricks();
    } else if (index == 2 && _notesList.isEmpty) {
      _fetchNotes();
    } else if (index == 3 && _daysList.isEmpty) {
      _fetchDays();
    }
  }

  // ── Scraper API Calls ──

  Future<void> _startScraping(int topicId, String topicTitle) async {
    setState(() {
      _isLoadingMcq = true;
      _scrapedQuestions = [];
      _loadingMcqMessage = "Connecting to RajasthanGyan...";
      _selectedTopicTitle = topicTitle;
    });

    setState(() {
      _loadingMcqMessage = "Extracting live questions & exam badges...";
    });

    final questions = await ScraperService.fetchLiveGkQuestions(topicId);

    setState(() {
      _isLoadingMcq = false;
      _scrapedQuestions = questions;
    });

    if (questions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to extract questions. Please check the Topic ID or connection.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _fetchTricks() async {
    setState(() => _isLoadingTricks = true);
    final list = await ScraperService.fetchLiveTricks();
    setState(() {
      _tricksList = list;
      _isLoadingTricks = false;
    });
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoadingNotes = true);
    final list = await ScraperService.fetchLiveNotes();
    setState(() {
      _notesList = list;
      _isLoadingNotes = false;
    });
  }

  Future<void> _fetchDays() async {
    setState(() => _isLoadingDays = true);
    final list = await ScraperService.fetchLiveDays();
    setState(() {
      _daysList = list;
      _isLoadingDays = false;
    });
  }

  // Show detailed trick content dialog
  void _viewTrickDetail(String id, String title) async {
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
                Text('Fetching trick details...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final detail = await ScraperService.fetchTrickDetail(id);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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

  // ── UI Tab Builders ──

  Widget _buildMcqTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preconfigured Topics Selector
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
                  '1. Select GK subject to extract:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
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
                      onPressed: _isLoadingMcq
                          ? null
                          : () {
                              final id = int.tryParse(_customIdController.text) ?? 1;
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

          // Loading mcqs
          if (_isLoadingMcq)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMcqMessage,
                      style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else if (_scrapedQuestions.isNotEmpty) ...[
            // Launch Test Banner
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
                        'Extracted ${_scrapedQuestions.length} Questions!',
                        style: const TextStyle(color: Color(0xFF10B981), fontSize: 15, fontWeight: FontWeight.w800),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.play_circle_filled_rounded, size: 20),
                    label: const Text(
                      'START MOCK TEST NOW',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questions Preview Header
            const Text(
              'Questions Preview with Exam Badges:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),

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
                      if (q.examTag != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                q.examTag!,
                                style: const TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
    );
  }

  Widget _buildTricksTab() {
    if (_isLoadingTricks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tricksList.isEmpty) {
      return const Center(
        child: Text('No GK tricks extracted yet.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _tricksList.length,
      itemBuilder: (context, index) {
        final trick = _tricksList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tips_and_updates_rounded, color: Colors.amber),
            ),
            title: Text(
              trick['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.textPrimary),
            ),
            subtitle: const Text('Tap to view shortcut mnemonic', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
            onTap: () => _viewTrickDetail(trick['id'] ?? '', trick['title'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    if (_isLoadingNotes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notesList.isEmpty) {
      return const Center(
        child: Text('No Study Notes extracted yet.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _notesList.length,
      itemBuilder: (context, index) {
        final note = _notesList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  note['subject'] ?? '',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                note['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                note['description'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final link = note['link'] ?? '';
                  if (link.isNotEmpty) {
                    final uri = Uri.parse(link);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 16),
                label: const Text('Read Notes Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaysTab() {
    if (_isLoadingDays) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_daysList.isEmpty) {
      return const Center(
        child: Text('No Important Days data found.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _daysList.length,
      itemBuilder: (context, index) {
        final day = _daysList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.red),
            ),
            title: Text(
              day['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            trailing: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.textSecondary),
            onTap: () async {
              final link = day['link'] ?? '';
              if (link.isNotEmpty) {
                final uri = Uri.parse(link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('RajasthanGyan Portal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.flash_on_rounded, size: 20), text: 'MCQ Extractor'),
            Tab(icon: Icon(Icons.tips_and_updates_rounded, size: 20), text: 'GK Tricks'),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'Study Notes'),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 20), text: 'Imp Days'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMcqTab(),
          _buildTricksTab(),
          _buildNotesTab(),
          _buildDaysTab(),
        ],
      ),
    );
  }
}
