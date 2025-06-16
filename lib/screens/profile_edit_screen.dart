import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nicknameController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  File? _newProfileImage;

  // 실시간 닉네임 유효성 검사 상태
  bool _hasValidLength = false;
  bool _hasValidCharacters = false;
  bool _isNotDuplicate = true;
  bool _isNotEmpty = false;

  @override
  void initState() {
    super.initState();
    // 현재 닉네임으로 초기화 - 제거하여 빈 상태로 시작
    // _nicknameController.text = _authService.currentUserNickname ?? '';
  }

  void _validateNickname() {
    final nickname = _nicknameController.text;
    setState(() {
      _isNotEmpty = nickname.isNotEmpty;
      
      if (nickname.isEmpty) {
        // 빈 문자열일 때는 모든 조건 불만족
        _hasValidLength = false;
        _hasValidCharacters = false;
        _isNotDuplicate = false;
      } else {
        _hasValidLength = nickname.length >= 2 && nickname.length <= 10;
        _hasValidCharacters = RegExp(r'^[가-힣a-zA-Z0-9]+$').hasMatch(nickname);
        // 현재 닉네임과 다르거나 허용되지 않은 닉네임이 아니면 사용 가능
        _isNotDuplicate = nickname == _authService.currentUserNickname ||
                         !['admin', 'test', '관리자'].contains(nickname.toLowerCase());
      }
    });
  }

  bool get _isNicknameValid => _isNotEmpty && _hasValidLength && _hasValidCharacters && _isNotDuplicate;

  Future<void> _pickProfileImage() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('프로필 사진 변경'),
        message: const Text('새로운 프로필 사진을 선택해주세요'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateImagePick();
            },
            child: const Text('카메라'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateImagePick();
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

  void _simulateImagePick() {
    // TODO: 실제 이미지 피커 구현
    setState(() {
      // _newProfileImage = selectedFile;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('프로필 사진 선택이 완료되었습니다. (시뮬레이션)'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _handleSave() async {
    final nickname = _nicknameController.text.trim();
    
    // 실시간 검증으로 이미 확인했으므로 간단한 체크만
    if (!_isNicknameValid) {
      setState(() => _errorMessage = '닉네임 조건을 모두 만족해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 프로필 업데이트 API 호출
      final result = await _authService.updateProfile(
        nickname, 
        _authService.currentUserProfileImageUrl ?? '',
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
          
          Navigator.pop(context);
        } else {
          setState(() => _errorMessage = result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '프로필 업데이트 중 오류가 발생했습니다.';
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
          '프로필 수정',
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
              
              // 프로필 사진 섹션
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: ClipOval(
                              child: _authService.currentUserProfileImageUrl != null
                                  ? Image.network(
                                      _authService.currentUserProfileImageUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: AppTheme.primaryColor,
                                          child: Icon(
                                            CupertinoIcons.person,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    )
                                  : Icon(
                                      CupertinoIcons.person,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                            ),
                          ),
                          
                          // 편집 아이콘
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                CupertinoIcons.camera,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      '프로필 사진 변경',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
                    hintText: _authService.currentUserNickname?.isNotEmpty == true 
                        ? _authService.currentUserNickname! 
                        : '닉네임을 입력하세요',
                    hintStyle: AppTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(CupertinoIcons.person, color: AppTheme.hintTextColor),
                    counterText: '', // 글자 수 카운터 숨김
                  ),
                  onSubmitted: (_) => _handleSave(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                    _validateNickname();
                  },
                ),
              ),
              
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
              
              // 닉네임 조건 안내 - 항상 표시
              const SizedBox(height: 8),
              _buildNicknameRequirement('2자 이상 10자 이하', _hasValidLength),
              _buildNicknameRequirement('한글, 영문, 숫자만 가능', _hasValidCharacters),
              _buildNicknameRequirement('사용 가능한 닉네임', _isNotDuplicate),
              
              const SizedBox(height: 40),
              
              // 저장 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isNicknameValid) ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNicknameValid ? AppTheme.primaryColor : Colors.grey[300],
                    foregroundColor: _isNicknameValid ? Colors.white : Colors.grey[600],
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
                      : Text(
                          _isNicknameValid ? '저장' : '닉네임 조건을 확인해주세요',
                          style: const TextStyle(
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

  Widget _buildNicknameRequirement(String text, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isSatisfied ? CupertinoIcons.checkmark : CupertinoIcons.exclamationmark_triangle,
            color: isSatisfied ? AppTheme.primaryColor : Colors.red,
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
    _nicknameController.dispose();
    _nicknameFocusNode.dispose();
    super.dispose();
  }
} 