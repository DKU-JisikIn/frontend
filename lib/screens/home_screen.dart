import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import 'questions_list_screen.dart';
import 'popular_questions_screen.dart';
import 'frequent_questions_screen.dart';
import 'new_question_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'question_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _bannerScrollController = ScrollController();
  
  bool _isLoading = false;
  
  // 답변받지 못한 질문 관련
  List<Question> _unansweredQuestions = [];
  int _currentQuestionIndex = 0;
  Timer? _questionTimer;

  // 통계 데이터
  int _todayQuestionCount = 0;
  int _todayAnswerCount = 0;
  int _totalAnswerCount = 0;

  // 애니메이션 컨트롤러들
  late AnimationController _animationController;
  late AnimationController _questionAnimationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _questionFadeAnimation;

  // 우수 답변자 데이터
  List<TopAnswerer> _topAnswerers = [];

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 질문 카드 애니메이션 컨트롤러 초기화
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));

    // 4개 요소에 대한 애니메이션 생성 (환영메시지, 공식정보, 인기질문, 자주받은질문)
    _fadeAnimations = List.generate(7, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.08, // 각 요소마다 0.08초씩 지연
          (index * 0.08) + 0.4, // 0.4초 동안 애니메이션
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _slideAnimations = List.generate(7, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.08,
          (index * 0.08) + 0.4,
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
      // 답변받지 못한 질문들 로드 (테스트용으로 더 많이 로드)
      final unansweredQuestions = await _apiService.getUnansweredQuestions(limit: 8);
      
      // 통계 데이터 로드
      final todayQuestionCount = await _apiService.getTodayQuestionCount();
      final todayAnswerCount = await _apiService.getTodayAnswerCount();
      final totalAnswerCount = await _apiService.getTotalAnswerCount();
      
      // 우수 답변자 데이터 로드
      final topAnswerers = await _apiService.getTopAnswerers(limit: 5);
      
      setState(() {
        _unansweredQuestions = unansweredQuestions;
        _todayQuestionCount = todayQuestionCount;
        _todayAnswerCount = todayAnswerCount;
        _totalAnswerCount = totalAnswerCount;
        _topAnswerers = topAnswerers;
        _isLoading = false;
      });

      // 데이터 로딩 완료 후 애니메이션 시작
      if (!_isLoading) {
        _animationController.forward();
        if (_unansweredQuestions.isNotEmpty) {
          _startQuestionTimer();
        }
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

  void _startQuestionTimer() {
    _questionAnimationController.forward();
    _questionTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_unansweredQuestions.isNotEmpty) {
        _questionAnimationController.reverse().then((_) {
          setState(() {
            _currentQuestionIndex = (_currentQuestionIndex + 1) % _unansweredQuestions.length;
          });
          _questionAnimationController.forward();
        });
      }
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
          '단비',
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
                      // 배너 리스트 (좌우 스크롤 가능)
                      SlideTransition(
                        position: _slideAnimations[0],
                        child: FadeTransition(
                          opacity: _fadeAnimations[0],
                          child: SizedBox(
                            height: 200, // 정사각형에 가까운 높이로 조정
                            child: ListView(
                              controller: _bannerScrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                // 1. 인삿말 배너
                                _buildWelcomeBanner(),
                                // 2. 공식 정보 배너
                                _buildOfficialBanner(),
                                // 3. 인기 질문 배너
                                _buildPopularBanner(),
                                // 4. 자주 받은 질문 배너
                                _buildFrequentBanner(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 답변받지 못한 질문 카드
                      if (_unansweredQuestions.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimations[1],
                          child: FadeTransition(
                            opacity: _fadeAnimations[1],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.question_circle,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '답변을 기다리는 질문',
                                        style: TextStyle(
                                          color: AppTheme.primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FadeTransition(
                                  opacity: _questionFadeAnimation,
                                  child: MessageBubble(
                                    question: _unansweredQuestions[_currentQuestionIndex],
                                    onTap: () => _onQuestionTap(_unansweredQuestions[_currentQuestionIndex]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 우수 답변자 랭킹
                      if (_topAnswerers.isNotEmpty) ...[
                        SlideTransition(
                          position: _slideAnimations[2],
                          child: FadeTransition(
                            opacity: _fadeAnimations[2],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.star_fill,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '우수 답변자',
                                        style: TextStyle(
                                          color: AppTheme.primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: AppTheme.iosCardDecoration,
                                  child: Column(
                                    children: [
                                      for (int i = 0; i < 3 && i < _topAnswerers.length; i++)
                                        _buildTopAnswererItem(_topAnswerers[i], i == 2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 오늘의 질문과 답변 통계
                      SlideTransition(
                        position: _slideAnimations[3],
                        child: FadeTransition(
                          opacity: _fadeAnimations[3],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.chart_bar,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '오늘의 질문과 답변',
                                      style: TextStyle(
                                        color: AppTheme.primaryTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.iosCardDecoration,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '질문 수',
                                          style: TextStyle(
                                            color: AppTheme.secondaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$_todayQuestionCount',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: AppTheme.borderColor,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '답변 수',
                                          style: TextStyle(
                                            color: AppTheme.secondaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$_todayAnswerCount',
                                          style: TextStyle(
                                            color: AppTheme.primaryTextColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 누적 답변 수
                      SlideTransition(
                        position: _slideAnimations[5],
                        child: FadeTransition(
                          opacity: _fadeAnimations[5],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.checkmark_seal,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '누적 답변 수',
                                      style: TextStyle(
                                        color: AppTheme.primaryTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: AppTheme.iosCardDecoration,
                                child: Center(
                                  child: Text(
                                    '$_totalAnswerCount',
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 120), // 하단 검색창을 위한 여백
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

  // 배너 메서드들
  Widget _buildWelcomeBanner() {
    return Container(
      width: 200, // 너비를 줄여서 더 많은 배너가 보이도록 조정
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.welcomeContainerDecoration.gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (_authService.isLoggedIn) {
            // 로그인된 상태: 프로필 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _authService.isLoggedIn 
                ? '${_authService.currentUserName ?? '사용자'}님,\n반가워요!'
                : '안녕하세요!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _authService.isLoggedIn
                ? '궁금한 점이 있으신가요?\n언제든지 질문해주세요!'
                : '오늘은 무엇이\n궁금하시나요?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialBanner() {
    return Container(
      width: 200, // 너비를 줄여서 더 많은 배너가 보이도록 조정
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuestionsListScreen(initialCategory: '공식'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '공식 정보',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '단국대 공식 정보에 대한\n질문을 확인하세요!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBanner() {
    return Container(
      width: 200, // 너비를 줄여서 더 많은 배너가 보이도록 조정
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PopularQuestionsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '인기 질문',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '많은 학생들이 살펴본\n인기 질문을 확인하세요!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentBanner() {
    return Container(
      width: 200, // 너비를 줄여서 더 많은 배너가 보이도록 조정
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FrequentQuestionsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '자주 받은 질문',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '어떤 질문이 자주 올라올까요?\n한 번 확인해보세요!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAnswererItem(TopAnswerer topAnswerer, bool isLast) {
    // 랭킹에 따른 색상 설정
    Color rankColor;
    IconData rankIcon;
    
    switch (topAnswerer.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // 금색
        rankIcon = CupertinoIcons.star_fill;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // 은색
        rankIcon = CupertinoIcons.star_fill;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // 동색
        rankIcon = CupertinoIcons.star_fill;
        break;
      default:
        rankColor = AppTheme.secondaryTextColor;
        rankIcon = CupertinoIcons.star;
    }

    return Column(
      children: [
        Row(
          children: [
            // 랭킹 아이콘
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${topAnswerer.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 프로필 이미지
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  topAnswerer.userName.isNotEmpty ? topAnswerer.userName[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topAnswerer.userName,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '답변 ${topAnswerer.answerCount}개',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // 점수
            Text(
              '${topAnswerer.score}점',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: AppTheme.borderColor,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _questionAnimationController.dispose();
    _bannerScrollController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }
} 