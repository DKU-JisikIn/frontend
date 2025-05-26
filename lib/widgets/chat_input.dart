import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: AppTheme.inputContainerDecoration,
              child: TextField(
                controller: controller,
                enabled: enabled,
                autofocus: false,
                enableInteractiveSelection: true,
                onChanged: onChanged,
                onSubmitted: enabled ? (value) {
                  if (value.trim().isNotEmpty) {
                    onSubmitted(value);
                  }
                } : null,
                style: TextStyle(
                  color: enabled ? AppTheme.primaryTextColor : AppTheme.secondaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: enabled ? '질문을 입력하세요...' : '처리 중입니다...',
                  hintStyle: AppTheme.hintStyle,
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
              color: enabled ? AppTheme.primaryColor : AppTheme.lightTextColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send, 
                color: Colors.white, 
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