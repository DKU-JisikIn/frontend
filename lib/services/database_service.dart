import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';
import '../models/answer.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'dankook_app.db';
  static const int _databaseVersion = 1;

  // 테이블 이름
  static const String questionsTable = 'questions';
  static const String answersTable = 'answers';

  // 싱글톤 인스턴스
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 질문 테이블 생성
    await db.execute('''
      CREATE TABLE $questionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        viewCount INTEGER DEFAULT 0,
        answerCount INTEGER DEFAULT 0,
        isOfficial INTEGER DEFAULT 0,
        category TEXT NOT NULL,
        tags TEXT
      )
    ''');

    // 답변 테이블 생성
    await db.execute('''
      CREATE TABLE $answersTable (
        id TEXT PRIMARY KEY,
        questionId TEXT NOT NULL,
        content TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        likeCount INTEGER DEFAULT 0,
        isAccepted INTEGER DEFAULT 0,
        isAIGenerated INTEGER DEFAULT 0,
        FOREIGN KEY (questionId) REFERENCES $questionsTable (id)
      )
    ''');

    // 샘플 공식 데이터 삽입
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // 단국대 공식 정보 샘플 데이터
    final sampleQuestions = [
      {
        'id': 'official_1',
        'title': '2024학년도 학사일정',
        'content': '''2024학년도 주요 학사일정입니다.

1학기:
- 입학식: 2024년 2월 29일
- 개강: 2024년 3월 4일
- 중간고사: 2024년 4월 22일 ~ 4월 26일
- 기말고사: 2024년 6월 17일 ~ 6월 21일

2학기:
- 개강: 2024년 9월 2일
- 중간고사: 2024년 10월 21일 ~ 10월 25일
- 기말고사: 2024년 12월 16일 ~ 12월 20일''',
        'userId': 'admin',
        'userName': '단국대학교',
        'createdAt': DateTime.now().toIso8601String(),
        'viewCount': 150,
        'answerCount': 0,
        'isOfficial': 1,
        'category': '학사',
        'tags': '["학사일정", "시험", "개강", "방학"]'
      },
      {
        'id': 'official_2',
        'title': '국가장학금 신청 안내',
        'content': '''국가장학금 신청 방법 및 일정 안내입니다.

신청 기간:
- 1차: 2024년 2월 1일 ~ 3월 14일
- 2차: 2024년 5월 22일 ~ 6월 20일

신청 방법:
1. 한국장학재단 홈페이지 접속
2. 공인인증서로 로그인
3. 장학금 신청 메뉴에서 국가장학금 선택
4. 필요 서류 업로드

문의: 학생지원팀 031-8005-2000''',
        'userId': 'admin',
        'userName': '단국대학교',
        'createdAt': DateTime.now().toIso8601String(),
        'viewCount': 89,
        'answerCount': 0,
        'isOfficial': 1,
        'category': '장학금',
        'tags': '["국가장학금", "한국장학재단", "신청방법"]'
      },
    ];

    for (var question in sampleQuestions) {
      await db.insert(questionsTable, question);
    }
  }

  // 질문 관련 메서드
  Future<int> insertQuestion(Question question) async {
    final db = await database;
    final map = question.toJson();
    map['tags'] = question.tags.join(',');
    map['isOfficial'] = question.isOfficial ? 1 : 0;
    map['createdAt'] = question.createdAt.toIso8601String();
    return await db.insert(questionsTable, map);
  }

  Future<List<Question>> getQuestions({String? category, bool? isOfficial}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (isOfficial != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'isOfficial = ?';
      whereArgs.add(isOfficial ? 1 : 0);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }

  Future<Question?> getQuestionById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = Map<String, dynamic>.from(maps.first);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    }
    return null;
  }

  Future<List<Question>> searchQuestions(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }

  // 답변 관련 메서드
  Future<int> insertAnswer(Answer answer) async {
    final db = await database;
    final map = answer.toJson();
    map['isAccepted'] = answer.isAccepted ? 1 : 0;
    map['isAIGenerated'] = answer.isAIGenerated ? 1 : 0;
    map['createdAt'] = answer.createdAt.toIso8601String();
    return await db.insert(answersTable, map);
  }

  Future<List<Answer>> getAnswersByQuestionId(String questionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      answersTable,
      where: 'questionId = ?',
      whereArgs: [questionId],
      orderBy: 'isAccepted DESC, createdAt ASC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isAccepted'] = map['isAccepted'] == 1;
      map['isAIGenerated'] = map['isAIGenerated'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      return Answer.fromJson(map);
    });
  }

  // 카테고리 목록 가져오기
  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM $questionsTable ORDER BY category',
    );
    return maps.map((map) => map['category'] as String).toList();
  }

  // 자주 받은 질문 (답변이 많은 질문)
  Future<List<Question>> getFrequentlyAskedQuestions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      orderBy: 'answerCount DESC, viewCount DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }

  // 조회수 많은 질문
  Future<List<Question>> getPopularQuestions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      orderBy: 'viewCount DESC, createdAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }

  // 최근 질문
  Future<List<Question>> getRecentQuestions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }

  // 공식 정보만 가져오기
  Future<List<Question>> getOfficialQuestions({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      questionsTable,
      where: 'isOfficial = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      map['isOfficial'] = map['isOfficial'] == 1;
      map['createdAt'] = DateTime.parse(map['createdAt']);
      map['tags'] = (map['tags'] as String).split(',').where((tag) => tag.isNotEmpty).toList();
      return Question.fromJson(map);
    });
  }
} 