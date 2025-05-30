import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
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
import 'my_questions_screen.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final ThemeService _themeService = ThemeService();
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

  // 사용자 질문 통계 데이터
  Map<String, int> _userQuestionStats = {};

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
    _fadeAnimations = List.generate(8, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.07, // 각 요소마다 0.07초씩 지연
          (index * 0.07) + 0.4, // 0.4초 동안 애니메이션
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _slideAnimations = List.generate(8, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.07,
          (index * 0.07) + 0.4,
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _loadDashboardData();
    
    // AuthService 상태 변경 감지
    _authService.authStateStream.listen((isLoggedIn) {
      if (mounted) {
        setState(() {}); // UI 업데이트
        // 로그인 상태가 변경되면 데이터 다시 로드
        _loadDashboardData();
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
      
      // 사용자 질문 통계 로드 (로그인된 경우에만)
      Map<String, int> userQuestionStats = {};
      if (_authService.isLoggedIn) {
        final userId = _authService.currentUserEmail?.split('@')[0] ?? 'test';
        print('Loading user question stats for userId: $userId'); // 디버그 로그
        userQuestionStats = await _apiService.getUserQuestionStats(userId);
        print('User question stats loaded: $userQuestionStats'); // 디버그 로그
      }
      
      setState(() {
        _unansweredQuestions = unansweredQuestions;
        _todayQuestionCount = todayQuestionCount;
        _todayAnswerCount = todayAnswerCount;
        _totalAnswerCount = totalAnswerCount;
        _topAnswerers = topAnswerers;
        _userQuestionStats = userQuestionStats;
        _isLoading = false;
      });

      // 데이터 로딩 완료 후 애니메이션 시작
      if (!_isLoading && mounted) {
        _animationController.forward();
        // 기존 타이머 정리 후 새로 시작
        _stopQuestionTimer();
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
    // 기존 타이머가 있으면 취소
    _questionTimer?.cancel();
    
    // 질문이 없으면 타이머 시작하지 않음
    if (_unansweredQuestions.isEmpty) return;
    
    // 질문이 1개뿐이면 애니메이션만 시작하고 타이머는 시작하지 않음
    if (_unansweredQuestions.length == 1) {
      if (mounted && _questionAnimationController.status != AnimationStatus.forward) {
        _questionAnimationController.forward();
      }
      return;
    }
    
    // 초기 애니메이션 시작
    if (mounted && _questionAnimationController.status != AnimationStatus.forward) {
      _questionAnimationController.forward();
    }
    
    // 타이머 시작 (3초마다 질문 변경)
    _questionTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _unansweredQuestions.isEmpty) {
        timer.cancel();
        return;
      }
      
      // 애니메이션이 이미 실행 중이면 스킵
      if (_questionAnimationController.isAnimating) {
        return;
      }
      
      // 페이드 아웃
      _questionAnimationController.reverse().then((_) {
        if (!mounted || _unansweredQuestions.isEmpty) return;
        
        setState(() {
          _currentQuestionIndex = (_currentQuestionIndex + 1) % _unansweredQuestions.length;
        });
        
        // 페이드 인
        if (mounted) {
          _questionAnimationController.forward();
        }
      });
    });
  }
  
  void _stopQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _onQuestionTap(Question question) {
    // 질문 상세로 이동하기 전에 타이머 일시 정지
    _stopQuestionTimer();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionDetailScreen(question: question),
      ),
    ).then((_) {
      // 돌아왔을 때 타이머 다시 시작
      if (mounted && _unansweredQuestions.isNotEmpty) {
        _startQuestionTimer();
      }
    });
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
          _buildProfileButton(),
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
              ? Center(
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

                      // 사용자 질문 통계 (로그인된 경우에만 표시)
                      if (_authService.isLoggedIn) ...[
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
                                        CupertinoIcons.person_crop_circle,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '내 질문 현황',
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
                                    children: [
                                      Expanded(
                                        child: _buildUserStatItem(
                                          '올린 질문',
                                          _userQuestionStats['total'] ?? 0,
                                          CupertinoIcons.chat_bubble_text,
                                          () => _navigateToMyQuestions('all'),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 50,
                                        color: AppTheme.borderColor,
                                      ),
                                      Expanded(
                                        child: _buildUserStatItem(
                                          '답변받은 질문',
                                          _userQuestionStats['answered'] ?? 0,
                                          CupertinoIcons.checkmark_circle,
                                          () => _navigateToMyQuestions('answered'),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 50,
                                        color: AppTheme.borderColor,
                                      ),
                                      Expanded(
                                        child: _buildUserStatItem(
                                          '답변 대기중',
                                          _userQuestionStats['unanswered'] ?? 0,
                                          CupertinoIcons.clock,
                                          () => _navigateToMyQuestions('unanswered'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 답변받지 못한 질문 카드
                      if (_unansweredQuestions.isNotEmpty) ...[
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
                                  child: _unansweredQuestions.isNotEmpty && 
                                         _currentQuestionIndex < _unansweredQuestions.length
                                      ? MessageBubble(
                                          question: _unansweredQuestions[_currentQuestionIndex],
                                          onTap: () => _onQuestionTap(_unansweredQuestions[_currentQuestionIndex]),
                                        )
                                      : Container(), // 안전한 대체 위젯
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
                        position: _slideAnimations[6],
                        child: FadeTransition(
                          opacity: _fadeAnimations[6],
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
            icon: CupertinoIcons.list_bullet,
            title: '전체 질문',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuestionsListScreen(initialCategory: '전체'),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.flame,
            title: '인기 질문',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PopularQuestionsScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.question_circle,
            title: '자주 받은 질문',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FrequentQuestionsScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: CupertinoIcons.star_fill,
            title: '랭킹',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RankingScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          
          // 다크 모드 스위치
          ListenableBuilder(
            listenable: _themeService,
            builder: (context, child) {
              return ListTile(
                leading: Icon(
                  _themeService.isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                  color: AppTheme.secondaryTextColor,
                ),
                title: Text(
                  '다크 모드',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                trailing: CupertinoSwitch(
                  value: _themeService.isDarkMode,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    _themeService.toggleTheme();
                    setState(() {}); // UI 업데이트
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
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
            decoration: BoxDecoration(
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
        gradient: LinearGradient(
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
        gradient: LinearGradient(
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
        gradient: LinearGradient(
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

  Widget _buildUserStatItem(String label, int count, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMyQuestions(String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyQuestionsScreen(initialFilter: filter),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _questionAnimationController.dispose();
    _bannerScrollController.dispose();
    _stopQuestionTimer(); // 타이머 정리
    super.dispose();
  }

  Widget _buildProfileButton() {
    if (_authService.isLoggedIn) {
      // 프로필 이미지가 있으면 CircleAvatar로 표시, 없으면 기본 아이콘
      final profileImageUrl = _authService.currentUserProfileImageUrl;
      
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
        icon: profileImageUrl != null && profileImageUrl.isNotEmpty
            ? CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.primaryColor,
                child: ClipOval(
                  child: Image.network(
                    profileImageUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지 로딩 실패시 기본 아이콘 표시
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : Icon(CupertinoIcons.person_circle, color: AppTheme.primaryTextColor),
      );
    } else {
      return IconButton(
        icon: Icon(CupertinoIcons.person_circle, color: AppTheme.primaryTextColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
      );
    }
  }
} 