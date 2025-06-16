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

  // 업로드된 파일이 있는지 확인하는 getter 추가
  bool get _hasUploadedFile => _profileImage != null || _verificationDocument != null;

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
        // 시뮬레이션을 위해 임시 파일 경로 설정
        _profileImage = File('simulated_profile_image.jpg');
      } else {
        // 시뮬레이션을 위해 임시 파일 경로 설정
        _verificationDocument = File('simulated_verification_document.jpg');
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
      // 회원가입 API 호출
      final result = await _authService.register(
        widget.email,
        widget.password,
        widget.nickname,
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
            
            const SizedBox(height: 32),
            
            // 안내사항 (상단으로 이동)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.lightbulb,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '추가 정보 입력 안내',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEnhancedInfoItem(
                    CupertinoIcons.exclamationmark_circle,
                    '선택사항입니다',
                    '프로필 사진 또는 소속 인증 문서 업로드는 선택사항입니다',
                  ),
                  const SizedBox(height: 12),
                  _buildEnhancedInfoItem(
                    CupertinoIcons.pencil_circle,
                    '언제든 수정 가능',
                    '나중에 프로필 설정에서 언제든 변경할 수 있습니다',
                  ),
                  const SizedBox(height: 12),
                  _buildEnhancedInfoItem(
                    CupertinoIcons.checkmark_seal,
                    '인증 마크 획득',
                    '인증 문서 업로드 시 관리자 승인 후 인증 마크가 표시됩니다',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 40),
            
            // 버튼들
            Column(
              children: [
                // 건너뛰기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleSkip,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '건너뛰고 가입완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 회원가입 완료 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_hasUploadedFile) ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasUploadedFile 
                          ? AppTheme.primaryColor 
                          : Colors.grey[400],
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
                        : Text(
                            _hasUploadedFile 
                                ? '파일과 함께 가입완료' 
                                : '파일을 업로드하고 가입완료',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
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