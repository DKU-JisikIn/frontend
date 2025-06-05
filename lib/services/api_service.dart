import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/answer.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';

class ApiService {
  // Mockoon 로컬 서버 URL (기본 포트 3001)
  static const String baseUrl = 'http://localhost:3001/api';
  
  // AuthService 인스턴스
  final AuthService _authService = AuthService();
  
  // HTTP 헤더 설정
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 인증이 필요한 요청용 헤더 (JWT 토큰 포함)
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authService.authToken != null) 'Authorization': 'Bearer ${_authService.authToken}',
  };

  // 질문 목록 조회
  Future<List<Question>> getQuestions({String? category, String? search}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions').replace(queryParameters: {
        if (category != null && category != '전체') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('질문 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      // 오류 시 빈 목록 반환
      return [];
    }
  }

  // 인기 질문 목록 조회
  Future<List<Question>> getPopularQuestions({int limit = 10, String period = '전체기간'}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/popular').replace(queryParameters: {
        'limit': limit.toString(),
        'period': period,
      });

      print('Popular questions API 호출: $uri'); // 디버그 로그 추가

      final response = await http.get(uri, headers: headers);

      print('Popular questions 응답 상태: ${response.statusCode}'); // 디버그 로그 추가
      print('Popular questions 응답 본문: ${response.body}'); // 디버그 로그 추가

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Popular questions 파싱된 데이터: $data'); // 디버그 로그 추가
        
        // Mockoon 응답 구조에 맞게 수정: data['response']['questions'] 또는 data['questions']
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          print('Popular questions: questionsJson이 null입니다'); // 디버그 로그 추가
          return [];
        }
        
        print('Popular questions 개수: ${questionsJson.length}'); // 디버그 로그 추가
        
        final questions = questionsJson.map((json) => Question.fromJson(json)).toList();
        print('Popular questions 변환 완료: ${questions.length}개'); // 디버그 로그 추가
        
        return questions;
      } else {
        throw Exception('인기 질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 자주 받은 질문 목록 조회
  Future<List<Question>> getFrequentlyAskedQuestions({int limit = 10, String period = '전체기간'}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/frequent').replace(queryParameters: {
        'limit': limit.toString(),
        'period': period,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('자주 받은 질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 공식 질문 목록 조회
  Future<List<Question>> getOfficialQuestions({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/official').replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('공식 질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 답변받지 못한 질문 목록 조회
  Future<List<Question>> getUnansweredQuestions({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/unanswered').replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('답변받지 못한 질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 질문 검색
  Future<List<Question>> searchQuestions(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/search').replace(queryParameters: {
        'q': query,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('질문 검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 특정 질문 조회
  Future<Question> getQuestionById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Question.fromJson(data);
      } else {
        throw Exception('질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 새 질문 작성
  Future<Question> createQuestion(Question question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: authHeaders, // 인증 토큰 포함
        body: json.encode(question.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Question.fromJson(data);
      } else {
        throw Exception('질문 작성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 특정 질문의 답변 목록 조회
  Future<List<Answer>> getAnswersByQuestionId(String questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$questionId/answers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // null safety 체크 추가 및 Mockoon 응답 구조에 맞게 수정
        final answersJson = (data['response']?['answers'] ?? data['answers']) as List?;
        if (answersJson == null) {
          return []; // null인 경우 빈 리스트 반환
        }
        return answersJson.map((json) => Answer.fromJson(json)).toList();
      } else {
        throw Exception('답변 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 새 답변 작성
  Future<Answer> createAnswer(Answer answer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/answers'),
        headers: authHeaders, // 인증 토큰 포함
        body: json.encode(answer.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Answer.fromJson(data);
      } else {
        throw Exception('답변 작성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 답변 채택
  Future<Answer> acceptAnswer(String answerId, String questionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/answers/$answerId/accept'),
        headers: authHeaders, // 인증 토큰 포함
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Answer.fromJson(data);
      } else {
        throw Exception('답변 채택 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 답변 좋아요/좋아요 취소
  Future<Answer> toggleAnswerLike(String answerId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/answers/$answerId/like'),
        headers: authHeaders, // 인증 토큰 포함
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Answer.fromJson(data);
      } else {
        throw Exception('좋아요 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 채팅 메시지 처리
  Future<List<ChatMessage>> processChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/process'),
        headers: authHeaders, // 인증 토큰 포함
        body: json.encode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return [
          ChatMessage.assistant(
            data['response'] ?? '응답을 받지 못했습니다.',
            metadata: data['metadata'],
          )
        ];
      } else {
        throw Exception('채팅 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      // 오류 시 기본 응답 반환
      return [
        ChatMessage.assistant(
          'API 연결에 문제가 있습니다. Mockoon 서버가 실행 중인지 확인해주세요.',
          metadata: {'type': 'error'},
        ),
      ];
    }
  }

  // 카테고리 자동 감지 (프론트엔드에서 간단히 처리)
  String detectCategory(String content) {
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

  // 채팅에서 질문 생성
  Future<Question> createQuestionFromChat(String title, String content, String category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions/from-chat'),
        headers: authHeaders, // 인증 토큰 포함
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Question.fromJson(data);
      } else {
        throw Exception('채팅에서 질문 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 키워드 추출 (프론트엔드에서 간단히 처리)
  List<String> _extractKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s가-힣]'), '').split(' ');
    
    for (final word in words) {
      if (word.length > 1) {
        keywords.add(word);
      }
    }
    
    return keywords;
  }

  // 오늘의 질문 수 조회
  Future<int> getTodayQuestionCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/today/questions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final responseData = data['response'] ?? data;
        return responseData['count'] ?? 0;
      } else {
        throw Exception('오늘의 질문 수 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 0; // 오류 시 0 반환
    }
  }

  // 오늘의 답변 수 조회
  Future<int> getTodayAnswerCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/today/answers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final responseData = data['response'] ?? data;
        return responseData['count'] ?? 0;
      } else {
        throw Exception('오늘의 답변 수 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 0;
    }
  }

  // 전체 답변 수 조회
  Future<int> getTotalAnswerCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/total/answers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final responseData = data['response'] ?? data;
        return responseData['count'] ?? 0;
      } else {
        throw Exception('전체 답변 수 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 0;
    }
  }

  // 우수 답변자 목록 조회
  Future<List<TopAnswerer>> getTopAnswerers({int limit = 3}) async {
    try {
      final uri = Uri.parse('$baseUrl/statistics/top-answerers').replace(queryParameters: {
        'limit': limit.toString(),
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final topAnswerersJson = (data['response']?['topAnswerers'] ?? data['topAnswerers']) as List?;
        if (topAnswerersJson == null) {
          return [];
        }
        return topAnswerersJson.map((json) => TopAnswerer(
          id: json['id'],
          userName: json['userName'],
          profileImageUrl: json['profileImageUrl'] ?? '',
          score: json['score'],
          rank: json['rank'],
          answerCount: json['answerCount'],
          likeCount: json['likeCount'],
        )).toList();
      } else {
        throw Exception('우수 답변자 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return []; // 오류 시 빈 목록 반환
    }
  }

  // 사용자 질문 통계 조회
  Future<Map<String, int>> getUserQuestionStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/question-stats'),
        headers: authHeaders, // 인증 토큰 포함
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final responseData = data['response'] ?? data;
        return {
          'total': responseData['total'] ?? 0,
          'answered': responseData['answered'] ?? 0,
          'unanswered': responseData['unanswered'] ?? 0,
        };
      } else {
        throw Exception('사용자 질문 통계 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return {
        'total': 0,
        'answered': 0,
        'unanswered': 0,
      };
    }
  }

  // 사용자 질문 목록 조회
  Future<List<Question>> getUserQuestions(String userId, {String? filter}) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/questions').replace(queryParameters: {
        if (filter != null) 'filter': filter,
      });

      final response = await http.get(uri, headers: authHeaders); // 인증 토큰 포함

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mockoon 응답 구조에 맞게 수정
        final questionsJson = (data['response']?['questions'] ?? data['questions']) as List?;
        if (questionsJson == null) {
          return [];
        }
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('사용자 질문 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 백엔드 개발자를 위한 API 엔드포인트 가이드
  /*
  
  === API 엔드포인트 가이드 ===
  
  1. 인증 관련 API:
     POST /api/auth/login                   - 로그인
     POST /api/auth/logout                  - 로그아웃
     POST /api/auth/register                - 회원가입
     POST /api/auth/send-verification       - 이메일 인증 코드 전송
     POST /api/auth/verify-email            - 이메일 인증
  
  2. 질문 관련 API:
     GET  /api/questions                    - 질문 목록 조회
     GET  /api/questions/{id}               - 특정 질문 조회
     POST /api/questions                    - 새 질문 작성
     GET  /api/questions/popular            - 인기 질문 목록
     GET  /api/questions/frequent           - 자주 받은 질문 목록
     GET  /api/questions/official           - 공식 질문 목록
     GET  /api/questions/unanswered         - 답변받지 못한 질문 목록
     GET  /api/questions/search?q={query}   - 질문 검색
     POST /api/questions/from-chat          - 채팅에서 질문 생성
  
  3. 답변 관련 API:
     GET  /api/questions/{id}/answers       - 특정 질문의 답변 목록
     POST /api/answers                      - 새 답변 작성
     PUT  /api/answers/{id}/accept          - 답변 채택
     PUT  /api/answers/{id}/like            - 답변 좋아요/좋아요 취소
  
  4. 채팅 관련 API:
     POST /api/chat/process                 - 채팅 메시지 처리 (AI 응답)
  
  5. 통계 관련 API:
     GET  /api/statistics/today/questions   - 오늘의 질문 수
     GET  /api/statistics/today/answers     - 오늘의 답변 수
     GET  /api/statistics/total/answers     - 전체 답변 수
     GET  /api/statistics/top-answerers     - 우수 답변자 목록
  
  6. 사용자 관련 API:
     GET  /api/users/{userId}/question-stats - 사용자 질문 통계
     GET  /api/users/{userId}/questions      - 사용자 질문 목록
  
  7. 카테고리:
     - 학사
     - 장학금
     - 교내프로그램
     - 취업
     - 기타
  
  8. 요청/응답 형식:
     - Content-Type: application/json
     - 모든 날짜는 ISO 8601 형식 (2024-01-01T00:00:00Z)
     - 페이지네이션: ?page=1&limit=10
     - JWT 인증: Authorization: Bearer {token}
  
  */
}

// 우수 답변자 모델
class TopAnswerer {
  final String id;
  final String userName;
  final String profileImageUrl;
  final int score;
  final int rank;
  final int answerCount;
  final int likeCount;

  TopAnswerer({
    required this.id,
    required this.userName,
    required this.profileImageUrl,
    required this.score,
    required this.rank,
    required this.answerCount,
    required this.likeCount,
  });
} 