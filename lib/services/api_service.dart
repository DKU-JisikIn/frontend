import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/answer.dart';
import '../models/chat_message.dart';

class ApiService {
  // TODO: 백엔드 개발자가 실제 API 엔드포인트로 변경해야 함
  static const String baseUrl = 'https://your-backend-api.com/api';
  
  // 질문 관련 API
  Future<List<Question>> getQuestions({String? category, String? search}) async {
    // TODO: 실제 API 호출로 대체
    // 현재는 목업 데이터 반환
    return _getMockQuestions();
  }

  Future<List<Question>> getPopularQuestions({int limit = 10}) async {
    // TODO: 실제 API 호출로 대체
    return _getMockQuestions().take(limit).toList();
  }

  Future<List<Question>> getFrequentlyAskedQuestions({int limit = 10}) async {
    // TODO: 실제 API 호출로 대체
    return _getMockQuestions().take(limit).toList();
  }

  Future<List<Question>> getOfficialQuestions({int limit = 10}) async {
    // TODO: 실제 API 호출로 대체
    return _getMockQuestions().where((q) => q.isOfficial).take(limit).toList();
  }

  Future<List<Question>> searchQuestions(String query) async {
    // TODO: 실제 API 호출로 대체
    return _getMockQuestions()
        .where((q) => q.title.contains(query) || q.content.contains(query))
        .toList();
  }

  Future<Question> createQuestion(Question question) async {
    // TODO: 실제 API 호출로 대체
    // POST /api/questions
    return question;
  }

  Future<Question> getQuestionById(String id) async {
    // TODO: 실제 API 호출로 대체
    return _getMockQuestions().firstWhere((q) => q.id == id);
  }

  // 답변 관련 API
  Future<List<Answer>> getAnswersByQuestionId(String questionId) async {
    // TODO: 실제 API 호출로 대체
    return _getMockAnswers().where((a) => a.questionId == questionId).toList();
  }

  Future<Answer> createAnswer(Answer answer) async {
    // TODO: 실제 API 호출로 대체
    // POST /api/answers
    return answer;
  }

  // 채팅 관련 API
  Future<List<ChatMessage>> processChatMessage(String message) async {
    // TODO: 실제 AI/백엔드 API 호출로 대체
    // POST /api/chat/process
    
    // 현재는 간단한 목업 응답
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션
    
    // 사용자 메시지는 제외하고 AI 답변만 반환
    return [
      ChatMessage.assistant(
        '죄송합니다. 현재 백엔드 연동 대기 중입니다.\n백엔드 개발자가 API를 구현하면 정상적으로 작동할 예정입니다.',
        metadata: {'type': 'mock_response'},
      ),
    ];
  }

  // 카테고리 자동 감지 (백엔드에서 처리할 예정)
  String detectCategory(String content) {
    // TODO: 백엔드 AI API로 대체
    final text = content.toLowerCase();
    
    if (text.contains('수강신청') || text.contains('학사일정') || text.contains('성적') || text.contains('학점')) {
      return '학사';
    } else if (text.contains('장학금') || text.contains('등록금') || text.contains('학비')) {
      return '장학금';
    } else if (text.contains('취업') || text.contains('인턴') || text.contains('채용') || text.contains('진로')) {
      return '취업';
    } else if (text.contains('동아리') || text.contains('행사') || text.contains('프로그램') || text.contains('활동')) {
      return '교내프로그램';
    }
    
    return '기타';
  }

  // 채팅에서 질문 생성 (백엔드에서 처리할 예정)
  Future<Question> createQuestionFromChat(String title, String content, String category) async {
    // TODO: 백엔드 API 호출로 대체
    // POST /api/questions/from-chat
    
    final question = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      userId: 'user_001', // TODO: 실제 사용자 ID로 대체
      userName: '익명',
      createdAt: DateTime.now(),
      category: category,
      tags: _extractKeywords(content).take(3).toList(),
    );
    
