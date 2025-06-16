import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../widgets/chat_input.dart';
import 'related_questions_screen.dart';
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
        _messages.addAll(aiMessages); // addAll 사용
        _isProcessing = false;
      });

      // AI 답변 추가 후 스크롤
      await _scrollToBottomSmooth();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage.assistant(
          '연결 필요',
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

  void _handleViewRelatedQuestions(ChatMessage message) {
    final metadata = message.metadata;
    if (metadata == null) return;

    final relatedQuestions = metadata['relatedQuestions'] as List?;
    if (relatedQuestions != null && relatedQuestions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RelatedQuestionsScreen(
            relatedQuestions: relatedQuestions.cast<Map<String, dynamic>>(),
          ),
        ),
      );
    }
  }

  void _handleQuestionCreate(ChatMessage message) async {
    final metadata = message.metadata;
    if (metadata == null) return;

    final actions = metadata['actions'] as Map<String, dynamic>?;
    if (actions == null) return;

    final suggestedTitle = actions['suggestedTitle'] as String? ?? '';
    final suggestedContent = actions['suggestedContent'] as String? ?? '';

    // 질문 미리보기를 채팅 메시지로 표시
    setState(() {
      _messages.add(ChatMessage.assistant(
        '다음과 같이 질문을 작성할까요?',
        metadata: {
          'type': 'question_preview',
          'suggestedTitle': suggestedTitle,
          'suggestedContent': suggestedContent,
        },
      ));
    });

    await _scrollToBottomSmooth();
  }

  void _handleRelatedQuestionsTap(List<Map<String, dynamic>> relatedQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RelatedQuestionsScreen(
          relatedQuestions: relatedQuestions,
        ),
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
      children: [
        // 메시지 말풍선
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMessageBubble(message),
        ),
          // 관련 질문 버튼 (말풍선 바로 아래에 위치)
        if (!message.isUser) ..._buildActionButtons(message),
      ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isUser) {
      return _buildUserMessage(message);
    } else {
      return _buildBotMessage(message);
    }
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: AppTheme.userMessageDecoration,
        padding: const EdgeInsets.all(16),
        child: Text(
          message.content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              if (message.metadata?['type'] == 'question_preview') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.title,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '제목',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.metadata?['suggestedTitle'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '내용',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.metadata?['suggestedContent'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryTextColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (message.relatedQuestions != null && message.relatedQuestions!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  '관련 질문',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...message.relatedQuestions!.map((question) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _handleRelatedQuestionsTap(message.relatedQuestions!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              question['title'] ?? '',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(ChatMessage message) {
    final metadata = message.metadata;
    if (metadata == null) {
      print('DEBUG: metadata is null');
      return [];
    }

    print('DEBUG: metadata = $metadata');
    final widgets = <Widget>[];
    final actions = metadata['actions'] as Map<String, dynamic>?;
    print('DEBUG: actions = $actions');
    
    final canCreateQuestion = actions != null && (actions['canCreateQuestion'] == true || actions['canCreateQuestion'] == 'true');
    final hasDirectAnswer = actions != null && (actions['hasDirectAnswer'] == true || actions['hasDirectAnswer'] == 'true');
    print('DEBUG: canCreateQuestion = $canCreateQuestion, hasDirectAnswer = $hasDirectAnswer');

    // hasDirectAnswer가 true인 경우 버튼 표시
    if (hasDirectAnswer) {
      print('DEBUG: Adding related questions button');
      widgets.add(
        Container(
          margin: const EdgeInsets.only(left: 16, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: ElevatedButton.icon(
                onPressed: () => _handleViewRelatedQuestions(message),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                icon: Icon(
                  CupertinoIcons.arrow_right_circle,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  '관련질문 보러가기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // canCreateQuestion이 true일 때만 질문 작성하기 버튼 표시
    if (canCreateQuestion) {
      print('DEBUG: Adding create question button');
      widgets.add(
        Container(
          margin: const EdgeInsets.only(left: 16, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: ElevatedButton.icon(
                onPressed: () => _handleQuestionCreate(message),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  '질문 작성하기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 질문 미리보기 메시지인 경우 질문 올리기 버튼 표시
    if (metadata['type'] == 'question_preview') {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(left: 16, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
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
                        '연결 필요',
                        metadata: {'type': 'error'},
                      ));
                    });
                    
                    await _scrollToBottomSmooth();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  '질문 올리기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
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
                  return _buildMessageWidget(message, index);
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