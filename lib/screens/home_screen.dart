import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import 'questions_list_screen.dart';
import 'popular_questions_screen.dart';
import 'frequent_questions_screen.dart';
import 'question_detail_screen.dart';
import 'new_question_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Question> _popularQuestions = [];
  List<Question> _frequentQuestions = [];
  List<Question> _officialQuestions = [];
  bool _isLoading = false;

  // 애니메이션 컨트롤러들
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 4개 요소에 대한 애니메이션 생성 (환영메시지, 공식정보, 인기질문, 자주받은질문)
    _fadeAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.15, // 각 요소마다 0.15초씩 지연
          (index * 0.15) + 0.4, // 0.4초 동안 애니메이션
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.15,
          (index * 0.15) + 0.4,
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _loadDashboardData();
    
    // AuthService 상태 변경 감지
    _authService.authStateStream.listen((isLoggedIn) {
      if (mounted) {
        setState(() {}); // UI 업데이트
      }
    });
    
    // 다른 화면에서 돌아왔을 때 키보드가 나타나지 않도록 포커스 해제
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
      _searchController.clear();
    });
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

      // 데이터 로딩 완료 후 애니메이션 시작
      if (!_isLoading) {
        _animationController.forward();
      }
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(CupertinoIcons.line_horizontal_3, color: AppTheme.primaryTextColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          '단국대 도우미',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.person_circle, color: AppTheme.primaryTextColor),
            onPressed: () {
              if (_authService.isLoggedIn) {
                // 로그인된 상태: 프로필 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else {
                // 로그인되지 않은 상태: 로그인 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: GestureDetector(
        // 화면 터치 시 키보드 숨기기
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.backgroundColor,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 환영 메시지
                      SlideTransition(
                        position: _slideAnimations[0],
                        child: FadeTransition(
                          opacity: _fadeAnimations[0],
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: AppTheme.welcomeContainerDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _authService.isLoggedIn 
                                    ? '${_authService.currentUserName ?? '사용자'}님, 반가워요! 👋'
                                    : '안녕하세요! 👋',
                                  style: const TextStyle(
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
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 공식 정보
                      if (_officialQuestions.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimations[1],
                          child: FadeTransition(
                            opacity: _fadeAnimations[1],
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  '📋 공식 정보',
                                  '단국대학교 공식 자료',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const QuestionsListScreen(initialCategory: '공식'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildQuestionsList(_officialQuestions),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // 인기 질문
                      if (_popularQuestions.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimations[2],
                          child: FadeTransition(
                            opacity: _fadeAnimations[2],
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  '🔥 인기 질문',
                                  '조회수가 많은 질문들',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PopularQuestionsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildQuestionsList(_popularQuestions),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // 자주 받은 질문
                      if (_frequentQuestions.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimations[3],
                          child: FadeTransition(
                            opacity: _fadeAnimations[3],
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  '❓ 자주 받은 질문',
                                  '비슷한 유형의 질문들',
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FrequentQuestionsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildQuestionsList(_frequentQuestions),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 120), // 하단 검색창을 위한 여백
                      ],
                    ],
                  ),
                ),
        ),
      ),
      bottomSheet: _buildSearchBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 상단 여백 (상태바 높이만큼)
          SizedBox(height: MediaQuery.of(context).padding.top + 20),
          
          // 메뉴 아이템들
          _buildDrawerItem(
            icon: CupertinoIcons.person,
            title: '내정보',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('내정보 기능은 추후 구현 예정입니다.')),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.settings,
            title: '설정',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 기능은 추후 구현 예정입니다.')),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.chat_bubble_text,
            title: '내가 올린 질문',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('내가 올린 질문 기능은 추후 구현 예정입니다.')),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.list_bullet,
            title: '질문목록',
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
          
          const SizedBox(height: 20),
          const Divider(),
          
          // 하단 여백
          const SizedBox(height: 40),
          
          // 버전 정보
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                color: AppTheme.lightTextColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
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
      leading: Icon(icon, color: AppTheme.secondaryTextColor),
      title: Text(
        title,
        style: TextStyle(color: AppTheme.primaryTextColor),
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
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.subheadingStyle,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: AppTheme.searchBarContainerDecoration,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: AppTheme.inputContainerDecoration,
              child: TextField(
                controller: _searchController,
                style: AppTheme.bodyStyle,
                autofocus: false,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  hintText: '궁금한 점을 검색해보세요...',
                  hintStyle: AppTheme.hintStyle,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(CupertinoIcons.search, color: AppTheme.hintTextColor),
                ),
                onSubmitted: (_) => _performSearch(),
                onTap: () {
                  // 검색바를 탭했을 때만 포커스 받도록
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 20),
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
    _animationController.dispose();
    super.dispose();
  }
} 