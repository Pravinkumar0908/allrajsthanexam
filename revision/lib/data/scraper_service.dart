import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ScraperService {
  // Free CORS proxy for web target to avoid browser CORS policy blocking the request
  static const String _corsProxy = "https://corsproxy.io/?";

  static Future<List<Question>> fetchLiveGkQuestions(int topicId) async {
    final String targetUrl = "https://www.rajasthangyan.com/question?tid=$topicId&start=0&sort=n";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint("Failed to fetch questions. Status code: ${response.statusCode}");
        return [];
      }

      // Convert body bytes to UTF-8 to correctly decode Hindi characters
      final htmlContent = utf8.decode(response.bodyBytes);
      return parseRajasthanGyanHtml(htmlContent, topicId.toString());
    } catch (e) {
      debugPrint("Error fetching live GK questions: $e");
      return [];
    }
  }

  static List<Question> parseRajasthanGyanHtml(String htmlContent, String topicId) {
    List<Question> questions = [];

    // Split HTML content by the question block identifier
    List<String> blocks = htmlContent.split('class="question-container"');
    if (blocks.length <= 1) {
      debugPrint("No question blocks found in scraped HTML.");
      return questions;
    }

    for (int i = 1; i < blocks.length; i++) {
      String block = blocks[i];

      // Isolate this specific question block up to the closing dl/div tag
      int dlEnd = block.indexOf('</dl>');
      if (dlEnd != -1) {
        block = block.substring(0, dlEnd);
      }

      // 1. Extract Question Text & Exam Tag
      String qText = "";
      String? examTag;
      int dtStart = block.indexOf('<dt>');
      int dtEnd = block.indexOf('</dt>');
      if (dtStart != -1 && dtEnd != -1) {
        String dtContent = block.substring(dtStart + 4, dtEnd);

        // Extract exam info span if present
        int spanStart = dtContent.indexOf('<span');
        if (spanStart != -1) {
          int spanEnd = dtContent.indexOf('</span>', spanStart);
          if (spanEnd != -1) {
            String spanContent = dtContent.substring(spanStart, spanEnd + 7);
            String rawTag = spanContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();
            rawTag = rawTag.replaceAll(RegExp(r'^[\[\(\s]*(Exam\s*:\s*)?|[\]\)\s]*$'), '').trim();
            if (rawTag.isNotEmpty) {
              examTag = rawTag;
            }
          }
          dtContent = dtContent.substring(0, spanStart);
        }

        // Clean HTML tags and excessive spacing
        qText = dtContent
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        // Clean prefix like "प्रश्न 1 ", "प्रश्न 2 ", etc.
        qText = qText.replaceAll(RegExp(r'^प्रश्न\s*\d+\s*'), '');
      }

      // 2. Extract Options
      List<String> options = [];
      int ulStart = block.indexOf('<ul>');
      int ulEnd = block.indexOf('</ul>');
      if (ulStart != -1 && ulEnd != -1) {
        String ulContent = block.substring(ulStart + 4, ulEnd);
        List<String> items = ulContent.split('<li>');
        for (var item in items) {
          int liEnd = item.indexOf('</li>');
          if (liEnd != -1) {
            String optText = item.substring(0, liEnd)
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

            // Strip prefix like (अ), (ब), (स), (द), or A, B, C, D
            optText = optText.replaceAll(RegExp(r'^\([अबसदबअसदABCDA-D]\)\s*'), '').trim();
            // Also clean custom brackets if present
            optText = optText.replaceAll(RegExp(r'^[अबसद]\s+'), '').trim();

            if (optText.isNotEmpty) {
              options.add(optText);
            }
          }
        }
      }

      // 3. Extract Answer & Explanation
      String correctAnswer = "";
      String explanation = "";
      int contentStart = block.indexOf('class="rg-c-content"');
      if (contentStart != -1) {
        int divTextStart = block.indexOf('>', contentStart);
        int divTextEnd = block.indexOf('</div>', contentStart);
        if (divTextStart != -1 && divTextEnd != -1) {
          String contentText = block.substring(divTextStart + 1, divTextEnd);

          // Find correct answer line
          int ansStart = contentText.indexOf('उत्तर :');
          if (ansStart == -1) ansStart = contentText.indexOf('उत्तर:');

          int expStart = contentText.indexOf('व्याख्या :');
          if (expStart == -1) expStart = contentText.indexOf('व्याख्या:');

          if (ansStart != -1) {
            int endOfAns = (expStart != -1 && expStart > ansStart) ? expStart : contentText.length;
            String ansText = contentText.substring(ansStart, endOfAns)
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .trim();
            correctAnswer = ansText.replaceAll(RegExp(r'^उत्तर\s*:\s*'), '').trim();
          }

          if (expStart != -1) {
            String expText = contentText.substring(expStart)
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .trim();
            explanation = expText.replaceAll(RegExp(r'^व्याख्या\s*:\s*'), '').trim();
          }
        }
      }

      // 4. Calculate correct option index
      int correctIndex = 0;
      if (options.isNotEmpty && correctAnswer.isNotEmpty) {
        correctIndex = options.indexWhere((opt) => opt.toLowerCase().trim() == correctAnswer.toLowerCase().trim());
        if (correctIndex == -1) {
          correctIndex = options.indexWhere((opt) => opt.toLowerCase().contains(correctAnswer.toLowerCase()));
        }
        if (correctIndex == -1) {
          correctIndex = options.indexWhere((opt) => correctAnswer.toLowerCase().contains(opt.toLowerCase()));
        }
        if (correctIndex == -1) {
          correctIndex = 0; // Default fallback
        }
      }

      // If we extracted a valid question, add it
      if (qText.isNotEmpty && options.isNotEmpty) {
        questions.add(Question(
          id: "scraped_${topicId}_$i",
          question: qText,
          options: options,
          correctIndex: correctIndex,
          explanation: explanation.isNotEmpty ? explanation : null,
          examTag: examTag,
        ));
      }
    }

    return questions;
  }

  // ── Fetch GK Tricks ──
  static Future<List<Map<String, String>>> fetchLiveTricks() async {
    const String targetUrl = "https://www.rajasthangyan.com/tricks";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(Uri.parse(requestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final html = utf8.decode(response.bodyBytes);
      List<Map<String, String>> tricks = [];

      // Look for trick links: href="trick?tid=X
      final regExp = RegExp(r'href="trick\?tid=(\d+)[^"]*">.*?rg_tricks_link[^>]*>(.*?)</span>', dotAll: true);
      final matches = regExp.allMatches(html);

      for (var m in matches) {
        final id = m.group(1) ?? "";
        final title = m.group(2)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? "";
        if (id.isNotEmpty && title.isNotEmpty) {
          tricks.add({'id': id, 'title': title});
        }
      }
      return tricks;
    } catch (e) {
      debugPrint("Error fetching tricks: $e");
      return [];
    }
  }

  // ── Fetch Trick Detail ──
  static Future<String> fetchTrickDetail(String tid) async {
    final String targetUrl = "https://www.rajasthangyan.com/trick?tid=$tid";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(Uri.parse(requestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return "Failed to fetch trick detail.";

      final html = utf8.decode(response.bodyBytes);
      
      // Parse main content block of the trick
      int contentStart = html.indexOf('class="maincontent"');
      if (contentStart == -1) contentStart = html.indexOf('class="container"');
      
      if (contentStart != -1) {
        String subHtml = html.substring(contentStart);
        int contentEnd = subHtml.indexOf('</div>');
        if (contentEnd != -1) {
          subHtml = subHtml.substring(0, contentEnd);
        }
        final cleaned = subHtml.replaceAll(RegExp(r'<[^>]*>'), '\n').replaceAll(RegExp(r'\n+'), '\n').trim();
        return cleaned.isNotEmpty ? cleaned : "No description found.";
      }
      return "Trick details not found on the page.";
    } catch (e) {
      debugPrint("Error fetching trick detail: $e");
      return "Error connecting to RajasthanGyan.";
    }
  }

  // ── Fetch GK Notes ──
  static Future<List<Map<String, String>>> fetchLiveNotes() async {
    const String targetUrl = "https://www.rajasthangyan.com/notes";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(Uri.parse(requestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final html = utf8.decode(response.bodyBytes);
      List<Map<String, String>> notes = [];

      // Split by rg_nts_contain
      final blocks = html.split('class="rg_nts_contain"');
      for (int i = 1; i < blocks.length; i++) {
        String block = blocks[i];
        int endIdx = block.indexOf('</div>');
        if (endIdx != -1) block = block.substring(0, endIdx);

        // Subject
        String subject = "";
        int h1Start = block.indexOf('<h1>');
        int h1End = block.indexOf('</h1>');
        if (h1Start != -1 && h1End != -1) {
          subject = block.substring(h1Start + 4, h1End).replaceAll(RegExp(r'<[^>]*>'), '').trim();
        }

        // Title
        String title = "";
        int h3Start = block.indexOf('<h3>');
        int h3End = block.indexOf('</h3>');
        if (h3Start != -1 && h3End != -1) {
          title = block.substring(h3Start + 4, h3End).replaceAll(RegExp(r'<[^>]*>'), '').trim();
        } else {
          // Fallback to secondary h1 if present
          int h1SecStart = block.indexOf('<h1>', h1End + 5);
          int h1SecEnd = block.indexOf('</h1>', h1End + 5);
          if (h1SecStart != -1 && h1SecEnd != -1) {
            title = block.substring(h1SecStart + 4, h1SecEnd).replaceAll(RegExp(r'<[^>]*>'), '').trim();
          }
        }

        // Snippet
        String description = "";
        int pStart = block.indexOf('<p>');
        int pEnd = block.indexOf('</p>');
        if (pStart != -1 && pEnd != -1) {
          description = block.substring(pStart + 3, pEnd).replaceAll(RegExp(r'<[^>]*>'), '').trim();
        }

        // Link
        String link = "";
        int hrefStart = block.indexOf('href="');
        if (hrefStart != -1) {
          int hrefEnd = block.indexOf('"', hrefStart + 6);
          if (hrefEnd != -1) {
            link = block.substring(hrefStart + 6, hrefEnd).trim();
          }
        }

        if (subject.isNotEmpty) {
          notes.add({
            'subject': subject,
            'title': title.isNotEmpty ? title : subject,
            'description': description,
            'link': link.isNotEmpty ? "https://www.rajasthangyan.com/$link" : "",
          });
        }
      }
      return notes;
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      return [];
    }
  }

  // ── Fetch Important Days Calendar ──
  static Future<List<Map<String, String>>> fetchLiveDays() async {
    const String targetUrl = "https://www.rajasthangyan.com/imp_day_calender";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(Uri.parse(requestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final html = utf8.decode(response.bodyBytes);
      List<Map<String, String>> daysList = [];

      // Parse days list
      final regExp = RegExp(r'<div class="index_topic">.*?href="([^"]+)".*?><span>(.*?)</span>', dotAll: true);
      final matches = regExp.allMatches(html);

      for (var m in matches) {
        final link = m.group(1)?.trim() ?? "";
        final title = m.group(2)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? "";
        if (title.isNotEmpty) {
          daysList.add({
            'title': title,
            'link': link.startsWith('http') ? link : "https://www.rajasthangyan.com/$link",
          });
        }
      }
      return daysList;
    } catch (e) {
      debugPrint("Error fetching calendar days: $e");
      return [];
    }
  }

  // ── Fetch General Questions Feed ──
  static Future<List<Question>> fetchQuestionsFeed(String relation) async {
    final String targetUrl = "https://www.rajasthangyan.com/questions?rel=$relation";
    final String requestUrl = kIsWeb ? "$_corsProxy${Uri.encodeComponent(targetUrl)}" : targetUrl;

    try {
      final response = await http.get(Uri.parse(requestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final html = utf8.decode(response.bodyBytes);
      return parseRajasthanGyanHtml(html, relation);
    } catch (e) {
      debugPrint("Error fetching questions feed: $e");
      return [];
    }
  }
}
