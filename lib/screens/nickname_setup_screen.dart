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
  
  // 닉네임 유효성 검사 상태
  bool _hasValidLength = false;
  bool _hasValidCharacters = false;
  bool _isNotDuplicate = true; // 일단 true로 시작 (중복 검사는 서버에서)

  @override
  void initState() {
    super.initState();
    // 포커스를 자동으로 닉네임 입력 필드로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nicknameFocusNode.requestFocus();
    });
  }

  void _validateNickname() {
    final nickname = _nicknameController.text;
    setState(() {
      if (nickname.isEmpty) {
        // 입력이 없을 때는 모두 미확인 상태
        _hasValidLength = false;
        _hasValidCharacters = false;
        _isNotDuplicate = true; // 중복 검사는 기본적으로 통과
      } else {
        _hasValidLength = nickname.length >= 2 && nickname.length <= 10;
        _hasValidCharacters = RegExp(r'^[가-힣a-zA-Z0-9]+$').hasMatch(nickname);
        _isNotDuplicate = true; // 실제로는 서버에서 중복 확인
      }
      
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
  }

  bool get _isNicknameValid => _hasValidLength && _hasValidCharacters && _isNotDuplicate;
  bool get _canProceed => _isNicknameValid && _nicknameController.text.isNotEmpty;

  Future<void> _handleNext() async {
    if (!_canProceed) {
      if (!_hasValidLength) {
        setState(() => _errorMessage = '닉네임은 2자 이상 10자 이하여야 합니다.');
      } else if (!_hasValidCharacters) {
        setState(() => _errorMessage = '닉네임은 한글, 영문, 숫자만 입력 가능합니다.');
      }
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
              nickname: _nicknameController.text.trim(),
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
                  onChanged: (value) => _validateNickname(),
                ),
              ),
              
              // 닉네임 조건 표시
              const SizedBox(height: 8),
              _buildNicknameRequirement('2자 이상 10자 이하', _hasValidLength),
              _buildNicknameRequirement('한글, 영문, 숫자만 가능', _hasValidCharacters),
              _buildNicknameRequirement('중복되지 않은 닉네임', _isNotDuplicate),
              
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
              
              const SizedBox(height: 40),
              
              // 다음 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_canProceed) ? null : _handleNext,
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

  Widget _buildNicknameRequirement(String text, bool isValid) {
    final nickname = _nicknameController.text;
    String displayText;
    Color textColor;

    // 입력이 없을 때는 기본 안내 메시지 표시
    if (nickname.isEmpty) {
      switch (text) {
        case '2자 이상 10자 이하':
          displayText = '○ 2자 이상 10자 이하';
          break;
        case '한글, 영문, 숫자만 가능':
          displayText = '○ 한글, 영문, 숫자만 사용';
          break;
        case '중복되지 않은 닉네임':
          displayText = '○ 중복되지 않은 닉네임';
          break;
        default:
          displayText = text;
      }
      textColor = Colors.grey[600]!;
    } else {
      // 입력이 있을 때는 유효성 검사 결과 표시
      switch (text) {
        case '2자 이상 10자 이하':
          displayText = isValid ? '✓ 2자 이상 10자 이하입니다' : '✗ 2자 이상 10자 이하여야 합니다';
          break;
        case '한글, 영문, 숫자만 가능':
          displayText = isValid ? '✓ 올바른 문자를 사용했습니다' : '✗ 한글, 영문, 숫자만 입력 가능합니다';
          break;
        case '중복되지 않은 닉네임':
          displayText = isValid ? '✓ 사용 가능한 닉네임입니다' : '✗ 중복된 닉네임입니다';
          break;
        default:
          displayText = text;
      }
      textColor = isValid ? Colors.green[600]! : Colors.red[600]!;
    }

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