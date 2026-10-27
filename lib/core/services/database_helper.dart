import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('truth_or_dare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE questions (
  id $idType,
  type $textType,
  category $textType,
  intensity $textType,
  text $textType,
  timer $intType,
  players $textType,
  ageRating $textType,
  isCustom $boolType
  )
''');
  }

  Future<void> insertQuestion(Question question) async {
    final db = await instance.database;
    await db.insert(
      'questions',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Question>> getCustomQuestions() async {
    final db = await instance.database;
    final maps = await db.query('questions', where: 'isCustom = 1');
    return maps.map(Question.fromJson).toList();
  }
}
