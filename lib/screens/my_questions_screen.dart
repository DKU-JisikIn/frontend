import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import 'question_detail_screen.dart';

class MyQuestionsScreen extends StatefulWidget {
  final String? initialFilter; // 'all', 'answered', 'unanswered'
  
  const MyQuestionsScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<MyQuestionsScreen> createState() => _MyQuestionsScreenState();
}

class _MyQuestionsScreenState extends State<MyQuestionsScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  List<Question> _questions = [];
  bool _isLoading = false;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? 'all';
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (!_authService.isLoggedIn) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userId = _authService.currentUserEmail?.split('@')[0] ?? 'test';
      final questions = await _apiService.getUserQuestions(
        userId,
        filter: _currentFilter == 'all' ? null : _currentFilter,
      );
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('질문을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() => _currentFilter = filter);
    _loadQuestions();
  }

  void _onQuestionTap(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(question: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '내가 올린 질문',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 필터 탭
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterTab('all', '전체', _questions.length),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterTab(
                    'answered', 
                    '답변받은 질문', 
                    _questions.where((q) => q.answerCount > 0).length,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterTab(
                    'unanswered', 
                    '답변받지 못한 질문', 
                    _questions.where((q) => q.answerCount == 0).length,
                  ),
                ),
              ],
            ),
          ),
          
          // 질문 목록
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : _questions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadQuestions,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: MessageBubble(
                                question: question,
                                onTap: () => _onQuestionTap(question),
                                showDate: true,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label, int count) {
    final isSelected = _currentFilter == filter;
    
    return GestureDetector(
      onTap: () => _onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_currentFilter) {
      case 'answered':
        message = '답변받은 질문이 없습니다.\n질문을 올려보세요!';
        icon = CupertinoIcons.chat_bubble_2;
        break;
      case 'unanswered':
        message = '답변받지 못한 질문이 없습니다.\n모든 질문에 답변을 받으셨네요!';
        icon = CupertinoIcons.checkmark_circle;
        break;
      default:
        message = '아직 올린 질문이 없습니다.\n첫 질문을 올려보세요!';
        icon = CupertinoIcons.question_circle;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.hintTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 