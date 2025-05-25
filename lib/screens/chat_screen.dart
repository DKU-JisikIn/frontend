import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
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
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    
    // 초기 검색어가 있으면 자동으로 처리
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialQuery!);
      });
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage.assistant(
      '안녕하세요! 단국대 도우미입니다. 🎓\n\n궁금한 점이 있으시면 언제든지 질문해주세요!\n\n예시:\n• "올해 수강신청은 언제부터야?"\n• "장학금 신청 방법 알려줘"\n• "도서관 이용시간이 어떻게 돼?"',
      metadata: {'type': 'welcome'},
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 채팅 서비스로 메시지 처리
      final newMessages = await _chatService.processUserMessage(text.trim());
      
      setState(() {
        _messages.addAll(newMessages);
        _isProcessing = false;
      });

      _textController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage.assistant(
          '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
          metadata: {'type': 'error'},
        ));
        _isProcessing = false;
      });
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
    final category = _chatService.detectCategory(suggestedContent);

    try {
      // 자동으로 질문 생성
      final question = await _chatService.createQuestionFromChat(
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

      _scrollToBottom();
    } catch (e) {
      // 오류 메시지 추가
      setState(() {
        _messages.add(ChatMessage.assistant(
          '질문 작성 중 오류가 발생했습니다. 직접 질문 작성 페이지에서 시도해주세요.',
          metadata: {'type': 'error'},
        ));
      });
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
      backgroundColor: const Color(0xFF343541),
      appBar: AppBar(
        backgroundColor: const Color(0xFF343541),
        title: const Text(
          '단국대 도우미 채팅',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // 채팅 메시지 리스트
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '대화를 시작해보세요!',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19C37D)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '답변을 찾고 있습니다...',
                    style: TextStyle(
                      color: Colors.grey[400],
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
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 