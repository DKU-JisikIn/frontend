import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import '../widgets/period_filter.dart';
import 'question_detail_screen.dart';

class FrequentQuestionsScreen extends StatefulWidget {
  const FrequentQuestionsScreen({super.key});

  @override
  State<FrequentQuestionsScreen> createState() => _FrequentQuestionsScreenState();
}

class _FrequentQuestionsScreenState extends State<FrequentQuestionsScreen> {
  final ApiService _apiService = ApiService();
  List<Question> _questions = [];
  bool _isLoading = false;
  String _selectedPeriod = '전체기간';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _apiService.getFrequentlyAskedQuestions(
        limit: 50, 
        period: _selectedPeriod,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '자주 받은 질문',
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
          // 기간 필터
          PeriodFilter(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: _onPeriodChanged,
          ),
          
          // 질문 리스트
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadQuestions,
              color: AppTheme.primaryColor,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.question_circle,
                                size: 64,
                                color: AppTheme.hintTextColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedPeriod == '일주일' 
                                    ? '최근 일주일간 자주 받은 질문이 없습니다'
                                    : '자주 받은 질문이 없습니다',
                                style: TextStyle(
                                  color: AppTheme.hintTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: MessageBubble(
                                question: question,
                                onTap: () => _onQuestionTap(question),
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
} 