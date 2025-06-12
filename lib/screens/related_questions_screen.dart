import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import 'question_detail_screen.dart';

class RelatedQuestionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> relatedQuestions;
  final String searchQuery;

  const RelatedQuestionsScreen({
    super.key,
    required this.relatedQuestions,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          '관련 질문',
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
          // 검색어 표시
          if (searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검색어',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"$searchQuery"',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // 관련 질문 개수 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.question_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '관련 질문 ${relatedQuestions.length}개',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 관련 질문 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: relatedQuestions.length,
              itemBuilder: (context, index) {
                final questionData = relatedQuestions[index];
                return _buildQuestionCard(context, questionData, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> questionData, int index) {
    final answerCount = questionData['answerCount'] as int? ?? 0;
    final viewCount = questionData['viewCount'] as int? ?? 0;
    final category = questionData['category'] as String? ?? '기타';
    final title = questionData['title'] as String? ?? '제목 없음';
    final id = questionData['id'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // 질문 상세 페이지로 이동 - 임시 Question 객체 생성
            final question = Question(
              id: id,
              title: title,
              content: '', // 내용은 상세 페이지에서 로드
              userId: '',
              userName: '',
              createdAt: DateTime.now(),
              category: category,
              isOfficial: false,
              viewCount: viewCount,
              answerCount: answerCount,
              tags: [],
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionDetailScreen(question: question),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 정보 (카테고리만)
                Row(
                  children: [
                    // 카테고리
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 질문 제목
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // 하단 정보 (답변 수, 조회 수)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_text,
                      color: AppTheme.secondaryTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '답변 $answerCount',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      CupertinoIcons.eye,
                      color: AppTheme.secondaryTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '조회 $viewCount',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppTheme.secondaryTextColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 