import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../screens/profile_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/chat_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService authService;

  const HomeAppBar({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        ProfileButton(authService: authService),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileButton extends StatelessWidget {
  final AuthService authService;

  const ProfileButton({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    if (authService.isLoggedIn) {
      final profileImageUrl = authService.currentUserProfileImageUrl;
      
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

class SearchBottomSheet extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const SearchBottomSheet({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: AppTheme.searchBarContainerDecoration,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: AppTheme.inputContainerDecoration,
              child: TextField(
                controller: searchController,
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
                onSubmitted: (_) => onSearch(),
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
              onPressed: onSearch,
            ),
          ),
        ],
      ),
    );
  }
} 