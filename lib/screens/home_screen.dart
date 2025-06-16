import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../models/question.dart';
import '../widgets/message_bubble.dart';
import '../widgets/home/banner_widgets.dart';
import '../widgets/home/stats_widgets.dart';
import '../widgets/home/home_drawer.dart';
import '../widgets/home/home_app_bar.dart';
import 'question_detail_screen.dart';
import 'chat_screen.dart';
import 'questions_list_screen.dart';
import 'popular_questions_screen.dart';
import 'frequent_questions_screen.dart';
import 'new_question_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
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
  Map<String, dynamic> _userQuestionStats = {
    'total': 0,
    'answered': 0,
    'unanswered': 0,
  };

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
      
      // 사용자 질문 통계 로드
      if (_authService.isLoggedIn) {
        try {
          final userStats = await _apiService.getUserQuestionStats(_authService.currentUserId!, token: _authService.accessToken);
          setState(() {
            _userQuestionStats = userStats;
          });
        } catch (e) {
          print('사용자 질문 통계 로드 실패: $e');
        }
      }
      
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
      appBar: HomeAppBar(authService: _authService),
      drawer: HomeDrawer(themeService: _themeService),
      body: GestureDetector(
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
                      // 배너 리스트
                      SlideTransition(
                        position: _slideAnimations[0],
                        child: FadeTransition(
                          opacity: _fadeAnimations[0],
                          child: SizedBox(
                            height: 200,
                            child: ListView(
                              controller: _bannerScrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                WelcomeBanner(authService: _authService),
                                const OfficialBanner(),
                                const PopularBanner(),
                                const FrequentBanner(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 사용자 질문 통계
                      if (_authService.isLoggedIn) ...[
                        SlideTransition(
                          position: _slideAnimations[1],
                          child: FadeTransition(
                            opacity: _fadeAnimations[1],
                            child: UserStatsWidget(
                              userQuestionStats: _userQuestionStats,
                              onRefresh: _loadDashboardData,
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
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 우수 답변자 랭킹
                      SlideTransition(
                        position: _slideAnimations[3],
                        child: FadeTransition(
                          opacity: _fadeAnimations[3],
                          child: TopAnswerersWidget(topAnswerers: _topAnswerers),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 통계 섹션
                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 오늘의 질문과 답변 통계
                            FadeTransition(
                              opacity: _fadeAnimations[4],
                              child: SlideTransition(
                                position: _slideAnimations[4],
                                child: TodayStatsWidget(
                                  todayQuestionCount: _todayQuestionCount,
                                  todayAnswerCount: _todayAnswerCount,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _fadeAnimations[5],
                              child: SlideTransition(
                                position: _slideAnimations[5],
                                child: TotalAnswersWidget(
                                  totalAnswerCount: _totalAnswerCount,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
        ),
      ),
      bottomSheet: SearchBottomSheet(
        searchController: _searchController,
        onSearch: _performSearch,
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
} 