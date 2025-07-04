import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/answer.dart';
import '../models/chat_message.dart';
import '../models/top_answerer.dart';

class ApiService {
  // Azure Container Apps 백엔드 서버 URL
  static const String baseUrl = 'https://taba-backend2.purpleforest-e1d94921.koreacentral.azurecontainerapps.io';
  
  // HTTP 헤더 설정
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 인증이 필요한 요청용 헤더 (JWT 토큰 포함)
  Map<String, String> getAuthHeaders({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
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
        final questionsJson = data['response']['questions'] as List;
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('질문 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 인기 질문 목록 조회
  Future<List<Question>> getPopularQuestions({int limit = 10, String? period}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/popular').replace(queryParameters: {
        'limit': limit.toString(),
        if (period != null) 'period': period,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionsJson = data['response']['questions'] as List;
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('인기 질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return [];
    }
  }

  // 자주 받은 질문 목록 조회
  Future<List<Question>> getFrequentlyAskedQuestions({int limit = 10, String? period}) async {
    try {
      final uri = Uri.parse('$baseUrl/questions/frequent').replace(queryParameters: {
        'limit': limit.toString(),
        if (period != null) 'period': period,
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questionsJson = data['response']['questions'] as List;
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
        final questionsJson = data['response']['questions'] as List;
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
        final questionsJson = data['response']['questions'] as List;
        return questionsJson.map((json) => Question.fromJson(json)).toList();
      } else {
        print('답변받지 못한 질문 API 응답 오류: ${response.statusCode}');
        return _getMockUnansweredQuestions(limit);
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return _getMockUnansweredQuestions(limit);
    }
  }

  // 목업 답변받지 못한 질문 데이터
  List<Question> _getMockUnansweredQuestions(int limit) {
    final mockQuestions = [
      Question(
        id: 'mock_1',
        title: '수강신청 기간이 언제인가요?',
        content: '다음 학기 수강신청 기간과 방법에 대해 궁금합니다.',
        category: '학사',
        userId: 'user1',
        userName: '학생A',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        viewCount: 23,
        answerCount: 0,
        isAnswered: false,
        tags: ['수강신청', '학사일정'],
      ),
      Question(
        id: 'mock_2',
        title: '장학금 신청 조건이 궁금해요',
        content: '성적우수장학금과 가계곤란장학금의 신청 조건과 절차를 알고 싶습니다.',
        category: '장학금',
        userId: 'user2',
        userName: '김학생',
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
        viewCount: 45,
        answerCount: 0,
        isAnswered: false,
        tags: ['장학금', '신청조건'],
      ),
      Question(
        id: 'mock_3',
        title: '도서관 열람실 이용 방법',
        content: '도서관 열람실 예약은 어떻게 하나요? 이용 시간과 규칙도 알려주세요.',
        category: '기타',
        userId: 'user3',
        userName: '이학생',
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
        viewCount: 67,
        answerCount: 0,
        isAnswered: false,
        tags: ['도서관', '열람실'],
      ),
      Question(
        id: 'mock_4',
        title: '취업박람회 참가 방법',
        content: '다음 달에 열리는 취업박람회에 참가하려면 어떻게 신청해야 하나요?',
        category: '취업',
        userId: 'user4',
        userName: '박학생',
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
        viewCount: 34,
        answerCount: 0,
        isAnswered: false,
        tags: ['취업박람회', '신청'],
      ),
      Question(
        id: 'mock_5',
        title: '동아리 창설 절차',
        content: '새로운 동아리를 만들려고 하는데 필요한 절차와 조건이 무엇인가요?',
        category: '교내프로그램',
        userId: 'user5',
        userName: '최학생',
        createdAt: DateTime.now().subtract(Duration(hours: 18)),
        viewCount: 28,
        answerCount: 0,
        isAnswered: false,
        tags: ['동아리', '창설'],
      ),
    ];
    
    return mockQuestions.take(limit).toList();
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
        return Question.fromJson(data['response']);
      } else {
        throw Exception('질문 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 새 질문 작성
  Future<Question> createQuestion(Question question, {String? token}) async {
    try {
      if (question.title.trim().isEmpty) {
        throw Exception('질문 제목을 입력해주세요.');
      }

      if (question.content.trim().isEmpty) {
        throw Exception('질문 내용을 입력해주세요.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: getAuthHeaders(token: token),
        body: json.encode(question.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Question.fromJson(data['response']);
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
        final answersJson = data['response']['answers'] as List;
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
  Future<Answer> createAnswer(String questionId, String content, {String? token}) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception('답변 내용을 입력해주세요.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/questions/$questionId/answers'),
        headers: getAuthHeaders(token: token),
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Answer.fromJson(data['response']);
      } else {
        throw Exception('답변 작성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 답변 채택
  Future<Answer> acceptAnswer(String questionId, String answerId, {String? token}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/questions/$questionId/answers/$answerId/accept'),
        headers: getAuthHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Answer.fromJson(data['response']);
      } else {
        throw Exception('답변 채택 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 답변 좋아요/좋아요 취소
  Future<Answer> likeAnswer(String answerId, {String? token}) async {
    try {
      print('좋아요 API 호출: PUT $baseUrl/answers/$answerId/like'); // 디버깅 로그
      
      final response = await http.put(
        Uri.parse('$baseUrl/answers/$answerId/like'),
        headers: getAuthHeaders(token: token), // 인증 토큰 포함
      );

      print('좋아요 API 응답 상태: ${response.statusCode}'); // 디버깅 로그
      print('좋아요 API 응답 본문: ${response.body}'); // 디버깅 로그

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('좋아요 API 파싱된 데이터: $data'); // 디버깅 로그
        
        // Mockoon 응답이 래핑되어 있는지 확인
        final answerData = data['response'] ?? data;
        
        // 필수 필드들이 null인지 확인하고 안전하게 처리
        if (answerData['id'] == null) {
          throw Exception('응답에서 id 필드가 null입니다');
        }
        if (answerData['questionId'] == null) {
          throw Exception('응답에서 questionId 필드가 null입니다');
        }
        if (answerData['content'] == null) {
          throw Exception('응답에서 content 필드가 null입니다');
        }
        if (answerData['userId'] == null) {
          throw Exception('응답에서 userId 필드가 null입니다');
        }
        if (answerData['userName'] == null) {
          throw Exception('응답에서 userName 필드가 null입니다');
        }
        if (answerData['createdAt'] == null) {
          throw Exception('응답에서 createdAt 필드가 null입니다');
        }
        
        return Answer.fromJson(answerData);
      } else {
        throw Exception('좋아요 처리 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 채팅 메시지 처리
  Future<List<ChatMessage>> processChatMessage(String message, {String? token}) async {
    try {
      if (message.trim().isEmpty) {
        return [
          ChatMessage.assistant(
            '메시지를 입력해주세요.',
            metadata: {'type': 'error'},
          ),
        ];
      }

      print('DEBUG: 채팅 API 호출 시작 - baseUrl: $baseUrl');
      print('DEBUG: 메시지: $message');
      print('DEBUG: 토큰: ${token != null ? "있음" : "없음"}');

      final requestBody = {
        'message': message.trim(),
      };
      
      print('DEBUG: 요청 데이터: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/process'),
        headers: getAuthHeaders(token: token),
        body: json.encode(requestBody),
      );

      print('DEBUG: 응답 상태 코드: ${response.statusCode}');
      print('DEBUG: 응답 헤더: ${response.headers}');
      print('DEBUG: 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final List<ChatMessage> messages = [];
        
        if (data['answer'] != null && data['answer'].toString().isNotEmpty) {
          messages.add(ChatMessage.assistant(
            data['answer'],
            metadata: {
              'actions': data['actions'] ?? {
                'canCreateQuestion': true,
                'hasDirectAnswer': false,
              },
              'relatedQuestions': data['references'] ?? data['relatedQuestions'] ?? [],
            },
          ));
        }

        if (messages.isEmpty) {
          // 백엔드에서 빈 응답이 온 경우 목 데이터로 대체
          return _getMockChatResponse(message);
        }

        return messages;
      } else {
        print('DEBUG: API 오류 - 상태코드: ${response.statusCode}, 응답: ${response.body}');
        // 400 오류나 기타 오류 시 목 데이터로 대체
        return _getMockChatResponse(message);
      }
    } catch (e) {
      print('API 호출 오류: $e');
      // 네트워크 오류 시에도 목 데이터로 대체
      return _getMockChatResponse(message);
    }
  }

  // 목 데이터 응답 생성
  List<ChatMessage> _getMockChatResponse(String message) {
    // 키워드 기반으로 간단한 응답 생성
    final lowerMessage = message.toLowerCase();
    String response;
    Map<String, dynamic> metadata;

    if (lowerMessage.contains('수강신청') || lowerMessage.contains('학사')) {
      response = '수강신청과 관련된 문의시에는 학사지원팀(031-8005-2111)으로 문의하시거나, 웹정보서비스에서 확인하실 수 있습니다.';
      metadata = {
        'actions': {
          'canCreateQuestion': true,
          'hasDirectAnswer': true,
        },
        'relatedQuestions': [
          {'title': '수강신청 일정은 언제인가요?', 'id': 'mock1'},
          {'title': '수강신청 오류 해결 방법', 'id': 'mock2'},
          {'title': '재수강 신청 방법', 'id': 'mock3'},
        ],
      };
    } else if (lowerMessage.contains('장학금')) {
      response = '장학금 관련 문의는 학생지원팀(031-8005-2222)으로 연락하시거나, 학생포털에서 장학금 안내를 확인하세요.';
      metadata = {
        'actions': {
          'canCreateQuestion': true,
          'hasDirectAnswer': true,
        },
        'relatedQuestions': [
          {'title': '성적장학금 신청 방법', 'id': 'mock4'},
          {'title': '생활비 지원 장학금', 'id': 'mock5'},
          {'title': '외부 장학금 정보', 'id': 'mock6'},
        ],
      };
    } else if (lowerMessage.contains('취업') || lowerMessage.contains('진로')) {
      response = '취업 및 진로 상담은 취업지원센터(031-8005-3333)에서 도움받으실 수 있습니다. 진로상담 예약도 가능합니다.';
      metadata = {
        'actions': {
          'canCreateQuestion': true,
          'hasDirectAnswer': true,
        },
        'relatedQuestions': [
          {'title': '취업박람회 일정', 'id': 'mock7'},
          {'title': '이력서 작성 도움', 'id': 'mock8'},
          {'title': '인턴십 프로그램', 'id': 'mock9'},
        ],
      };
    } else if (lowerMessage.contains('도서관')) {
      response = '중앙도서관 이용시간은 평일 9:00-22:00, 주말 9:00-18:00입니다. 열람실 좌석 예약은 도서관 홈페이지에서 가능합니다.';
      metadata = {
        'actions': {
          'canCreateQuestion': true,
          'hasDirectAnswer': true,
        },
        'relatedQuestions': [
          {'title': '도서관 좌석 예약 방법', 'id': 'mock10'},
          {'title': '도서 대출 연장', 'id': 'mock11'},
          {'title': '그룹스터디룸 예약', 'id': 'mock12'},
        ],
      };
    } else {
      response = '질문해 주신 내용에 대한 정확한 정보를 찾기 어렵습니다. 더 구체적인 질문을 작성해 주시면 다른 학우들이 도움을 드릴 수 있을 것 같습니다.';
      metadata = {
        'actions': {
          'canCreateQuestion': true,
          'hasDirectAnswer': false,
        },
        'relatedQuestions': [],
      };
    }

    return [
      ChatMessage.assistant(
        response,
        metadata: metadata,
      ),
    ];
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
  Future<Question> createQuestionFromChat(String title, String content, String category, {String? token}) async {
    try {
      // /questions/from-chat 엔드포인트가 405 오류를 반환하므로 일반 질문 생성 API 사용
      final questionData = Question(
        id: '', // 서버에서 생성됨
        title: title.trim(),
        content: content.trim(),
        category: category,
        userId: '', // 서버에서 토큰으로 식별
        userName: '', // 서버에서 설정
        createdAt: DateTime.now(),
        viewCount: 0,
        answerCount: 0,
        isAnswered: false,
        tags: extractKeywords(content),
      );

      final response = await http.post(
        Uri.parse('$baseUrl/questions'),
        headers: getAuthHeaders(token: token),
        body: json.encode(questionData.toJson()),
      );

      print('DEBUG: 질문 생성 API 응답 상태: ${response.statusCode}');
      print('DEBUG: 질문 생성 API 응답 본문: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        // 응답 구조에 따라 적절히 처리
        final questionJson = data['response'] ?? data;
        return Question.fromJson(questionJson);
      } else {
        print('DEBUG: 질문 생성 실패 - 상태코드: ${response.statusCode}, 응답: ${response.body}');
        throw Exception('질문 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('질문 생성 API 호출 오류: $e');
      rethrow;
    }
  }

  // 키워드 추출 (프론트엔드에서 간단히 처리)
  List<String> extractKeywords(String text) {
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
        return data['response']['count'];
      } else {
        print('오늘의 질문 수 API 응답 오류: ${response.statusCode}');
        return 12; // 목업 데이터
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 12; // 목업 데이터
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
        return data['response']['count'];
      } else {
        print('오늘의 답변 수 API 응답 오류: ${response.statusCode}');
        return 28; // 목업 데이터
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 28; // 목업 데이터
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
        return data['response']['count'];
      } else {
        print('전체 답변 수 API 응답 오류: ${response.statusCode}');
        return 1847; // 목업 데이터
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return 1847; // 목업 데이터
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
          return _getMockTopAnswerers(limit);
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
        print('우수 답변자 API 응답 오류: ${response.statusCode}');
        return _getMockTopAnswerers(limit);
      }
    } catch (e) {
      print('API 호출 오류: $e');
      return _getMockTopAnswerers(limit); // 오류 시 목업 데이터 반환
    }
  }

  // 목업 우수 답변자 데이터
  List<TopAnswerer> _getMockTopAnswerers(int limit) {
    final mockData = [
      TopAnswerer(
        id: '1',
        userName: '김도움',
        profileImageUrl: '',
        score: 2850,
        rank: 1,
        answerCount: 47,
        likeCount: 125,
      ),
      TopAnswerer(
        id: '2',
        userName: '이답변',
        profileImageUrl: '',
        score: 2120,
        rank: 2,
        answerCount: 32,
        likeCount: 89,
      ),
      TopAnswerer(
        id: '3',
        userName: '박해결',
        profileImageUrl: '',
        score: 1890,
        rank: 3,
        answerCount: 28,
        likeCount: 76,
      ),
      TopAnswerer(
        id: '4',
        userName: '최질문',
        profileImageUrl: '',
        score: 1650,
        rank: 4,
        answerCount: 24,
        likeCount: 63,
      ),
      TopAnswerer(
        id: '5',
        userName: '정학사',
        profileImageUrl: '',
        score: 1420,
        rank: 5,
        answerCount: 19,
        likeCount: 52,
      ),
    ];
    
    return mockData.take(limit).toList();
  }

  // 사용자 질문 통계 조회
  Future<Map<String, dynamic>> getUserQuestionStats(String userId, {String? token}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/question-stats'),
        headers: getAuthHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['response'] ?? data;
        return {
          'total': responseData['total'] ?? 0,
          'answered': responseData['answered'] ?? 0,
          'unanswered': responseData['unanswered'] ?? 0,
        };
      }
      
      throw Exception('사용자 질문 통계 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('사용자 질문 통계 API 호출 오류: $e');
      throw Exception('사용자 질문 통계 조회 실패: $e');
    }
  }

  // 사용자 질문 목록 조회
  Future<List<Question>> getUserQuestions(String userId, {String? filter, String? token}) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/questions').replace(queryParameters: {
        if (filter != null) 'filter': filter,
      });

      final response = await http.get(uri, headers: getAuthHeaders(token: token)); // 인증 토큰 포함

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

  // 이메일 인증 코드 전송
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-verification'),
        headers: headers,
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 실제 서버는 response 래핑 없이 직접 반환
        return data;
      } else {
        throw Exception('인증 코드 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 이메일 인증
  Future<Map<String, dynamic>> verifyEmail(int requestId, String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: headers,
        body: json.encode({
          'requestId': requestId,
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 실제 서버는 response 래핑 없이 직접 반환
        return data;
      } else {
        throw Exception('이메일 인증 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register(String email, String password, String nickname) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        // 실제 서버는 response 래핑 없이 직접 반환
        return data;
      } else {
        throw Exception('회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> logout(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
        body: json.encode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('로그아웃 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 프로필 수정
  Future<Map<String, dynamic>> updateProfile(String nickname, String profileImageUrl, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/edit-profile'),
        headers: getAuthHeaders(token: token),
        body: json.encode({
          'nickname': nickname,
          'profileImageUrl': profileImageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      } else {
        throw Exception('프로필 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 소속 인증
  Future<Map<String, dynamic>> verifyDepartment(String email, String department, {String? token}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/verify-department'),
        headers: getAuthHeaders(token: token),
        body: json.encode({
          'email': email,
          'department': department,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      } else {
        throw Exception('소속 인증 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // 회원탈퇴
  Future<Map<String, dynamic>> deleteAccount({String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-account'),
        headers: getAuthHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'];
      } else {
        throw Exception('회원탈퇴 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
    }
  }

  // AI 질문 작성 도우미
  Future<Map<String, dynamic>> composeQuestion(String userMessage, {String? token}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/questions/compose'),
        headers: getAuthHeaders(token: token),
        body: json.encode({
          'userMessage': userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response']['composedQuestion'];
      } else {
        throw Exception('질문 작성 도우미 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('API 호출 오류: $e');
      rethrow;
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
     PATCH /api/auth/verify-department      - 소속 인증
     DELETE /api/auth/delete-account        - 회원탈퇴
  
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
     POST /api/questions/{id}/answers       - 새 답변 작성
     PUT  /api/questions/{id}/answers/{id}/accept - 답변 채택
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
     PATCH /api/users/edit-profile          - 프로필 수정
  
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