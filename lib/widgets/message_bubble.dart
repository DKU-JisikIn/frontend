import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';

class MessageBubble extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;
  final bool showDate; // 날짜 표시 여부 (상세 페이지용)
  final bool showContent; // 내용 표시 여부 (상세 페이지용)

  const MessageBubble({
    super.key,
    required this.question,
    required this.onTap,
    this.showDate = false,
    this.showContent = false,
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
              color: AppTheme.borderColor,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 정보 (카테고리와 날짜)
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
                  // 상세 페이지에서만 날짜 표시 (우측 상단)
                  if (showDate)
                    Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(question.createdAt),
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
                maxLines: showContent ? null : 3,
                overflow: showContent ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              
              // 내용 (상세 페이지에서만 표시)
              if (showContent) ...[
                const SizedBox(height: 12),
                Text(
                  question.content,
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // 하단 정보 (조회수와 댓글 수를 우측 하단에 한 줄로)
              Row(
                children: [
                  const Spacer(),
                  // 조회수
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
                  const SizedBox(width: 12),
                  // 댓글 수
                  Icon(
                    CupertinoIcons.chat_bubble,
                    size: 16,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    question.answerCount.toString(),
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 