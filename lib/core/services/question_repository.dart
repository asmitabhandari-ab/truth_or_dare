import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';
import 'database_helper.dart';

class QuestionRepository {
  List<Question>? _defaultQuestions;

  Future<List<Question>> getQuestions({
    required String category,
    required bool include18Plus,
  }) async {
    final questions = <Question>[...await _loadDefaultQuestions()];

    try {
      questions.addAll(await DatabaseHelper.instance.getCustomQuestions());
    } catch (_) {
      // The built-in question bank remains available if local storage is unavailable.
    }

    return questions.where((question) {
      final matchesCategory =
          category == 'all' || question.category == category;
      final isAllowed = include18Plus || question.ageRating != '18+';
      return matchesCategory && isAllowed;
    }).toList();
  }

  Future<List<Question>> _loadDefaultQuestions() async {
    if (_defaultQuestions != null) return _defaultQuestions!;

    final contents = await rootBundle.loadString('assets/data/questions.json');
    final decoded = jsonDecode(contents) as List<dynamic>;
    _defaultQuestions = decoded
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return _defaultQuestions!;
  }
}
