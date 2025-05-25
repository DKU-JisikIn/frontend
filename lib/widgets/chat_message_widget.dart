import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타
          _buildAvatar(),
          const SizedBox(width: 12),
          
          // 메시지 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 발신자 이름과 시간
                Row(
                  children: [
                    Text(
                      _getSenderName(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // 메시지 버블
                _buildMessageBubble(context),
                
                // 액션 버튼들
                if (_hasActions()) ...[
                  const SizedBox(height: 12),
                  _buildActionButtons(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getAvatarColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        _getAvatarIcon(),
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBubbleColor(),
        borderRadius: BorderRadius.circular(16),
        border: message.type == MessageType.user 
            ? null 
            : Border.all(color: const Color(0xFF565869), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: message.type == MessageType.user ? Colors.white : Colors.grey[300],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          
          // 상태 표시
          if (message.status == MessageStatus.sending) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '전송 중...',
                  style: TextStyle(
                    color: Colors.grey[400],
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
    
    return Wrap(
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
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF19C37D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  String _getSenderName() {
    switch (message.type) {
      case MessageType.user:
        return '나';
      case MessageType.assistant:
        return '단국대 도우미';
      case MessageType.system:
        return '시스템';
    }
  }

  IconData _getAvatarIcon() {
    switch (message.type) {
      case MessageType.user:
        return Icons.person;
      case MessageType.assistant:
        return Icons.smart_toy;
      case MessageType.system:
        return Icons.info;
    }
  }

  Color _getAvatarColor() {
    switch (message.type) {
      case MessageType.user:
        return const Color(0xFF565869);
      case MessageType.assistant:
        return const Color(0xFF19C37D);
      case MessageType.system:
        return const Color(0xFF9333EA);
    }
  }

  Color _getBubbleColor() {
    switch (message.type) {
      case MessageType.user:
        return const Color(0xFF19C37D);
      case MessageType.assistant:
        return const Color(0xFF444654);
      case MessageType.system:
        return const Color(0xFF40414F);
    }
  }

  bool _hasActions() {
    final metadata = message.metadata;
    if (metadata == null) return false;
    
    final type = metadata['type'] as String?;
    return type == 'answer_found' || type == 'no_answer' || type == 'new_question';
  }
} 