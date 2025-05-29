import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'additional_info_screen.dart';

class NicknameSetupScreen extends StatefulWidget {
  final String email;
  final String password;

  const NicknameSetupScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 포커스를 자동으로 닉네임 입력 필드로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nicknameFocusNode.requestFocus();
    });
  }

  Future<void> _handleNext() async {
    final nickname = _nicknameController.text.trim();
    
    if (nickname.isEmpty) {
      setState(() => _errorMessage = '닉네임을 입력해주세요.');
      return;
    }
    
    if (nickname.length < 2) {
      setState(() => _errorMessage = '닉네임은 2자 이상이어야 합니다.');
      return;
    }
    
    if (nickname.length > 10) {
      setState(() => _errorMessage = '닉네임은 10자 이하여야 합니다.');
      return;
    }
    
    // 한글, 영문, 숫자만 허용
    if (!RegExp(r'^[가-힣a-zA-Z0-9]+$').hasMatch(nickname)) {
      setState(() => _errorMessage = '닉네임은 한글, 영문, 숫자만 입력 가능합니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 닉네임 중복 확인 API 호출
      await Future.delayed(const Duration(milliseconds: 500)); // API 호출 시뮬레이션
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 추가 정보 입력 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdditionalInfoScreen(
              email: widget.email,
              password: widget.password,
              nickname: nickname,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '닉네임 확인 중 오류가 발생했습니다.';
        });
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
          '닉네임 설정',
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
                      CupertinoIcons.person_circle,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '닉네임 설정',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '다른 사용자들에게 보여질 닉네임을 설정해주세요',
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
                  _buildStepLine(true),
                  _buildStepIndicator(4, '닉네임', true),
                  _buildStepLine(false),
                  _buildStepIndicator(5, '추가정보', false),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 닉네임 입력
              Text(
                '닉네임',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _nicknameController,
                  focusNode: _nicknameFocusNode,
                  style: AppTheme.bodyStyle,
                  maxLength: 10,
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.person, color: AppTheme.hintTextColor),
                    counterText: '', // 글자 수 카운터 숨김
                  ),
                  onSubmitted: (_) => _handleNext(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 오류 메시지
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // 닉네임 조건 안내
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.info_circle,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '닉네임 조건',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildNicknameRequirement('2자 이상 10자 이하'),
                    _buildNicknameRequirement('한글, 영문, 숫자만 가능'),
                    _buildNicknameRequirement('중복되지 않은 닉네임'),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 다음 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleNext,
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

  Widget _buildNicknameRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.circle_fill,
            size: 6,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
            ),
          ),
        ],
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
              child: isActive && step < 4
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
    _nicknameController.dispose();
    _nicknameFocusNode.dispose();
    super.dispose();
  }
} 