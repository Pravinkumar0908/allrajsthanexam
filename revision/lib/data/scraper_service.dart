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

      // 1. Extract Question Text
      String qText = "";
      int dtStart = block.indexOf('<dt>');
      int dtEnd = block.indexOf('</dt>');
      if (dtStart != -1 && dtEnd != -1) {
        String dtContent = block.substring(dtStart + 4, dtEnd);

        // Remove span tags containing exam info
        int spanStart = dtContent.indexOf('<span');
        if (spanStart != -1) {
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
        ));
      }
    }

    return questions;
  }
}
