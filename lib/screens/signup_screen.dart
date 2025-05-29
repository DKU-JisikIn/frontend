import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 아이디 필드는 빈 상태로 시작
  }

  Future<void> _handleSendVerification() async {
    final username = _emailController.text.trim();
    final fullEmail = '$username@dankook.ac.kr';
    
    if (username.isEmpty) {
      _showSnackBar('아이디를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.sendVerificationCode(fullEmail);

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          _showSnackBar(result['message']);
          // 이메일 인증 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(email: fullEmail),
            ),
          );
        } else {
          _showSnackBar(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('인증번호 전송 중 오류가 발생했습니다.');
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
          '회원가입',
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
              
              // 환영 메시지
              Container(
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.welcomeContainerDecoration,
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.person_badge_plus,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '단국대학교 아이디로 가입하세요',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 단계 표시
              Row(
                children: [
                  _buildStepIndicator(1, '이메일', true),
                  _buildStepLine(false),
                  _buildStepIndicator(2, '인증', false),
                  _buildStepLine(false),
                  _buildStepIndicator(3, '비밀번호', false),
                  _buildStepLine(false),
                  _buildStepIndicator(4, '닉네임', false),
                  _buildStepLine(false),
                  _buildStepIndicator(5, '추가정보', false),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 이메일 입력
              Text(
                '단국대 아이디',
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
                    hintText: 'student',
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
                  onSubmitted: (_) => _handleSendVerification(),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '단국대학교 아이디만 사용 가능합니다.\n인증번호가 해당 이메일로 전송됩니다.',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 인증번호 전송 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendVerification,
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
                          '인증번호 전송',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryColor : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      width: 32,
      color: isActive ? AppTheme.primaryColor : Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }
} 