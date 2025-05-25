import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/question.dart';
import '../providers/app_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/category_selector.dart';
import 'question_detail_screen.dart';
import 'new_question_screen.dart';

class QuestionsListScreen extends StatefulWidget {
  const QuestionsListScreen({super.key});

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  
  List<Question> _questions = [];
  List<Question> _searchResults = [];
  String _selectedCategory = 'all';
  bool _isLoading = false;
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _databaseService.getQuestions(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _searchQuestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearchMode = true;
      _isLoading = true;
    });

    try {
      final results = await _databaseService.searchQuestions(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _isSearchMode = false;
      _searchResults = [];
    });
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
    final displayQuestions = _isSearchMode ? _searchResults : _questions;
    
    return Scaffold(
      backgroundColor: const Color(0xFF343541),
      appBar: AppBar(
        backgroundColor: const Color(0xFF343541),
        title: const Text(
          '질문 목록',
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (_isSearchMode) {
                setState(() {
                  _isSearchMode = false;
                  _searchResults = [];
                  _textController.clear();
                });
              }
              _loadQuestions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 선택기
          if (!_isSearchMode)
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          
          // 메시지 리스트
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : displayQuestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearchMode ? Icons.search_off : Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearchMode 
                                  ? '검색 결과가 없습니다' 
                                  : '질문을 검색하거나\n새로운 질문을 작성해보세요',
                              textAlign: TextAlign.center,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: displayQuestions.length,
                        itemBuilder: (context, index) {
                          final question = displayQuestions[index];
                          return MessageBubble(
                            question: question,
                            onTap: () => _onQuestionTap(question),
                          );
                        },
                      ),
          ),
          
          // 입력 영역
          ChatInput(
            controller: _textController,
            onSubmitted: _searchQuestions,
            onChanged: (value) {
              if (value.trim().isEmpty && _isSearchMode) {
                setState(() {
                  _isSearchMode = false;
                  _searchResults = [];
                });
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewQuestionScreen(),
            ),
          );
          
          // 새 질문이 작성된 경우 목록 새로고침
          if (result == true) {
            _loadQuestions();
          }
        },
        backgroundColor: const Color(0xFF19C37D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }
} 