import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
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
        elevation: 0,
        title: Text(
          '관련 질문',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: relatedQuestions.length,
        itemBuilder: (context, index) {
          final question = relatedQuestions[index];
          return MessageBubble(
            question: Question(
              id: question['id'].toString(),
              title: question['title'],
              content: question['content'],
              category: '기타',
              userId: '',
              userName: '',
              createdAt: DateTime.now(),
              answerCount: 0,
              isAnswered: false,
              isOfficial: false,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionDetailScreen(
                    question: Question(
                      id: question['id'].toString(),
                      title: question['title'],
                      content: question['content'],
                      category: '기타',
                      userId: '',
                      userName: '',
                      createdAt: DateTime.now(),
                      answerCount: 0,
                      isAnswered: false,
                      isOfficial: false,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 