    // 목업: 실제로는 백엔드에 저장
    return question;
  }

  // 키워드 추출 (백엔드에서 처리할 예정)
  List<String> _extractKeywords(String text) {
    // TODO: 백엔드 AI API로 대체
    final keywords = <String>[];
    final words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s가-힣]'), '').split(' ');
    
    for (final word in words) {
      if (word.length > 1) {
        keywords.add(word);
      }
    }
    
    return keywords;
  }

  // 목업 데이터 (백엔드 연동 전까지 임시 사용)
  List<Question> _getMockQuestions() {
    return [
      Question(
        id: '1',
        title: '2024년 1학기 수강신청 일정이 언제인가요?',
        content: '수강신청 일정을 알고 싶습니다.',
        userId: 'admin',
        userName: '학사팀',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        category: '학사',
        isOfficial: true,
        viewCount: 150,
        answerCount: 1,
        tags: ['수강신청', '일정', '학사'],
      ),
      Question(
        id: '2',
        title: '장학금 신청 방법을 알려주세요',
        content: '성적 장학금 신청하려면 어떻게 해야 하나요?',
        userId: 'user1',
        userName: '익명',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        category: '장학금',
        viewCount: 89,
        answerCount: 2,
        tags: ['장학금', '신청'],
      ),
      Question(
        id: '3',
        title: '도서관 이용시간이 어떻게 되나요?',
        content: '중앙도서관 평일/주말 이용시간을 알고 싶습니다.',
        userId: 'admin',
        userName: '도서관',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: '기타',
        isOfficial: true,
        viewCount: 234,
        answerCount: 1,
        tags: ['도서관', '이용시간'],
      ),
      Question(
        id: '4',
        title: '졸업요건이 어떻게 되나요?',
        content: '컴퓨터공학과 졸업요건을 알고 싶습니다.',
        userId: 'user2',
        userName: '학생',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        category: '학사',
        viewCount: 67,
        answerCount: 3,
        tags: ['졸업요건', '학사'],
      ),
      Question(
        id: '5',
        title: '국가장학금 신청 기간이 언제인가요?',
        content: '국가장학금 1차 신청 기간을 알려주세요.',
        userId: 'admin',
        userName: '학생지원팀',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        category: '장학금',
        isOfficial: true,
        viewCount: 198,
        answerCount: 1,
        tags: ['국가장학금', '신청기간'],
      ),
      Question(
        id: '6',
        title: '교내 동아리 가입 방법',
        content: '새 학기 동아리 가입하고 싶은데 어떻게 하나요?',
        userId: 'user3',
        userName: '신입생',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        category: '교내프로그램',
        viewCount: 45,
        answerCount: 2,
        tags: ['동아리', '가입'],
      ),
      Question(
        id: '7',
        title: '취업박람회 일정 문의',
        content: '올해 취업박람회는 언제 열리나요?',
        userId: 'user4',
        userName: '4학년',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        category: '취업',
        viewCount: 123,
        answerCount: 1,
        tags: ['취업박람회', '일정'],
      ),
      Question(
        id: '8',
        title: '학식 메뉴와 운영시간',
        content: '학생식당 메뉴와 운영시간이 궁금합니다.',
        userId: 'user5',
        userName: '재학생',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        category: '기타',
        viewCount: 78,
        answerCount: 0,
        tags: ['학식', '운영시간'],
      ),
      Question(
        id: '9',
        title: '성적 이의신청 방법',
        content: '성적에 이상이 있어서 이의신청하고 싶습니다.',
        userId: 'user6',
        userName: '학생',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        category: '학사',
        viewCount: 92,
        answerCount: 2,
        tags: ['성적', '이의신청'],
      ),
      Question(
        id: '10',
        title: '교환학생 프로그램 안내',
        content: '해외 교환학생 프로그램에 대해 알고 싶습니다.',
        userId: 'admin',
        userName: '국제교류팀',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        category: '교내프로그램',
        isOfficial: true,
        viewCount: 156,
        answerCount: 1,
        tags: ['교환학생', '해외'],
      ),
    ];
  }

  List<Answer> _getMockAnswers() {
    return [
      Answer(
        id: '1',
        questionId: '1',
        content: '2024년 1학기 수강신청은 2월 5일부터 시작됩니다.\n자세한 일정은 학사공지를 확인해주세요.',
        userId: 'admin',
        userName: '학사팀',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        isAccepted: true,
        likeCount: 25,
      ),
      Answer(
        id: '2',
        questionId: '2',
        content: '성적 장학금은 매 학기 말에 신청 가능합니다.\n학사시스템에서 온라인으로 신청하시면 됩니다.',
        userId: 'user2',
        userName: '선배',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likeCount: 12,
      ),
      Answer(
        id: '3',
        questionId: '3',
        content: '중앙도서관 이용시간:\n평일: 09:00 - 22:00\n주말: 09:00 - 18:00',
        userId: 'admin',
        userName: '도서관',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isAccepted: true,
        likeCount: 18,
      ),
    ];
  }

  // 백엔드 개발자를 위한 API 엔드포인트 가이드
  /*
  
  === API 엔드포인트 가이드 ===
  
  1. 질문 관련 API:
     GET  /api/questions                    - 질문 목록 조회
     GET  /api/questions/{id}               - 특정 질문 조회
     POST /api/questions                    - 새 질문 작성
     GET  /api/questions/popular            - 인기 질문 목록
     GET  /api/questions/frequent           - 자주 받은 질문 목록
     GET  /api/questions/official           - 공식 질문 목록
     GET  /api/questions/search?q={query}   - 질문 검색
  
  2. 답변 관련 API:
     GET  /api/questions/{id}/answers       - 특정 질문의 답변 목록
     POST /api/answers                      - 새 답변 작성
     PUT  /api/answers/{id}/accept          - 답변 채택
     PUT  /api/answers/{id}/like            - 답변 좋아요
  
  3. 채팅 관련 API:
     POST /api/chat/process                 - 채팅 메시지 처리 (AI 응답)
  
  4. 카테고리:
     - 학사
     - 장학금
     - 교내프로그램
     - 취업
     - 기타
  
  5. 요청/응답 형식:
     - Content-Type: application/json
     - 모든 날짜는 ISO 8601 형식 (2024-01-01T00:00:00Z)
     - 페이지네이션: ?page=1&limit=10
  
  */
} 