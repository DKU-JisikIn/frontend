import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/question.dart';
import '../models/answer.dart';
import 'database_service.dart';

class ChatService {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  // 사용자 질문을 처리하고 적절한 응답을 생성
  Future<List<ChatMessage>> processUserMessage(String userInput) async {
    final messages = <ChatMessage>[];
    
    // 사용자 메시지 추가
    messages.add(ChatMessage.user(userInput));
    
    try {
      // 1. 유사한 질문 검색
      final similarQuestions = await _searchSimilarQuestions(userInput);
      
      if (similarQuestions.isNotEmpty) {
        // 2. 가장 유사한 질문 선택
        final bestMatch = similarQuestions.first;
        
        // 3. 해당 질문의 답변 확인
        final answers = await _databaseService.getAnswersByQuestionId(bestMatch.id);
        
        if (answers.isNotEmpty) {
          // 답변이 있는 경우 - 답변 제공
          final bestAnswer = answers.where((a) => a.isAccepted).isNotEmpty 
              ? answers.firstWhere((a) => a.isAccepted)
              : answers.first;
              
          messages.add(ChatMessage.assistant(
            _formatAnswerResponse(bestMatch, bestAnswer),
            metadata: {
              'type': 'answer_found',
              'questionId': bestMatch.id,
              'answerId': bestAnswer.id,
            },
          ));
        } else {
          // 답변이 없는 경우 - 질문 작성 제안
          messages.add(ChatMessage.assistant(
            _formatNoAnswerResponse(bestMatch),
            metadata: {
              'type': 'no_answer',
              'questionId': bestMatch.id,
              'suggestedTitle': bestMatch.title,
              'suggestedContent': userInput,
            },
          ));
        }
      } else {
        // 유사한 질문이 없는 경우 - 새 질문 작성 제안
        messages.add(ChatMessage.assistant(
          _formatNewQuestionResponse(userInput),
          metadata: {
            'type': 'new_question',
            'suggestedTitle': _generateQuestionTitle(userInput),
            'suggestedContent': userInput,
          },
        ));
      }
    } catch (e) {
      // 오류 발생 시
      messages.add(ChatMessage.assistant(
        '죄송합니다. 검색 중 오류가 발생했습니다. 다시 시도해주세요.',
        metadata: {'type': 'error', 'error': e.toString()},
      ));
    }
    
    return messages;
  }

  // 유사한 질문 검색 (간단한 키워드 매칭)
  Future<List<Question>> _searchSimilarQuestions(String query) async {
    // 기본 검색
    final searchResults = await _databaseService.searchQuestions(query);
    
    if (searchResults.isNotEmpty) {
      return searchResults;
    }
    
    // 키워드 기반 검색
    final keywords = _extractKeywords(query);
    final allQuestions = await _databaseService.getQuestions();
    
    final scoredQuestions = <MapEntry<Question, double>>[];
    
    for (final question in allQuestions) {
      final score = _calculateSimilarityScore(query, question, keywords);
      if (score > 0.3) { // 임계값 설정
        scoredQuestions.add(MapEntry(question, score));
      }
    }
    
    // 점수순으로 정렬
    scoredQuestions.sort((a, b) => b.value.compareTo(a.value));
    
    return scoredQuestions.take(3).map((e) => e.key).toList();
  }

  // 키워드 추출
  List<String> _extractKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s가-힣]'), '').split(' ');
    
    // 중요한 키워드들
    final importantKeywords = [
      '수강신청', '학사일정', '장학금', '등록금', '기숙사', '도서관', '취업', '인턴십',
      '졸업', '학점', '성적', '시험', '과제', '교수', '강의', '수업', '학과', '전공',
      '복수전공', '부전공', '교환학생', '휴학', '복학', '편입', '대학원'
    ];
    
    for (final word in words) {
      if (word.length > 1) {
        keywords.add(word);
      }
    }
    
    // 중요 키워드 가중치 부여
    for (final keyword in importantKeywords) {
      if (text.contains(keyword)) {
        keywords.add(keyword);
        keywords.add(keyword); // 중복 추가로 가중치 부여
      }
    }
    
    return keywords;
  }

  // 유사도 점수 계산
  double _calculateSimilarityScore(String query, Question question, List<String> keywords) {
    double score = 0.0;
    final questionText = '${question.title} ${question.content}'.toLowerCase();
    
    // 키워드 매칭
    for (final keyword in keywords) {
      if (questionText.contains(keyword)) {
        score += 0.2;
      }
    }
    
    // 카테고리 매칭
    if (query.contains('학사') && question.category == '학사') score += 0.3;
    if (query.contains('장학') && question.category == '장학금') score += 0.3;
    if (query.contains('취업') && question.category == '취업') score += 0.3;
    
    // 공식 자료 가중치
    if (question.isOfficial) score += 0.1;
    
    return score > 1.0 ? 1.0 : score;
  }

  // 답변 발견 시 응답 포맷
  String _formatAnswerResponse(Question question, Answer answer) {
    return '''관련 질문을 찾았습니다! 📋

**질문**: ${question.title}

**답변**: ${answer.content}

${answer.isAIGenerated ? '🤖 AI 생성 답변' : ''}
${answer.isAccepted ? '✅ 채택된 답변' : ''}

더 자세한 정보가 필요하시면 질문 상세 페이지를 확인해보세요.''';
  }

  // 답변 없음 시 응답 포맷
  String _formatNoAnswerResponse(Question question) {
    return '''비슷한 질문을 찾았지만 아직 답변이 없습니다. 😅

**기존 질문**: ${question.title}

이 질문에 대한 답변을 기다리거나, 새로운 질문을 작성하시겠습니까?''';
  }

  // 새 질문 제안 시 응답 포맷
  String _formatNewQuestionResponse(String userInput) {
    return '''관련된 기존 질문을 찾지 못했습니다. 🤔

새로운 질문을 작성해서 다른 학생들과 정보를 공유해보세요!

질문을 작성하시겠습니까?''';
  }

  // 질문 제목 생성
  String _generateQuestionTitle(String content) {
    if (content.length <= 30) {
      return content;
    }
    
    // 간단한 제목 생성 로직
    final sentences = content.split(RegExp(r'[.!?]'));
    if (sentences.isNotEmpty && sentences.first.length <= 50) {
      return sentences.first.trim();
    }
    
    return '${content.substring(0, 27)}...';
  }

  // 새 질문 자동 생성
  Future<Question> createQuestionFromChat(String title, String content, String category) async {
    final question = Question(
      id: _uuid.v4(),
      title: title,
      content: content,
      userId: 'user_001', // 실제 앱에서는 로그인 시스템으로 대체
      userName: '익명',
      createdAt: DateTime.now(),
      category: category,
      tags: _extractKeywords(content).take(3).toList(),
    );
    
    await _databaseService.insertQuestion(question);
    return question;
  }

  // 카테고리 자동 감지
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
} 