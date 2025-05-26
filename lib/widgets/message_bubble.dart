import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';

class MessageBubble extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const MessageBubble({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: question.isOfficial ? AppTheme.primaryColor : AppTheme.borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 카테고리
              Row(
                children: [
                  if (question.isOfficial)
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
                  if (question.isOfficial) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.eye,
                    size: 16,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    question.viewCount.toString(),
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 제목
              Text(
                question.title,
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 하단 정보 (답변 수만)
              Row(
                children: [
                  const Spacer(),
                  if (question.answerCount > 0) ...[
                    Icon(
                      CupertinoIcons.chat_bubble,
                      size: 16,
                      color: AppTheme.lightTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      question.answerCount.toString(),
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ],
              ),
              
              // 태그
              if (question.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: question.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTheme.bodyStyle.copyWith(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 