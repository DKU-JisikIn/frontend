import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onQuestionCreate;
  final VoidCallback? onViewQuestion;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onQuestionCreate,
    this.onViewQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: EdgeInsets.only(
        top: isUser ? 16 : 8,
        bottom: isUser ? 8 : 20,
        left: 16,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 메시지일 때만 왼쪽에 표시
          if (!isUser) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageBubble(context, isUser),
                  if (_hasActions()) ...[
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                  ],
                ],
              ),
            ),
          ],
          
          // 사용자 메시지일 때만 오른쪽에 표시
          if (isUser) ...[
            Flexible(
              child: _buildMessageBubble(context, isUser),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isUser) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isUser ? AppTheme.userMessageDecoration : AppTheme.assistantMessageDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: isUser ? Colors.white : AppTheme.primaryTextColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          
          // 전송 중 상태 표시 (사용자 메시지만)
          if (isUser && message.status == MessageStatus.sending) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '전송 중...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final metadata = message.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final type = metadata['type'] as String?;
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (type == 'answer_found' && onViewQuestion != null)
            _buildActionButton(
              '질문 상세보기',
              Icons.open_in_new,
              onViewQuestion!,
            ),
          
          if ((type == 'no_answer' || type == 'new_question') && onQuestionCreate != null)
            _buildActionButton(
              '질문 작성하기',
              Icons.edit,
              onQuestionCreate!,
            ),
          
          if (type == 'no_answer' && onViewQuestion != null)
            _buildActionButton(
              '기존 질문 보기',
              Icons.visibility,
              onViewQuestion!,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    );
  }

  bool _hasActions() {
    final metadata = message.metadata;
    if (metadata == null) return false;
    
    final type = metadata['type'] as String?;
    return type == 'answer_found' || type == 'no_answer' || type == 'new_question';
  }
} 