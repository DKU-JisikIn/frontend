import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import 'questions_list_screen.dart';
import 'question_detail_screen.dart';
import 'new_question_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Question> _popularQuestions = [];
  List<Question> _frequentQuestions = [];
  List<Question> _officialQuestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final popularQuestions = await _apiService.getPopularQuestions(limit: 3);
      final frequentQuestions = await _apiService.getFrequentlyAskedQuestions(limit: 3);
      final officialQuestions = await _apiService.getOfficialQuestions(limit: 3);
      
      setState(() {
        _popularQuestions = popularQuestions;
        _frequentQuestions = frequentQuestions;
        _officialQuestions = officialQuestions;
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

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // 채팅 화면으로 이동하면서 검색어 전달
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(initialQuery: query),
        ),
      );
      _searchController.clear();
    }
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
      backgroundColor: const Color(0xFF343541),
      appBar: AppBar(
        backgroundColor: const Color(0xFF343541),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          '단국대 도우미',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // 사용자 정보 화면으로 이동 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자 정보 기능은 추후 구현 예정입니다.')),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF19C37D),
        backgroundColor: const Color(0xFF40414F),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 환영 메시지
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF19C37D), Color(0xFF16A085)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '안녕하세요! 👋',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '단국대학교 관련 궁금한 점이 있으시면\n언제든지 질문해주세요!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 공식 정보
                    if (_officialQuestions.isNotEmpty) ...[
                      _buildSectionHeader(
                        '📋 공식 정보',
                        '단국대학교 공식 자료',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionsListScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionsList(_officialQuestions),
                      const SizedBox(height: 32),
                    ],

                    // 인기 질문
                    if (_popularQuestions.isNotEmpty) ...[
                      _buildSectionHeader(
                        '🔥 인기 질문',
                        '조회수가 많은 질문들',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionsListScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionsList(_popularQuestions),
                      const SizedBox(height: 32),
                    ],

                    // 자주 받은 질문
                    if (_frequentQuestions.isNotEmpty) ...[
                      _buildSectionHeader(
                        '❓ 자주 받은 질문',
                        '답변이 많은 질문들',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionsListScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionsList(_frequentQuestions),
                      const SizedBox(height: 120), // 하단 검색창을 위한 여백
                    ],
                  ],
                ),
              ),
      ),
      bottomSheet: _buildSearchBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF40414F),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF19C37D), Color(0xFF16A085)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '단국대 도우미',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '교내 정보를 쉽게 찾아보세요',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: '홈',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.chat,
                  title: 'AI 채팅 도우미',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list,
                  title: '질문 목록',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuestionsListScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_circle,
                  title: '새 질문 작성',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewQuestionScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Color(0xFF565869)),
                _buildDrawerItem(
                  icon: Icons.school,
                  title: '학사 정보',
                  onTap: () {
                    Navigator.pop(context);
                    // 학사 카테고리로 필터링된 질문 목록으로 이동
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.attach_money,
                  title: '장학금 정보',
                  onTap: () {
                    Navigator.pop(context);
                    // 장학금 카테고리로 필터링된 질문 목록으로 이동
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event,
                  title: '교내 프로그램',
                  onTap: () {
                    Navigator.pop(context);
                    // 교내프로그램 카테고리로 필터링된 질문 목록으로 이동
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.work,
                  title: '취업 정보',
                  onTap: () {
                    Navigator.pop(context);
                    // 취업 카테고리로 필터링된 질문 목록으로 이동
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, VoidCallback onMoreTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onMoreTap,
          child: Text(
            '더보기',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList(List<Question> questions) {
    return Column(
      children: questions.map((question) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: MessageBubble(
            question: question,
            onTap: () => _onQuestionTap(question),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildSearchBar() {
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
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '궁금한 점을 검색해보세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onSubmitted: (_) => _performSearch(),
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
              onPressed: _performSearch,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 