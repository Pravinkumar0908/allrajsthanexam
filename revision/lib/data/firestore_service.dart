import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';

class FirestoreService {
  // Helper to parse date values into DateTime robustly
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // Helper to parse month slug weight for chronological sorting
  static int _getMonthWeight(String slug) {
    final parts = slug.split('-');
    if (parts.length < 2) return 0;
    final monthName = parts.first.toLowerCase();
    final year = int.tryParse(parts[1]) ?? 2026;
    
    const months = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12
    };
    final monthIndex = months[monthName] ?? 1;
    return year * 12 + monthIndex;
  }

  // Fetch all active tests from Firestore using the official SDK
  static Future<List<Map<String, dynamic>>> fetchTests() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tests').get();
      final List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'active';
        if (status.toLowerCase() == 'active') {
          list.add({
            'id': doc.id,
            'title': data['title'] as String? ?? 'Mock Test',
            'exam': data['exam'] as String? ?? 'All Exams',
            'subject': data['subject'] as String? ?? 'All Subjects',
            'testType': data['testType'] as String? ?? 'Free',
            'createdAt': data['createdAt'],
            'totalQuestions': data['totalQuestions'] is int 
                ? data['totalQuestions'] 
                : int.tryParse(data['totalQuestions']?.toString() ?? '') ?? 10,
            'duration': data['duration'] is int 
                ? data['duration'] 
                : int.tryParse(data['duration']?.toString() ?? '') ?? 10,
          });
        }
      }
      
      // Sort in Ascending order (pehle added top pr - oldest first)
      list.sort((a, b) {
        final dateA = _parseDateTime(a['createdAt']);
        final dateB = _parseDateTime(b['createdAt']);
        if (dateA != null && dateB != null) {
          return dateA.compareTo(dateB);
        }
        if (dateA != null) return -1;
        if (dateB != null) return 1;
        return 0;
      });
      
      return list;
    } catch (e) {
      print('Error fetching tests from Firestore SDK: $e');
    }
    return [];
  }

  // Fetch questions for a specific test ID using the official SDK
  static Future<List<Question>> fetchTestQuestions(String testId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tests')
          .doc(testId)
          .collection('questions')
          .get();

      final List<Question> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final questionText = data['question'] as String? ?? '';
        final explanation = data['explanation'] as String?;
        final correctAnswer = data['correctAnswer'] as String? ?? 'A';

        List<String> parsedOptions = [];
        int correctIndex = 0;

        final optionsVal = data['options'] as List?;
        if (optionsVal != null) {
          final optList = optionsVal.map((v) {
            if (v is Map) {
              final key = v['key'] as String? ?? '';
              final text = v['text'] as String? ?? '';
              return {'key': key, 'text': text};
            }
            return {'key': '', 'text': v.toString()};
          }).toList();
          
          // Filter empty key/text
          optList.removeWhere((e) => e['key'] == '' && e['text'] == '');
          
          optList.sort((a, b) => a['key']!.compareTo(b['key']!));
          parsedOptions = optList.map((e) => e['text']!).toList();

          correctIndex = optList.indexWhere((e) => e['key'] == correctAnswer);
          if (correctIndex == -1) correctIndex = 0;
        }

        if (questionText.isNotEmpty && parsedOptions.isNotEmpty) {
          list.add(Question(
            id: doc.id,
            question: questionText,
            options: parsedOptions,
            correctIndex: correctIndex,
            explanation: explanation,
          ));
        }
      }
      return list;
    } catch (e) {
      print('Error fetching questions for test $testId SDK: $e');
    }
    return [];
  }

  // Fetch chapters from "rajasthan_gk" collection based on subjectKey
  static Future<List<Map<String, dynamic>>> fetchGkChapters(String? subjectKey) async {
    try {
      Query query = FirebaseFirestore.instance.collection('rajasthan_gk');
      if (subjectKey != null) {
        query = query.where('subject', isEqualTo: subjectKey);
      }
      final snapshot = await query.get();

      final List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Parse tests questions array
        final testsRaw = data['tests'] as List?;
        final List<Question> parsedQuestions = [];
        if (testsRaw != null) {
          for (var item in testsRaw) {
            if (item is! Map) continue;
            final questionText = item['question'] as String? ?? '';
            final explanation = item['explanation'] as String?;
            final correctAnswerText = item['correctAnswer'] as String? ?? '';
            
            final optionsRaw = item['options'] as List?;
            if (optionsRaw == null || questionText.isEmpty) continue;
            
            final List<String> parsedOptions = optionsRaw.map((e) => e.toString()).toList();
            
            int correctIndex = parsedOptions.indexWhere(
              (opt) => opt.trim().toLowerCase() == correctAnswerText.trim().toLowerCase()
            );
            if (correctIndex == -1) correctIndex = 0;

            parsedQuestions.add(Question(
              id: '${doc.id}_${parsedQuestions.length}',
              question: questionText,
              options: parsedOptions,
              correctIndex: correctIndex,
              explanation: explanation,
            ));
          }
        }

        list.add({
          'id': doc.id,
          'title': data['title'] as String? ?? 'GK Chapter',
          'subtitle': data['subtitle'] as String? ?? 'Rajasthan GK sub-topic',
          'order': data['order'] is int ? data['order'] : int.tryParse(data['order']?.toString() ?? '') ?? 1,
          'createdAt': data['createdAt'],
          'questionsCount': parsedQuestions.length,
          'time': parsedQuestions.length > 0 ? parsedQuestions.length : 10,
          'isFirestore': true,
          'isGkCollection': true,
          'questions': parsedQuestions,
        });
      }
      
      // Sort in Ascending order (pehle added top pr - oldest first)
      list.sort((a, b) {
        final dateA = _parseDateTime(a['createdAt']);
        final dateB = _parseDateTime(b['createdAt']);
        if (dateA != null && dateB != null) {
          return dateA.compareTo(dateB);
        }
        if (dateA != null) return -1;
        if (dateB != null) return 1;
        
        // Fallback to order
        final int orderA = a['order'] as int? ?? 1;
        final int orderB = b['order'] as int? ?? 1;
        return orderA.compareTo(orderB);
      });
      
      return list;
    } catch (e) {
      print('Error fetching GK chapters from Firestore: $e');
    }
    return [];
  }

  // Fetch active months for Current Affairs
  static Future<List<Map<String, dynamic>>> fetchCurrentAffairsMonths() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('current_affairs_months').get();
      final List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final slug = doc.id;
        final parts = slug.split('-');
        final monthName = parts.first[0].toUpperCase() + parts.first.substring(1);
        final year = parts.length > 1 ? parts[1] : '2026';
        
        list.add({
          'slug': slug,
          'title': '$monthName $year',
          'subtitle': 'मासिक समसामयिकी प्रश्नोत्तरी',
          'isPremium': data['isPremium'] as bool? ?? false,
        });
      }
      if (list.isNotEmpty) {
        // Sort chronologically in Ascending order (pehle added top pr - oldest first)
        list.sort((a, b) => _getMonthWeight(a['slug'].toString()).compareTo(_getMonthWeight(b['slug'].toString())));
        return list;
      }
    } catch (e) {
      print('Error fetching current affairs months from Firestore: $e');
    }
    
    // Fallback static months list in Ascending order (oldest first - Oct 2025 to June 2026)
    return [
      {'slug': 'october-2025', 'title': 'October 2025', 'subtitle': 'अक्टूबर 2025 समसामयिकी', 'isPremium': false},
      {'slug': 'november-2025', 'title': 'November 2025', 'subtitle': 'नवंबर 2025 समसामयिकी', 'isPremium': false},
      {'slug': 'december-2025', 'title': 'December 2025', 'subtitle': 'दिसंबर 2025 समसामयिकी', 'isPremium': false},
      {'slug': 'january-2026', 'title': 'January 2026', 'subtitle': 'जनवरी 2026 समसामयिकी', 'isPremium': false},
      {'slug': 'february-2026', 'title': 'February 2026', 'subtitle': 'फरवरी 2026 समसामयिकी', 'isPremium': false},
      {'slug': 'march-2026', 'title': 'March 2026', 'subtitle': 'मार्च 2026 समसामयिकी', 'isPremium': false},
      {'slug': 'april-2026', 'title': 'April 2026', 'subtitle': 'अप्रैल 2026 समसामयिकी', 'isPremium': false},
      {'slug': 'may-2026', 'title': 'May 2026', 'subtitle': 'मई 2026 समसामयिकी', 'isPremium': false},
      {'slug': 'june-2026', 'title': 'June 2026', 'subtitle': 'जून 2026 समसामयिकी', 'isPremium': false},
    ];
  }

  // Fetch Current Affairs questions for a specific month
  static Future<List<Question>> fetchCurrentAffairsQuestions(String monthSlug) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('current_affairs')
          .where('month', isEqualTo: monthSlug)
          .where('type', isEqualTo: 'mcq')
          .get();

      final List<Question> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final questionText = data['question'] as String? ?? '';
        final correctAnswer = data['correct'] as String? ?? 'A';

        List<String> parsedOptions = [];
        int correctIndex = 0;

        final optionsVal = data['options'] as List?;
        if (optionsVal != null) {
          final optList = optionsVal.map((v) {
            if (v is Map) {
              final label = v['label'] as String? ?? '';
              final text = v['text'] as String? ?? '';
              return {'key': label, 'text': text};
            }
            return {'key': '', 'text': v.toString()};
          }).toList();
          
          optList.removeWhere((e) => e['key'] == '' && e['text'] == '');
          optList.sort((a, b) => a['key']!.compareTo(b['key']!));
          parsedOptions = optList.map((e) => e['text']!).toList();

          correctIndex = optList.indexWhere((e) => e['key'] == correctAnswer);
          if (correctIndex == -1) correctIndex = 0;
        }

        if (questionText.isNotEmpty && parsedOptions.isNotEmpty) {
          list.add(Question(
            id: doc.id,
            question: questionText,
            options: parsedOptions,
            correctIndex: correctIndex,
            explanation: data['explanation'] as String?,
          ));
        }
      }
      return list;
    } catch (e) {
      print('Error fetching current affairs questions: $e');
    }
    return [];
  }

  // Fetch active vacancies from Firestore
  static Future<List<Map<String, dynamic>>> fetchVacancies() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('vacancies').get();
      final List<Map<String, dynamic>> list = [];
      final today = DateTime.now();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Exclude closed or expired items
        final status = data['status'] as String? ?? 'active';
        if (status == 'closed' || status == 'expired') continue;
        
        // Parse lastDate
        final lastDateStr = data['lastDate'] as String?;
        if (lastDateStr != null) {
          final lastDate = DateTime.tryParse(lastDateStr);
          if (lastDate != null && lastDate.isBefore(DateTime(today.year, today.month, today.day))) {
            continue; // Filter expired items
          }
        }

        list.add({
          'id': doc.id,
          'title': data['title'] as String? ?? 'Recruitment Alert',
          'org': data['department'] as String? ?? 'Rajasthan Government',
          'status': status == 'active' ? 'open' : status,
          'posts': data['posts'] is int 
              ? data['posts'] 
              : int.tryParse(data['posts']?.toString() ?? '') ?? 0,
          'qualification': data['qualification'] as String? ?? 'Graduation',
          'ageLimit': data['ageLimit'] as String? ?? '18 – 40 Years',
          'salary': data['salary'] as String? ?? '₹ 20,800 – 65,900',
          'lastDate': lastDateStr,
          'applyLink': data['applyLink'] as String? ?? '',
          'syllabusLink': data['syllabusLink'] as String? ?? '',
          'notificationLink': data['notificationLink'] as String? ?? '',
          'updatedAt': data['updatedAt'],
          'createdAt': data['createdAt'],
        });
      }

      // Sort by recently updated/created first
      list.sort((a, b) {
        final dateA = _parseDateTime(a['updatedAt'] ?? a['createdAt']);
        final dateB = _parseDateTime(b['updatedAt'] ?? b['createdAt']);
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA); // Newest first
        }
        if (dateA != null) return 1;
        if (dateB != null) return -1;
        return 0;
      });

      return list;
    } catch (e) {
      print('Error fetching vacancies from Firestore: $e');
    }
    return [];
  }

  // Fetch approved notes from Firestore
  static Future<List<Map<String, dynamic>>> fetchNotes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('notes').get();
      final List<Map<String, dynamic>> list = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'approved';
        
        if (status.toLowerCase() == 'approved') {
          list.add({
            'id': doc.id,
            'title': data['title'] as String? ?? 'Study Guide',
            'subject': data['subject'] as String? ?? 'General Studies',
            'exam': data['exam'] as String? ?? 'All Exams',
            'language': data['language'] as String? ?? 'Hindi',
            'pages': data['pages'] is int 
                ? data['pages'] 
                : int.tryParse(data['pages']?.toString() ?? '') ?? 0,
            'size': data['size'] as String? ?? 'N/A',
            'type': data['type'] as String? ?? 'free',
            'downloads': data['downloads'] is int 
                ? data['downloads'] 
                : int.tryParse(data['downloads']?.toString() ?? '') ?? 0,
            'category': data['category'] as String? ?? 'more',
            'noteUrl': data['noteUrl'] as String? ?? '',
            'description': data['description'] as String? ?? '',
            'noteType': data['noteType'] as String? ?? 'PDF',
            'createdAt': data['createdAt'],
          });
        }
      }

      // Sort by newest first
      list.sort((a, b) {
        final dateA = _parseDateTime(a['createdAt']);
        final dateB = _parseDateTime(b['createdAt']);
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA); // Newest first
        }
        if (dateA != null) return -1;
        if (dateB != null) return 1;
        return 0;
      });

      return list;
    } catch (e) {
      print('Error fetching notes: $e');
    }
    return [];
  }
}
