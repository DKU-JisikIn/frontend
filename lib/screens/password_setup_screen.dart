import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'nickname_setup_screen.dart';

class PasswordSetupScreen extends StatefulWidget {
  final String email;
  
  const PasswordSetupScreen({
    super.key,
    required this.email,
  });

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // 비밀번호 유효성 검사 상태
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
    });
    _validatePasswordMatch(); // 비밀번호가 변경되면 확인 필드도 다시 검사
  }

  void _validatePasswordMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      _passwordsMatch = password.isNotEmpty && 
                      confirmPassword.isNotEmpty && 
                      password == confirmPassword;
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasLetter && _hasNumber;
  bool get _canProceed => _isPasswordValid && _passwordsMatch;

  Future<void> _handleSignup() async {
    if (!_canProceed) {
      if (!_isPasswordValid) {
        _showSnackBar('비밀번호 조건을 모두 만족해주세요.');
      } else if (!_passwordsMatch) {
        _showSnackBar('비밀번호가 일치하지 않습니다.');
      }
      return;
    }

    setState(() => _isLoading = true);

    // 잠시 대기 후 다음 화면으로 이동 (비밀번호 검증 완료)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);
      
      // 닉네임 설정 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NicknameSetupScreen(
            email: widget.email,
            password: _passwordController.text.trim(),
          ),
        ),
      );
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
          '비밀번호 설정',
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
                      CupertinoIcons.lock_shield,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '비밀번호 설정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '안전한 비밀번호를 설정해주세요',
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
                  _buildStepLine(true),
                  _buildStepIndicator(2, '인증', true),
                  _buildStepLine(true),
                  _buildStepIndicator(3, '비밀번호', true),
                  _buildStepLine(false),
                  _buildStepIndicator(4, '닉네임', false),
                  _buildStepLine(false),
                  _buildStepIndicator(5, '추가정보', false),
                ],
              ),
              
              const SizedBox(height: 40),
              
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
                  onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  onChanged: (value) => _validatePassword(),
                ),
              ),
              
              // 비밀번호 조건 표시
              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildPasswordRequirement('최소 8자 이상', _hasMinLength),
                _buildPasswordRequirement('영문 포함', _hasLetter),
                _buildPasswordRequirement('숫자 포함', _hasNumber),
              ],
              
              const SizedBox(height: 24),
              
              // 비밀번호 재입력
              Text(
                '비밀번호 확인',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 다시 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  onSubmitted: (_) => _handleSignup(),
                  onChanged: (value) => _validatePasswordMatch(),
                ),
              ),
              
              // 비밀번호 일치 여부 표시
              if (_confirmPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildPasswordRequirement('비밀번호 일치', _passwordsMatch),
              ],
              
              const SizedBox(height: 40),
              
              // 회원가입 완료 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_canProceed) ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed ? AppTheme.primaryColor : Colors.grey[300],
                    foregroundColor: _canProceed ? Colors.white : Colors.grey[600],
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
                          '다음',
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

  Widget _buildPasswordRequirement(String text, bool isValid) {
    String displayText;
    Color textColor;
    IconData iconData;

    switch (text) {
      case '최소 8자 이상':
        displayText = isValid ? '✓ 8자 이상입니다' : '✗ 8자 이상이어야 합니다';
        break;
      case '영문 포함':
        displayText = isValid ? '✓ 영문이 포함되었습니다' : '✗ 영문을 포함해야 합니다';
        break;
      case '숫자 포함':
        displayText = isValid ? '✓ 숫자가 포함되었습니다' : '✗ 숫자를 포함해야 합니다';
        break;
      case '비밀번호 일치':
        displayText = isValid ? '✓ 비밀번호가 일치합니다' : '✗ 비밀번호가 일치하지 않습니다';
        break;
      default:
        displayText = text;
    }

    textColor = isValid ? Colors.green[600]! : Colors.red[600]!;

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
              child: isActive && step < 3
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
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

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      height: 2,
      width: 32,
      color: isCompleted ? AppTheme.primaryColor : Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
} 