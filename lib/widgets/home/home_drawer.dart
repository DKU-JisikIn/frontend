import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';
import '../../services/theme_service.dart';
import '../../screens/questions_list_screen.dart';
import '../../screens/popular_questions_screen.dart';
import '../../screens/frequent_questions_screen.dart';
import '../../screens/ranking_screen.dart';

class HomeDrawer extends StatelessWidget {
  final ThemeService themeService;

  const HomeDrawer({
    super.key,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 상단 여백 (상태바 높이만큼)
          SizedBox(height: MediaQuery.of(context).padding.top + 20),
          
          // 메뉴 아이템들
          _buildDrawerItem(
            context,
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
            context,
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
            context,
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
            context,
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
            listenable: themeService,
            builder: (context, child) {
              return ListTile(
                leading: Icon(
                  themeService.isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                  color: AppTheme.secondaryTextColor,
                ),
                title: Text(
                  '다크 모드',
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                trailing: CupertinoSwitch(
                  value: themeService.isDarkMode,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    themeService.toggleTheme();
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

  Widget _buildDrawerItem(
    BuildContext context, {
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
} 