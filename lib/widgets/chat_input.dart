import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(String)? onChanged;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
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
                onChanged: onChanged,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onSubmitted(value);
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '질문을 입력하세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF19C37D),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSubmitted(text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 