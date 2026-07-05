import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/platform_view_helper.dart';
import '../theme/app_theme.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  // Helper to format Google Drive links for embedding cleanly
  String _getEmbedUrl(String originalUrl) {
    if (originalUrl.contains('drive.google.com')) {
      // Convert /view to /preview for direct embedded view
      var embed = originalUrl;
      if (embed.contains('/view')) {
        embed = embed.replaceAll('/view', '/preview');
      }
      return embed;
    }
    return originalUrl;
  }

  Future<void> _launchExternal() async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch external URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _getEmbedUrl(url);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: AppTheme.primary),
            tooltip: 'Open in Browser',
            onPressed: _launchExternal,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF3F4F6),
        child: createWebIframe(embedUrl),
      ),
    );
  }
}
