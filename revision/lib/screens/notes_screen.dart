import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/firestore_service.dart';
import '../theme/app_theme.dart';
import 'pdf_viewer_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;
  String _activeTab = 'all'; // 'all', 'free', 'premium'
  String _activeSubject = 'All'; // Subject filtering
  final TextEditingController _searchController = TextEditingController();

  final List<String> _subjects = [
    'All',
    'Rajasthan GK',
    'Polity',
    'History',
    'Geography',
    'Economy',
    'Science',
    'Hindi'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final list = await FirestoreService.fetchNotes();
    if (mounted) {
      setState(() {
        _allNotes = list;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> results = List.from(_allNotes);

    // Type Tab Filter
    if (_activeTab == 'free') {
      results = results.where((n) => n['type'] == 'free').toList();
    } else if (_activeTab == 'premium') {
      results = results.where((n) => n['type'] == 'premium').toList();
    }

    // Subject Filter
    if (_activeSubject != 'All') {
      results = results.where((n) {
        final subject = (n['subject'] ?? '').toString().toLowerCase();
        final cat = (n['category'] ?? '').toString().toLowerCase();
        final matchSubject = _activeSubject.toLowerCase();
        return subject.contains(matchSubject) || cat.contains(matchSubject) ||
            (matchSubject == 'rajasthan gk' && cat == 'rajasthan-gk');
      }).toList();
    }

    // Search Filter
    if (query.isNotEmpty) {
      results = results.where((n) {
        final title = (n['title'] ?? '').toString().toLowerCase();
        final desc = (n['description'] ?? '').toString().toLowerCase();
        final subject = (n['subject'] ?? '').toString().toLowerCase();
        return title.contains(query) || desc.contains(query) || subject.contains(query);
      }).toList();
    }

    setState(() {
      _filteredNotes = results;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Notes Library',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Search study notes, topics...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                // Horizontal Subjects List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _subjects.map((sub) {
                      final bool isSelected = _activeSubject == sub;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(sub),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _activeSubject = sub);
                              _applyFilters();
                            }
                          },
                          selectedColor: AppTheme.primary,
                          backgroundColor: Colors.transparent,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.border,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotes,
        color: AppTheme.primary,
        child: Column(
          children: [
            // Tabs Bar: All, Free, Premium
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  _buildTab('all', 'All PDF Notes (${_allNotes.length})'),
                  const SizedBox(width: 8),
                  _buildTab('free', 'Free (${_allNotes.where((n) => n['type'] == 'free').length})'),
                  const SizedBox(width: 8),
                  _buildTab('premium', 'Premium (${_allNotes.where((n) => n['type'] == 'premium').length})'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];
                            return _buildNoteCard(note);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String tabKey, String label) {
    final bool isSelected = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTab = tabKey);
          _applyFilters();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> n) {
    final title = n['title'] as String? ?? 'Study Guide';
    final desc = n['description'] as String? ?? '';
    final subject = n['subject'] as String? ?? '';
    final language = n['language'] as String? ?? 'Hindi';
    final pages = n['pages'] as int? ?? 0;
    final size = n['size'] as String? ?? 'N/A';
    final type = n['type'] as String? ?? 'free';
    final downloads = n['downloads'] as int? ?? 0;

    final isPremium = type == 'premium';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Icon Badge
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 24),
                  SizedBox(height: 2),
                  Text(
                    'PDF',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row: Title + Free/Premium Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPremium
                              ? AppTheme.primary.withValues(alpha: 0.10)
                              : Colors.green.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPremium ? 'Premium' : 'Free',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isPremium ? AppTheme.primary : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  if (desc.isNotEmpty) ...[
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Meta Row: Subject, Pages, Size, Language
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      _buildDotDivider(),
                      Text(
                        '$pages p.',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      _buildDotDivider(),
                      Text(
                        size,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      _buildDotDivider(),
                      Text(
                        language,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action row (Downloads count + View PDF button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$downloads views',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          final noteUrl = n['noteUrl'] ?? '';
                          if (noteUrl.isEmpty || noteUrl == '#') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Study guide link is not active yet.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerScreen(
                                title: title,
                                url: noteUrl,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.08),
                          foregroundColor: AppTheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new_rounded, size: 12),
                        label: const Text(
                          'View Notes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotDivider() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppTheme.border,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_rounded,
                color: AppTheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Study Notes Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t find any PDF study notes matching your active search, subjects, or filters. Swipe down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
