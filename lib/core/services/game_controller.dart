import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/question.dart';
import 'question_repository.dart';

enum PlayerSelectionMode { spinBottle, random }

class GameController extends ChangeNotifier {
  GameController({QuestionRepository? questionRepository})
    : _questionRepository = questionRepository ?? QuestionRepository();

  static const avatars = <String>[
    '\u{1F60E}',
    '\u{1F43C}',
    '\u{1F98A}',
    '\u{1F47B}',
    '\u{1F438}',
    '\u{1F42F}',
    '\u{1F984}',
    '\u{1F916}',
    '\u{1F428}',
    '\u{1F419}',
    '\u{1F98B}',
    '\u{1F43A}',
  ];

  final QuestionRepository _questionRepository;
  final Random _random = Random();
  final List<Player> _players = [];
  final Set<String> _usedQuestionIds = <String>{};

  Player? currentPlayer;
  Question? currentQuestion;
  String selectedCategory = 'all';
  bool include18Plus = false;
  PlayerSelectionMode selectionMode = PlayerSelectionMode.spinBottle;
  bool soundEnabled = true;
  bool hapticsEnabled = true;
  int rounds = 0;
  int truthsCompleted = 0;
  int daresCompleted = 0;
  int skipped = 0;
  String? _lastQuestionId;

  List<Player> get players => List.unmodifiable(_players);
  int get completed => truthsCompleted + daresCompleted;

  Future<void> initialise() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      soundEnabled = preferences.getBool('soundEnabled') ?? true;
      hapticsEnabled = preferences.getBool('hapticsEnabled') ?? true;
    } catch (_) {
      // Settings gracefully fall back to defaults when platform storage is unavailable.
    }
    notifyListeners();
  }

  String? addPlayer(String value) {
    final name = value.trim();
    if (name.isEmpty) return 'Enter a player name.';
    if (_players.length >= 12) return 'A game can have up to 12 players.';
    if (_players.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    )) {
      return 'Each player needs a different name.';
    }

    _players.add(
      Player(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        avatar: avatars[_players.length % avatars.length],
      ),
    );
    notifyListeners();
    return null;
  }

  void removePlayer(int index) {
    _players.removeAt(index);
    notifyListeners();
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final player = _players.removeAt(oldIndex);
    _players.insert(newIndex, player);
    notifyListeners();
  }

  void startSession() {
    currentPlayer = null;
    currentQuestion = null;
    _usedQuestionIds.clear();
    _lastQuestionId = null;
    rounds = 0;
    truthsCompleted = 0;
    daresCompleted = 0;
    skipped = 0;
    for (final player in _players) {
      player
        ..score = 0
        ..completed = 0
        ..skipped = 0;
    }
    notifyListeners();
  }

  void resetGame() {
    _players.clear();
    startSession();
  }

  void selectCategory(String category, {bool allow18Plus = false}) {
    selectedCategory = category;
    include18Plus = allow18Plus;
    notifyListeners();
  }

  void selectPlayerMode(PlayerSelectionMode mode) {
    selectionMode = mode;
    notifyListeners();
  }

  Player pickNextPlayer() {
    final options = _players.length > 1 && currentPlayer != null
        ? _players.where((player) => player.id != currentPlayer!.id).toList()
        : _players;
    currentPlayer = options[_random.nextInt(options.length)];
    currentQuestion = null;
    notifyListeners();
    return currentPlayer!;
  }

  Future<Question?> chooseQuestion(String type) async {
    final allQuestions = await _questionRepository.getQuestions(
      category: selectedCategory,
      include18Plus: include18Plus,
    );
    final eligible = allQuestions
        .where((question) => question.type == type)
        .toList();
    if (eligible.isEmpty) return null;

    var candidates = eligible
        .where((question) => !_usedQuestionIds.contains(question.id))
        .toList();
    if (candidates.isEmpty) {
      _usedQuestionIds.clear();
      candidates = eligible
          .where((question) => question.id != _lastQuestionId)
          .toList();
    }
    if (candidates.isEmpty) candidates = eligible;

    currentQuestion = candidates[_random.nextInt(candidates.length)];
    _usedQuestionIds.add(currentQuestion!.id);
    _lastQuestionId = currentQuestion!.id;
    notifyListeners();
    return currentQuestion;
  }

  void completeQuestion() {
    if (currentPlayer == null || currentQuestion == null) return;
    currentPlayer!
      ..score += currentQuestion!.intensity == 'hard' ? 2 : 1
      ..completed += 1;
    if (currentQuestion!.type == 'truth') {
      truthsCompleted += 1;
    } else {
      daresCompleted += 1;
    }
    rounds += 1;
    notifyListeners();
  }

  void skipQuestion() {
    if (currentPlayer == null || currentQuestion == null) return;
    currentPlayer!.skipped += 1;
    skipped += 1;
    rounds += 1;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('soundEnabled', value);
    } catch (_) {
      // The in-memory setting still applies for this session.
    }
  }

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled = value;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('hapticsEnabled', value);
    } catch (_) {
      // The in-memory setting still applies for this session.
    }
  }
}
