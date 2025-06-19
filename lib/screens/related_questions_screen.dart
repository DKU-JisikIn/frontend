import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import '../models/answer.dart';
import 'question_detail_screen.dart';

class RelatedQuestionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> relatedQuestions;

  const RelatedQuestionsScreen({
    super.key,
    required this.relatedQuestions,
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: relatedQuestions.length,
        itemBuilder: (context, index) {
          final question = relatedQuestions[index];
          final isVOC = question['source'] == 'VOC';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isVOC ? Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // 답변 정보 추출
                  List<Answer> answers = [];
                  final answerText = question['answer'] ?? question['content'];
                  
                  // 질문과 답변이 섞여있는 경우 파싱
                  if (answerText.contains('답변:') || answerText.contains('Answer:')) {
                    final parts = answerText.split(RegExp(r'답변[:：]|Answer[:：]'));
                    if (parts.length > 1) {
                      final answerContent = parts[1].trim();
                      if (answerContent.isNotEmpty) {
                        answers.add(Answer(
                          id: 'related_answer_$index',
                          questionId: question['id'].toString(),
                          content: answerContent,
                          userId: 'system',
                          userName: 'AI 어시스턴트',
                          createdAt: DateTime.now(),
                          likeCount: 0,
                          isLiked: false,
                          isAccepted: true,
                        ));
                      }
                    }
                  } else if (question['answer'] != null && question['answer'].toString().trim().isNotEmpty) {
                    // 별도 답변 필드가 있는 경우
                    answers.add(Answer(
                      id: 'related_answer_$index',
                      questionId: question['id'].toString(),
                      content: question['answer'].toString().trim(),
                      userId: 'system',
                      userName: 'AI 어시스턴트',
                      createdAt: DateTime.now(),
                      likeCount: 0,
                      isLiked: false,
                      isAccepted: true,
                    ));
                  }

                  // 질문 내용에서 답변 부분 제거
                  String questionContent = question['content'] ?? question['title'] ?? '';
                  if (questionContent.contains('답변:') || questionContent.contains('Answer:')) {
                    final parts = questionContent.split(RegExp(r'답변[:：]|Answer[:：]'));
                    questionContent = parts[0].replaceAll('질문:', '').replaceAll('Question:', '').trim();
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionDetailScreen(
                        question: Question(
                          id: question['id'].toString(),
                          title: question['title'] ?? questionContent,
                          content: questionContent,
                          category: question['category'] ?? '기타',
                          userId: question['userId'] ?? '',
                          userName: question['userName'] ?? '익명',
                          createdAt: DateTime.now(),
                          answerCount: answers.length,
                          isAnswered: answers.isNotEmpty,
                          isOfficial: false,
                        ),
                        initialAnswers: answers, // 답변 데이터 전달
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'VOC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        question['title'] ?? '',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        question['content'] ?? '',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            CupertinoIcons.arrow_right,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 