import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';
import '../../models/question.dart';
import '../../services/api_service.dart';
import '../../screens/my_questions_screen.dart';
import '../../models/top_answerer.dart';

class UserStatsWidget extends StatelessWidget {
  final Map<String, dynamic> userQuestionStats;
  final VoidCallback onRefresh;

  const UserStatsWidget({
    super.key,
    required this.userQuestionStats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.person_crop_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '내 질문 현황',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.iosCardDecoration,
          child: Row(
            children: [
              Expanded(
                child: _buildUserStatItem(
                  context,
                  '올린 질문',
                  (userQuestionStats['total'] as int?) ?? 0,
                  CupertinoIcons.chat_bubble_text,
                  () => _navigateToMyQuestions(context, 'all'),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildUserStatItem(
                  context,
                  '답변받은 질문',
                  (userQuestionStats['answered'] as int?) ?? 0,
                  CupertinoIcons.checkmark_circle,
                  () => _navigateToMyQuestions(context, 'answered'),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildUserStatItem(
                  context,
                  '답변 대기중',
                  (userQuestionStats['unanswered'] as int?) ?? 0,
                  CupertinoIcons.clock,
                  () => _navigateToMyQuestions(context, 'unanswered'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatItem(BuildContext context, String label, int count, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMyQuestions(BuildContext context, String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyQuestionsScreen(initialFilter: filter),
      ),
    );
  }
}

class TopAnswerersWidget extends StatelessWidget {
  final List<TopAnswerer> topAnswerers;

  const TopAnswerersWidget({
    super.key,
    required this.topAnswerers,
  });

  @override
  Widget build(BuildContext context) {
    if (topAnswerers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.star_fill,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '우수 답변자',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.iosCardDecoration,
          child: Column(
            children: [
              for (int i = 0; i < 3 && i < topAnswerers.length; i++)
                _buildTopAnswererItem(topAnswerers[i], i == 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopAnswererItem(TopAnswerer topAnswerer, bool isLast) {
    Color rankColor;
    
    switch (topAnswerer.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        break;
      default:
        rankColor = AppTheme.secondaryTextColor;
    }

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${topAnswerer.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  topAnswerer.userName.isNotEmpty ? topAnswerer.userName[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topAnswerer.userName,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '답변 ${topAnswerer.answerCount}개',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${topAnswerer.score}점',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: AppTheme.borderColor,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class TodayStatsWidget extends StatelessWidget {
  final int todayQuestionCount;
  final int todayAnswerCount;

  const TodayStatsWidget({
    super.key,
    required this.todayQuestionCount,
    required this.todayAnswerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 질문과 답변',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.iosCardDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '질문 수',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$todayQuestionCount',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Column(
                children: [
                  Text(
                    '답변 수',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$todayAnswerCount',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TotalAnswersWidget extends StatelessWidget {
  final int totalAnswerCount;

  const TotalAnswersWidget({
    super.key,
    required this.totalAnswerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.checkmark_seal,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '누적 답변 수',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.iosCardDecoration,
          child: Center(
            child: Text(
              '$totalAnswerCount',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 