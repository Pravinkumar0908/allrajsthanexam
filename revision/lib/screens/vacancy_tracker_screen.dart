import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/firestore_service.dart';
import '../theme/app_theme.dart';

class VacancyTrackerScreen extends StatefulWidget {
  const VacancyTrackerScreen({super.key});

  @override
  State<VacancyTrackerScreen> createState() => _VacancyTrackerScreenState();
}

class _VacancyTrackerScreenState extends State<VacancyTrackerScreen> {
  List<Map<String, dynamic>> _allVacancies = [];
  List<Map<String, dynamic>> _filteredVacancies = [];
  bool _isLoading = true;
  String _activeTab = 'all'; // 'all', 'open', 'upcoming'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVacancies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVacancies() async {
    setState(() => _isLoading = true);
    final list = await FirestoreService.fetchVacancies();
    if (mounted) {
      setState(() {
        _allVacancies = list;
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> results = List.from(_allVacancies);

    // Tab Filter
    if (_activeTab == 'open') {
      results = results.where((v) => v['status'] == 'open' || v['status'] == 'new').toList();
    } else if (_activeTab == 'upcoming') {
      results = results.where((v) => v['status'] == 'upcoming').toList();
    }

    // Search Filter
    if (query.isNotEmpty) {
      results = results.where((v) {
        final title = (v['title'] ?? '').toString().toLowerCase();
        final org = (v['org'] ?? '').toString().toLowerCase();
        return title.contains(query) || org.contains(query);
      }).toList();
    }

    setState(() {
      _filteredVacancies = results;
    });
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty || urlString == '#') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link is not active yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } catch (e) {
      debugPrint("Could not launch URL: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open link: $urlString'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Vacancy Tracker',
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
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
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
                        hintText: 'Search jobs, departments...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.normal),
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVacancies,
        color: AppTheme.primary,
        child: Column(
          children: [
            // Tabs Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  _buildTab('all', 'All (${_allVacancies.length})'),
                  const SizedBox(width: 8),
                  _buildTab('open', 'Ongoing (${_allVacancies.where((v) => v['status'] == 'open' || v['status'] == 'new').length})'),
                  const SizedBox(width: 8),
                  _buildTab('upcoming', 'Upcoming (${_allVacancies.where((v) => v['status'] == 'upcoming').length})'),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _filteredVacancies.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredVacancies.length,
                          itemBuilder: (context, index) {
                            final vacancy = _filteredVacancies[index];
                            return _buildVacancyCard(vacancy);
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

  Widget _buildVacancyCard(Map<String, dynamic> v) {
    final title = v['title'] as String? ?? '';
    final org = v['org'] as String? ?? '';
    final lastDateStr = v['lastDate'] as String? ?? 'TBD';
    final posts = v['posts'] as int? ?? 0;
    final status = v['status'] as String? ?? '';

    // Calculate dynamic deadline badge
    String deadlineText = 'Closed';
    Color deadlineColor = AppTheme.error;
    if (status == 'open' || status == 'new') {
      if (lastDateStr != 'TBD') {
        final lastDate = DateTime.tryParse(lastDateStr);
        if (lastDate != null) {
          final diffDays = lastDate.difference(DateTime.now()).inDays + 1;
          if (diffDays > 0) {
            deadlineText = '$diffDays Days Left';
            deadlineColor = diffDays <= 3 ? AppTheme.error : Colors.green;
          } else {
            deadlineText = 'Closing Today';
            deadlineColor = AppTheme.error;
          }
        }
      } else {
        deadlineText = 'Apply Online';
        deadlineColor = Colors.green;
      }
    } else if (status == 'upcoming') {
      deadlineText = 'Coming Soon';
      deadlineColor = Colors.orange;
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Org, Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        org,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: deadlineColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deadlineText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: deadlineColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Metadata Grid: Posts, Qualification, Age, Salary
            Row(
              children: [
                _buildMetaItem(Icons.group_rounded, 'Posts', posts > 0 ? posts.toString() : 'TBD'),
                _buildMetaItem(Icons.school_rounded, 'Req.', v['qualification'] ?? 'Graduation'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMetaItem(Icons.hourglass_empty_rounded, 'Age Limit', v['ageLimit'] ?? '18-40 Years'),
                _buildMetaItem(Icons.currency_rupee_rounded, 'Salary', v['salary'] ?? 'Scale Paid'),
              ],
            ),
            const SizedBox(height: 16),

            // Action row
            Row(
              children: [
                // Apply button
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () => _launchURL(v['applyLink'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Apply Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
                // Syllabus PDF
                if (v['syllabusLink'] != null && v['syllabusLink'].toString().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchURL(v['syllabusLink']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 14),
                      label: const Text('Syllabus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
                // Notification PDF
                if (v['notificationLink'] != null && v['notificationLink'].toString().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchURL(v['notificationLink']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
                      label: const Text('PDF Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
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
                Icons.work_off_rounded,
                color: AppTheme.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Vacancies Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t find any jobs matching your active search or filters. Swipe down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
