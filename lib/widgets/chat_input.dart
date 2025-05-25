import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(String)? onChanged;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF40414F),
        border: Border(
          top: BorderSide(color: Color(0xFF565869), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF40414F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF565869)),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                onChanged: onChanged,
                onSubmitted: enabled ? (value) {
                  if (value.trim().isNotEmpty) {
                    onSubmitted(value);
                  }
                } : null,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.grey[600],
                ),
                decoration: InputDecoration(
                  hintText: enabled ? '질문을 입력하세요...' : '처리 중입니다...',
                  hintStyle: TextStyle(
                    color: enabled ? Colors.grey : Colors.grey[700],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFF19C37D) : Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send, 
                color: enabled ? Colors.white : Colors.grey[500], 
                size: 20,
              ),
              onPressed: enabled ? () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSubmitted(text);
                }
              } : null,
            ),
          ),
        ],
      ),
    );
  }
} 