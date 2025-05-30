import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _currentPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (currentPassword.isEmpty) {
      setState(() => _errorMessage = '현재 비밀번호를 입력해주세요.');
      return;
    }
    
    if (newPassword.isEmpty) {
      setState(() => _errorMessage = '새 비밀번호를 입력해주세요.');
      return;
    }
    
    if (confirmPassword.isEmpty) {
      setState(() => _errorMessage = '새 비밀번호 확인을 입력해주세요.');
      return;
    }

    if (!_authService.isValidPassword(newPassword)) {
      setState(() => _errorMessage = '새 비밀번호는 최소 8자, 영문과 숫자를 포함해야 합니다.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = '새 비밀번호가 일치하지 않습니다.');
      return;
    }

    if (currentPassword == newPassword) {
      setState(() => _errorMessage = '현재 비밀번호와 새 비밀번호가 동일합니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (currentPassword != 'password123') {
        setState(() {
          _isLoading = false;
          _errorMessage = '현재 비밀번호가 올바르지 않습니다.';
        });
        return;
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 성공 메시지를 스낵바로 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('비밀번호가 성공적으로 변경되었습니다.'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // 이전 화면으로 돌아가기
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '비밀번호 변경 중 오류가 발생했습니다.';
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
          '비밀번호 변경',
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
                      CupertinoIcons.lock_shield,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '보안을 위해 현재 비밀번호를 먼저 확인합니다.',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                '현재 비밀번호',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _currentPasswordController,
                  focusNode: _currentPasswordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: !_isCurrentPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '현재 비밀번호를 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCurrentPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _newPasswordFocusNode.requestFocus(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                '새 비밀번호',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '새 비밀번호를 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                '새 비밀번호 확인',
                style: AppTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.inputContainerDecoration,
                child: TextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  style: AppTheme.bodyStyle,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '새 비밀번호를 다시 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.lock, color: AppTheme.hintTextColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        color: AppTheme.hintTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _handleChangePassword(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
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
                          '새 비밀번호 조건',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement('최소 8자 이상'),
                    _buildRequirement('영문자와 숫자 포함'),
                    _buildRequirement('현재 비밀번호와 다른 비밀번호'),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '비밀번호 변경',
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

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.checkmark,
            color: AppTheme.primaryColor,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
} 