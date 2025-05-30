import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/chat_input.dart';
import 'question_detail_screen.dart';
import 'new_question_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  
  const ChatScreen({super.key, this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 초기 인삿말 제거
    
    // 초기 검색어가 있으면 자동으로 처리
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    // 사용자 메시지를 먼저 화면에 표시
    final userMessage = ChatMessage.user(text.trim());
    setState(() {
      _messages.add(userMessage);
      _isProcessing = true;
    });

    _textController.clear();
    
    // 사용자 메시지 추가 후 즉시 스크롤
    await _scrollToBottomSmooth();

    try {
      // API 서비스로 메시지 처리 (AI 답변만)
      final aiMessages = await _apiService.processChatMessage(text.trim());
      
      setState(() {
        _messages.addAll(aiMessages);
        _isProcessing = false;
      });

      // AI 답변 추가 후 스크롤
      await _scrollToBottomSmooth();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage.assistant(
          '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
          metadata: {'type': 'error'},
        ));
        _isProcessing = false;
      });
      
      await _scrollToBottomSmooth();
    }
  }

  Future<void> _scrollToBottomSmooth() async {
    // 약간의 지연을 두어 UI 업데이트가 완료된 후 스크롤
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), // 더 부드러운 애니메이션
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuestionCreate(ChatMessage message) async {
    final metadata = message.metadata;
    if (metadata == null) return;

    final suggestedTitle = metadata['suggestedTitle'] as String? ?? '';
    final suggestedContent = metadata['suggestedContent'] as String? ?? '';
    final category = _apiService.detectCategory(suggestedContent);

    try {
      // 자동으로 질문 생성
      final question = await _apiService.createQuestionFromChat(
        suggestedTitle,
        suggestedContent,
        category,
      );

      // 성공 메시지 추가
      setState(() {
        _messages.add(ChatMessage.assistant(
          '질문이 성공적으로 작성되었습니다! ✅\n\n**제목**: ${question.title}\n**카테고리**: ${question.category}\n\n다른 학생들의 답변을 기다려보세요.',
          metadata: {
            'type': 'question_created',
            'questionId': question.id,
          },
        ));
      });

      await _scrollToBottomSmooth();
    } catch (e) {
      // 오류 메시지 추가
      setState(() {
        _messages.add(ChatMessage.assistant(
          '질문 작성 중 오류가 발생했습니다. 직접 질문 작성 페이지에서 시도해주세요.',
          metadata: {'type': 'error'},
        ));
      });
      
      await _scrollToBottomSmooth();
    }
  }

  void _handleViewQuestion(ChatMessage message) {
    final metadata = message.metadata;
    if (metadata == null) return;

    final questionId = metadata['questionId'] as String?;
    if (questionId != null) {
      // 질문 상세 페이지로 이동하는 로직
      // 실제 구현에서는 Question 객체를 가져와서 전달해야 함
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('질문 ID: $questionId 상세 페이지로 이동')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          '검색 결과',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () async {
            // 텍스트 필드 포커스 완전히 해제
            _textController.clear();
            FocusManager.instance.primaryFocus?.unfocus();
            
            // 키보드가 완전히 숨겨질 때까지 대기
            await Future.delayed(const Duration(milliseconds: 200));
            
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        // 화면 터치 시 키보드 숨기기
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // 채팅 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatMessageWidget(
                    message: message,
                    onQuestionCreate: () => _handleQuestionCreate(message),
                    onViewQuestion: () => _handleViewQuestion(message),
                  );
                },
              ),
            ),

            // 처리 중 표시
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '답변을 찾고 있습니다...',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // 입력 영역
            ChatInput(
              controller: _textController,
              onSubmitted: _sendMessage,
              enabled: !_isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // dispose 시에는 context 접근하지 않음 (위젯이 이미 비활성화됨)
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 