import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'signup_complete_screen.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final String email;
  final String password;
  final String nickname;

  const AdditionalInfoScreen({
    super.key,
    required this.email,
    required this.password,
    required this.nickname,
  });

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  File? _profileImage;
  File? _verificationDocument;

  Future<void> _pickProfileImage() async {
    // TODO: 이미지 피커 구현 (image_picker 패키지 필요)
    // 현재는 시뮬레이션
    await _showImagePickerDialog('프로필 사진');
  }

  Future<void> _pickVerificationDocument() async {
    // TODO: 문서 피커 구현 (image_picker 또는 file_picker 패키지 필요)
    // 현재는 시뮬레이션
    await _showImagePickerDialog('소속 인증 문서');
  }

  Future<void> _showImagePickerDialog(String type) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('$type 선택'),
        message: const Text('이미지를 선택해주세요'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateImagePick(type);
            },
            child: const Text('카메라'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateImagePick(type);
            },
            child: const Text('갤러리'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _simulateImagePick(String type) {
    // 실제 구현에서는 이미지 피커로 선택된 파일을 설정
    setState(() {
      if (type == '프로필 사진') {
        // _profileImage = selectedFile;
      } else {
        // _verificationDocument = selectedFile;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type 선택이 완료되었습니다. (시뮬레이션)'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 추가 정보와 함께 회원가입 완료 API 호출
      final result = await _authService.register(
        widget.email, 
        widget.password,
        nickname: widget.nickname,
        profileImage: _profileImage,
        verificationDocument: _verificationDocument,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          // 가입 완료 화면으로 이동
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SignupCompleteScreen(
                email: widget.email,
                nickname: widget.nickname,
              ),
            ),
            (route) => false, // 모든 이전 화면 제거
          );
        } else {
          _showSnackBar(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('회원가입 중 오류가 발생했습니다.');
      }
    }
  }

  Future<void> _handleSkip() async {
    // 추가 정보 없이 회원가입 완료
    await _handleComplete();
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
          '추가 정보',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSkip,
            child: Text(
              '건너뛰기',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    CupertinoIcons.photo_camera,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '추가 정보',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '프로필을 더욱 풍성하게 만들어보세요!\n(선택사항)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
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
                _buildStepLine(true),
                _buildStepIndicator(5, '추가정보', true),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // 프로필 사진 섹션
            Text(
              '프로필 사진',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '다른 사용자들에게 보여질 프로필 사진을 설정해주세요',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickProfileImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _profileImage != null ? AppTheme.primaryColor : AppTheme.borderColor,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _profileImage != null 
                            ? CupertinoIcons.checkmark_circle_fill 
                            : CupertinoIcons.camera,
                        size: 40,
                        color: _profileImage != null 
                            ? AppTheme.primaryColor 
                            : AppTheme.hintTextColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profileImage != null 
                            ? '프로필 사진 선택됨' 
                            : '프로필 사진 선택',
                        style: TextStyle(
                          color: _profileImage != null 
                              ? AppTheme.primaryColor 
                              : AppTheme.hintTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 소속 인증 문서 섹션
            Text(
              '소속 인증 문서',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '학생증, 재학증명서 등 단국대 소속을 확인할 수 있는 문서를 업로드해주세요',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickVerificationDocument,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _verificationDocument != null ? AppTheme.primaryColor : AppTheme.borderColor,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _verificationDocument != null 
                            ? CupertinoIcons.checkmark_circle_fill 
                            : CupertinoIcons.doc_text,
                        size: 40,
                        color: _verificationDocument != null 
                            ? AppTheme.primaryColor 
                            : AppTheme.hintTextColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _verificationDocument != null 
                            ? '인증 문서 선택됨' 
                            : '인증 문서 선택',
                        style: TextStyle(
                          color: _verificationDocument != null 
                              ? AppTheme.primaryColor 
                              : AppTheme.hintTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                        '안내사항',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem('추가 정보는 선택사항입니다'),
                  _buildInfoItem('나중에 프로필에서 수정 가능합니다'),
                  _buildInfoItem('인증 문서는 관리자 승인 후 인증 마크가 표시됩니다'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 완료 버튼
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleComplete,
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
                        '회원가입 완료',
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
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.circle_fill,
            size: 6,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
              ),
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
              child: isActive && step < 5
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
} 