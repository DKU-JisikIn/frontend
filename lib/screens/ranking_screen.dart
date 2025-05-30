import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  List<TopAnswerer> _rankings = [];
  TopAnswerer? _myRanking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    
    try {
      // 전체 랭킹 로드 (1-100등)
      final rankings = await _apiService.getTopAnswerers(limit: 100);
      
      // 로그인된 경우 내 랭킹 정보 로드
      TopAnswerer? myRanking;
      if (_authService.isLoggedIn) {
        myRanking = await _loadMyRanking();
      }
      
      setState(() {
        _rankings = rankings;
        _myRanking = myRanking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('랭킹을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<TopAnswerer?> _loadMyRanking() async {
    // TODO: 실제 API 호출로 대체
    // 현재는 목업 데이터로 테스트
    if (_authService.currentUserNickname == '테스트사용자') {
      return TopAnswerer(
        id: 'test',
        userName: '테스트사용자',
        profileImageUrl: 'https://via.placeholder.com/50/4A90E2/FFFFFF?text=T',
        score: 1250,
        rank: 42,
        answerCount: 28,
        likeCount: 89,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          '랭킹',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRankings,
              color: AppTheme.primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 내 랭킹 (로그인된 경우만)
                  if (_myRanking != null) ...[
                    _buildMyRankingCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // 전체 랭킹 제목
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '전체 랭킹',
                        style: AppTheme.headingStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 랭킹 리스트
                  ..._rankings.asMap().entries.map((entry) {
                    final index = entry.key;
                    final user = entry.value;
                    return _buildRankingCard(user, index == 0, index == 1, index == 2);
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildMyRankingCard() {
    if (_myRanking == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.person_fill,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '내 랭킹',
                style: AppTheme.headingStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.primaryColor,
                child: ClipOval(
                  child: Image.network(
                    _myRanking!.profileImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: AppTheme.primaryColor,
                        child: Center(
                          child: Text(
                            _myRanking!.userName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _myRanking!.userName,
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_myRanking!.rank}등',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_myRanking!.score}점',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 통계 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '답변 ${_myRanking!.answerCount}개',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '좋아요 ${_myRanking!.likeCount}개',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(TopAnswerer user, bool isFirst, bool isSecond, bool isThird) {
    Color? backgroundColor;
    Color? borderColor;
    Widget? rankIcon;
    
    if (isFirst) {
      backgroundColor = const Color(0xFFFFD700).withOpacity(0.1);
      borderColor = const Color(0xFFFFD700);
      rankIcon = Icon(CupertinoIcons.star_circle_fill, color: Color(0xFFFFD700), size: 20);
    } else if (isSecond) {
      backgroundColor = const Color(0xFFC0C0C0).withOpacity(0.1);
      borderColor = const Color(0xFFC0C0C0);
      rankIcon = Icon(CupertinoIcons.star_fill, color: Color(0xFFC0C0C0), size: 18);
    } else if (isThird) {
      backgroundColor = const Color(0xFFCD7F32).withOpacity(0.1);
      borderColor = const Color(0xFFCD7F32);
      rankIcon = Icon(CupertinoIcons.star_fill, color: Color(0xFFCD7F32), size: 16);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppTheme.borderColor,
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 40,
            child: Row(
              children: [
                if (rankIcon != null) ...[
                  rankIcon,
                  const SizedBox(width: 4),
                ] else ...[
                  Text(
                    '${user.rank}',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 프로필 이미지
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor,
            child: ClipOval(
              child: Image.network(
                user.profileImageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: AppTheme.primaryColor,
                    child: Center(
                      child: Text(
                        user.userName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
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
                  user.userName,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '답변 ${user.answerCount}개 • 좋아요 ${user.likeCount}개',
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
            '${user.score}점',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 