import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'signup_complete_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // 이메일 필드는 빈 상태로 시작 (아이디 부분만 입력받음)
  }

  Future<void> _handleLogin() async {
    final username = _emailController.text.trim();
    final fullEmail = '$username@dankook.ac.kr';
    
    if (username.isEmpty || _passwordController.text.trim().isEmpty) {
      _showErrorDialog('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    if (username.isEmpty) {
      _showErrorDialog('아이디를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        fullEmail, // 전체 이메일 주소로 로그인
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          // 로그인 성공: 홈화면으로 이동
          Navigator.pop(context); // 로그인 화면 닫기
          _showSnackBar('로그인되었습니다.');
        } else {
          // 로그인 실패: iOS 스타일 알림창 표시
          _showErrorDialog(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('로그인 중 오류가 발생했습니다.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('로그인 실패'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
          '로그인',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // 로고 및 환영 메시지
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.welcomeContainerDecoration,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/images/bear_umbrella.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              CupertinoIcons.person_circle_fill,
                              size: 72,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '단비',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '단국대학교 계정으로 로그인하세요',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 이메일 입력
              Text(
                '아이디',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  style: AppTheme.bodyStyle,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '아이디를 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.person, color: AppTheme.hintTextColor),
                    suffixText: '@dankook.ac.kr',
                    suffixStyle: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 비밀번호 입력
              Text(
                '비밀번호',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onSubmitted: (_) => _handleLogin(),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 로그인 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 회원가입 버튼
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 개발자 테스트 버튼
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.wrench,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '개발자 테스트',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupCompleteScreen(
                                email: 'test@dankook.ac.kr',
                                nickname: '테스트',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '가입완료 페이지 테스트',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              // 테스트 로그인 버튼
              TextButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  try {
                    final result = await _authService.login(
                      'test@dankook.ac.kr',
                      'test1234',
                    );
                    
                    if (mounted) {
                      setState(() => _isLoading = false);
                      if (result['success']) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        _showErrorDialog(result['message']);
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      _showErrorDialog('로그인 중 오류가 발생했습니다.');
                    }
                  }
                },
                child: Text(
                  '테스트 계정으로 로그인',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
} 