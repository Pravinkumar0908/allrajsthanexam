class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

class QuizCategory {
  final String id;
  final String name;
  final String icon;
  final int questionCount;
  final String description;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.questionCount,
    required this.description,
  });
}

class QuizResult {
  final String categoryName;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final Duration timeTaken;
  final List<QuestionAttempt> attempts;

  const QuizResult({
    required this.categoryName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.timeTaken,
    required this.attempts,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }
}

class QuestionAttempt {
  final Question question;
  final int? selectedIndex;

  const QuestionAttempt({
    required this.question,
    this.selectedIndex,
  });

  bool get isCorrect => selectedIndex == question.correctIndex;
  bool get isAttempted => selectedIndex != null;
}
