import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({
    super.key,
    required this.question,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Answer> _answers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  
  // 더블탭 감지를 위한 변수들
  Map<String, DateTime> _lastTapTimes = {};

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    setState(() => _isLoading = true);
    try {
      final answers = await _apiService.getAnswersByQuestionId(widget.question.id);
      setState(() {
        // 모든 답변의 좋아요 상태를 기본적으로 꺼진 상태로 설정
        final answersWithDefaultLike = answers.map((answer) => 
          answer.copyWith(isLiked: false)
        ).toList();
        
        // 채택된 답변을 맨 위로 정렬
        _answers = _sortAnswers(answersWithDefaultLike);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답변을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 답변 정렬: 채택된 답변이 맨 위, 나머지는 생성일 순
  List<Answer> _sortAnswers(List<Answer> answers) {
    final acceptedAnswers = answers.where((a) => a.isAccepted).toList();
    final otherAnswers = answers.where((a) => !a.isAccepted).toList();
    
    // 채택된 답변을 맨 위에, 나머지는 생성일 순으로 정렬
    otherAnswers.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return [...acceptedAnswers, ...otherAnswers];
  }

  // 답변 채택 처리
  Future<void> _acceptAnswer(Answer answer) async {
    // 질문 작성자만 채택 가능
    final currentUserId = _authService.currentUserEmail?.split('@')[0] ?? 'test';
    if (widget.question.userId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('질문 작성자만 답변을 채택할 수 있습니다.')),
      );
      return;
    }

    // 이미 채택된 답변인지 확인
    if (answer.isAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 채택된 답변입니다.')),
      );
      return;
    }

    try {
      // API 호출
      final acceptedAnswer = await _apiService.acceptAnswer(answer.id, widget.question.id);
      
      // 답변 목록 업데이트
      setState(() {
        final answerIndex = _answers.indexWhere((a) => a.id == answer.id);
        if (answerIndex != -1) {
          // 다른 답변들의 채택 상태 해제
          for (int i = 0; i < _answers.length; i++) {
            if (_answers[i].isAccepted) {
              _answers[i] = _answers[i].copyWith(isAccepted: false);
            }
          }
          
          // 선택된 답변을 채택 상태로 변경
          _answers[answerIndex] = acceptedAnswer;
          
          // 답변 재정렬
          _answers = _sortAnswers(_answers);
        }
      });

      // 채택 완료 토스트 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('답변이 채택되었습니다!'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답변 채택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 답변 좋아요 처리
  Future<void> _toggleAnswerLike(Answer answer) async {
    // 로컬 UI 상태만 업데이트 (API 호출 없음)
    setState(() {
      final answerIndex = _answers.indexWhere((a) => a.id == answer.id);
      if (answerIndex != -1) {
        final currentAnswer = _answers[answerIndex];
        // 좋아요 상태와 카운트를 토글
        _answers[answerIndex] = currentAnswer.copyWith(
          isLiked: !currentAnswer.isLiked,
          likeCount: currentAnswer.isLiked 
            ? currentAnswer.likeCount - 1 
            : currentAnswer.likeCount + 1,
        );
      }
    });

    // 햅틱 피드백 (옵션)
    // HapticFeedback.lightImpact(); // 필요 시 import 'package:flutter/services.dart';
  }

  // 더블탭 감지
  void _handleAnswerTap(Answer answer) {
    final now = DateTime.now();
    final lastTapTime = _lastTapTimes[answer.id];
    
    if (lastTapTime != null && now.difference(lastTapTime).inMilliseconds < 500) {
      // 더블탭 감지됨 - 답변 채택 시도
      _acceptAnswer(answer);
      _lastTapTimes.remove(answer.id); // 더블탭 후 초기화
    } else {
      // 첫 번째 탭
      _lastTapTimes[answer.id] = now;
    }
  }

  Future<void> _submitAnswer(String text) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answer = await _apiService.createAnswer(
        widget.question.id,
        text.trim(),
      );
      
      setState(() {
        _answers.add(answer);
        _answerController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답변이 등록되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답변 등록에 실패했습니다: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          '질문 상세',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 질문 카드
                  _buildQuestionCard(),
                  const SizedBox(height: 24),
                  
                  // 답변 섹션 헤더
                  Row(
                    children: [
                      Text(
                        '답변',
                        style: AppTheme.headingStyle,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _answers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 답변 리스트
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  else if (_answers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.chat_bubble,
                              size: 48,
                              color: AppTheme.lightTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 답변이 없습니다.\n첫 번째 답변을 작성해보세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _answers.map((answer) => _buildAnswerCard(answer)).toList(),
                    ),
                ],
              ),
            ),
          ),
          
          // 답변 입력 영역
          ChatInput(
            controller: _answerController,
            onSubmitted: (text) => _submitAnswer(text),
            hintText: '답변을 입력하세요...',
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return MessageBubble(
      question: widget.question,
      onTap: () {}, // 상세 페이지에서는 탭 기능 불필요
      showDate: true, // 날짜를 우측 상단에 표시
      showContent: true, // 내용을 표시
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    // 질문 작성자인지 확인
    final currentUserId = _authService.currentUserEmail?.split('@')[0] ?? 'test';
    final isQuestionAuthor = widget.question.userId == currentUserId;
    
    return GestureDetector(
      onTap: () => _handleAnswerTap(answer),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: answer.isAccepted ? AppTheme.primaryColor : AppTheme.borderColor,
            width: answer.isAccepted ? 2.0 : 1.0,
          ),
          // 채택된 답변에 그림자 효과 추가
          boxShadow: answer.isAccepted ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 영역 (사용자 아이디, AI 태그, 채택 배지)
            Row(
              children: [
                // 사용자 아이디 (좌측 상단)
                Text(
                  answer.userName,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                
                // 사용자 레벨 아이콘
                _buildUserLevelIcon(answer.userLevel),
                const SizedBox(width: 6),
                
                // 인증 배지 (인증된 사용자인 경우)
                if (answer.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_seal_fill,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '인증',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // AI 태그 (있는 경우) - 현재 Answer 모델에서 주석 처리됨
                // if (answer.isAIGenerated) ...[
                //   const SizedBox(width: 6),
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: AppTheme.secondaryColor,
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: const Text(
                //       'AI',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 11,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ],
                
                const Spacer(),
                
                // 채택 배지 (채택된 답변인 경우)
                if (answer.isAccepted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '채택됨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // 소속 정보 (있는 경우)
            if (answer.department != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.building_2_fill,
                    size: 12,
                    color: AppTheme.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    answer.department!,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // 답변 내용
            Text(
              answer.content,
              style: AppTheme.bodyStyle.copyWith(height: 1.4),
            ),
            
            const SizedBox(height: 12),
            
            // 하단 영역 (좋아요, 날짜, 채택 안내)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 좋아요 버튼 (좌측) - 항상 표시하고 클릭 가능하게 수정
                    GestureDetector(
                      onTap: () => _toggleAnswerLike(answer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: answer.isLiked 
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: answer.isLiked 
                                ? AppTheme.primaryColor.withOpacity(0.3)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                answer.isLiked 
                                    ? CupertinoIcons.heart_fill 
                                    : CupertinoIcons.heart,
                                key: ValueKey(answer.isLiked),
                                size: 16,
                                color: answer.isLiked 
                                    ? AppTheme.primaryColor 
                                    : AppTheme.lightTextColor,
                              ),
                            ),
                            if (answer.likeCount > 0) ...[
                              const SizedBox(width: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  answer.likeCount.toString(),
                                  key: ValueKey(answer.likeCount),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: answer.isLiked 
                                        ? AppTheme.primaryColor 
                                        : AppTheme.secondaryTextColor,
                                    fontWeight: answer.isLiked 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 날짜 (우측)
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(answer.createdAt),
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                
                // 채택 안내 메시지 (질문 작성자이고 아직 채택되지 않은 답변인 경우)
                if (isQuestionAuthor && !answer.isAccepted) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💡 이 답변이 도움이 되었다면 두 번 빠르게 탭하여 채택해보세요!',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLevelIcon(int userLevel) {
    // 사용자 레벨에 따른 아이콘과 색상 결정
    IconData icon;
    Color color;
    
    switch (userLevel) {
      case 5:
        icon = CupertinoIcons.star_fill;
        color = const Color(0xFFFFD700); // 금색
        break;
      case 4:
        icon = CupertinoIcons.star_fill;
        color = const Color(0xFFC0C0C0); // 은색
        break;
      case 3:
        icon = CupertinoIcons.star_fill;
        color = const Color(0xFFCD7F32); // 동색
        break;
      case 2:
        icon = CupertinoIcons.star;
        color = AppTheme.primaryColor;
        break;
      case 1:
      default:
        icon = CupertinoIcons.circle;
        color = AppTheme.secondaryTextColor;
        break;
    }
    
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: userLevel >= 2 
            ? Icon(
                icon,
                size: 10,
                color: userLevel >= 3 ? Colors.white : color,
              )
            : Text(
                userLevel.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 