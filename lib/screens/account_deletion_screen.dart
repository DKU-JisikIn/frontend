import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  String? _selectedReason;

  final List<String> _deletionReasons = [
    '서비스를 더 이상 이용하지 않아요',
    '원하는 정보를 찾기 어려워요',
    '개인정보 보호가 걱정돼요',
    '다른 서비스를 이용하게 되었어요',
    '계정이 너무 많아요',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    // 현재 이메일로 초기화
    _emailController.text = _authService.currentUserEmail ?? '';
  }

  Future<void> _handleAccountDeletion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty) {
      setState(() => _errorMessage = '이메일을 입력해주세요.');
      return;
    }
    
    if (password.isEmpty) {
      setState(() => _errorMessage = '비밀번호를 입력해주세요.');
      return;
    }

    if (email != _authService.currentUserEmail) {
      setState(() => _errorMessage = '현재 계정의 이메일과 일치하지 않습니다.');
      return;
    }

    if (_selectedReason == null) {
      setState(() => _errorMessage = '탈퇴 사유를 선택해주세요.');
      return;
    }

    // 최종 확인 다이얼로그
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '회원탈퇴',
              style: TextStyle(color: AppTheme.primaryTextColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 회원탈퇴를 진행하시겠습니까?',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주의사항',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• 모든 개인정보가 삭제됩니다', 
                       style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 13)),
                  Text('• 작성한 질문과 답변은 유지됩니다', 
                       style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 13)),
                  Text('• 탈퇴 후 복구가 불가능합니다', 
                       style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '탈퇴하기',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 실제 계정 삭제 API 호출
      await Future.delayed(const Duration(milliseconds: 2000)); // API 호출 시뮬레이션
      
      // 테스트용 비밀번호 확인
      if (password != 'password123') {
        setState(() {
          _isLoading = false;
          _errorMessage = '비밀번호가 올바르지 않습니다.';
        });
        return;
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 탈퇴 완료 후 로그아웃 및 홈으로 이동
        await _authService.logout();
        
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('회원탈퇴가 완료되었습니다.'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '회원탈퇴 처리 중 오류가 발생했습니다.';
        });
      }
    }
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
          '회원탈퇴',
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
              const SizedBox(height: 20),
              
              // 경고 메시지
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '회원탈퇴',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '탈퇴 시 모든 개인정보가 삭제되며\n복구가 불가능합니다.',
                      style: TextStyle(
                        color: Colors.red.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 계정 확인
              Text(
                '계정 확인',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              // 이메일 입력
              Text(
                '이메일',
                style: AppTheme.headingStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  style: AppTheme.bodyStyle,
                  readOnly: true, // 수정 불가능하도록
                  decoration: InputDecoration(
                    hintText: '현재 계정 이메일',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.mail, color: AppTheme.hintTextColor),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 비밀번호 입력
              Text(
                '비밀번호',
                style: AppTheme.headingStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '현재 계정의 비밀번호를 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 탈퇴 사유
              Text(
                '탈퇴 사유',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              ..._deletionReasons.map((reason) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedReason == reason ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedReason == reason ? AppTheme.primaryColor : AppTheme.borderColor,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(
                      reason,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    value: reason,
                    groupValue: _selectedReason,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                        if (_errorMessage != null) {
                          _errorMessage = null;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 16),
              
              // 오류 메시지
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 40),
              
              // 탈퇴 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAccountDeletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '회원탈퇴',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
} 