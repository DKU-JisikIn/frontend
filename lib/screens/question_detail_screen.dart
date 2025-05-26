import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../widgets/chat_input.dart';

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
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Answer> _answers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

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
        _answers = answers;
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

  Future<void> _submitAnswer(String content) async {
    if (content.trim().isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final answer = Answer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: widget.question.id,
        content: content.trim(),
        userId: 'user_001', // TODO: 실제 사용자 ID로 대체
        userName: '익명',
        createdAt: DateTime.now(),
      );

      await _apiService.createAnswer(answer);
      
      setState(() {
        _answers.add(answer);
        _isSubmitting = false;
      });

      _answerController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답변이 등록되었습니다!')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('답변 등록 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          '질문 상세',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                    const Center(
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
                              Icons.chat_bubble_outline,
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
            onSubmitted: _submitAnswer,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.question.isOfficial ? AppTheme.primaryColor : AppTheme.borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보
          Row(
            children: [
              if (widget.question.isOfficial)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '공식',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (widget.question.isOfficial) const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.question.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.remove_red_eye,
                size: 16,
                color: AppTheme.lightTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                widget.question.viewCount.toString(),
                style: TextStyle(
                  color: AppTheme.lightTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 제목
          Text(
            widget.question.title,
            style: AppTheme.headingStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          
          // 내용
          Text(
            widget.question.content,
            style: AppTheme.bodyStyle.copyWith(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 16),
          
          // 작성자 정보
          Row(
            children: [
              Text(
                widget.question.userName,
                style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(widget.question.createdAt),
                style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
          
          // 태그
          if (widget.question.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.question.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerCard(Answer answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: answer.isAccepted 
            ? Border.all(color: AppTheme.primaryColor, width: 1.5)
            : Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 답변자 정보와 상태
          Row(
            children: [
              if (answer.isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '채택',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (answer.isAIGenerated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.only(left: answer.isAccepted ? 8 : 0),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                answer.userName,
                style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MM/dd HH:mm').format(answer.createdAt),
                style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 답변 내용
          Text(
            answer.content,
            style: AppTheme.bodyStyle.copyWith(height: 1.4),
          ),
          
          // 좋아요 버튼
          if (answer.likeCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: AppTheme.lightTextColor,
                ),
                const SizedBox(width: 4),
                Text(
                  answer.likeCount.toString(),
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
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