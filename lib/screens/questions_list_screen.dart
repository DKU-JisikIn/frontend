import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import '../widgets/category_selector.dart';
import 'question_detail_screen.dart';

class QuestionsListScreen extends StatefulWidget {
  const QuestionsListScreen({super.key});

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Question> _allQuestions = [];
  List<Question> _filteredQuestions = [];
  String _selectedCategory = '전체';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _apiService.getQuestions();
      setState(() {
        _allQuestions = questions;
        _filterQuestions();
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

  void _filterQuestions() {
    if (_selectedCategory == '전체') {
      _filteredQuestions = _allQuestions;
    } else {
      _filteredQuestions = _allQuestions
          .where((question) => question.category == _selectedCategory)
          .toList();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _filterQuestions();
    });
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
        title: Text(
          '질문 목록',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 카테고리 선택기
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategoryChanged: _onCategoryChanged,
          ),
          
          // 메시지 리스트
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadQuestions,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.backgroundColor,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _filteredQuestions.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.chat_bubble,
                                    size: 64,
                                    color: AppTheme.lightTextColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedCategory == '전체' 
                                        ? '등록된 질문이 없습니다'
                                        : '${_selectedCategory} 카테고리에\n등록된 질문이 없습니다',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final question = _filteredQuestions[index];
                            return MessageBubble(
                              question: question,
                              onTap: () => _onQuestionTap(question),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 