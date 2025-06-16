import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  File? _verificationDocument;

  Future<void> _pickDocument() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('인증 서류 선택'),
        message: const Text('학생증, 재학증명서 등 소속을 확인할 수 있는 서류를 선택해주세요'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateDocumentPick('카메라');
            },
            child: const Text('카메라로 촬영'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateDocumentPick('갤러리');
            },
            child: const Text('갤러리에서 선택'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _simulateDocumentPick('파일');
            },
            child: const Text('파일에서 선택'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }

  void _simulateDocumentPick(String source) {
    // TODO: 실제 문서 피커 구현
    setState(() {
      // _verificationDocument = selectedFile;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$source에서 서류 선택이 완료되었습니다. (시뮬레이션)'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_verificationDocument == null) {
      setState(() => _errorMessage = '인증 서류를 업로드해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 소속 인증 API 호출
      final result = await _authService.verifyDepartment(
        _authService.currentUserEmail ?? '',
        '컴퓨터공학과', // 임시로 고정값 사용
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          // 성공 다이얼로그
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.backgroundColor,
              title: Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '인증 신청 완료',
                    style: TextStyle(color: AppTheme.primaryTextColor),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['message'],
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '신청 정보',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('소속: ${result['department']}', 
                             style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 13)),
                        Text('인증 상태: ${result['isVerified'] ? '인증 완료' : '검토 중'}', 
                             style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.pop(context); // 인증 화면 닫기
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          );
        } else {
          setState(() => _errorMessage = result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '인증 신청 중 오류가 발생했습니다.';
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
          '소속 인증',
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
            const SizedBox(height: 20),
            
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(24),
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
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.checkmark_shield,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '소속 인증하기',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '단국대학교 재학생임을 인증하여\n신뢰도 높은 답변자가 되어보세요!',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 인증 서류 업로드
            Text(
              '인증 서류',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '학생증, 재학증명서 등 단국대학교 소속을 확인할 수 있는 서류를 업로드해주세요',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: _pickDocument,
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
                            : CupertinoIcons.doc_on_clipboard,
                        size: 40,
                        color: _verificationDocument != null 
                            ? AppTheme.primaryColor 
                            : AppTheme.hintTextColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _verificationDocument != null 
                            ? '서류 업로드 완료' 
                            : '서류 업로드',
                        style: TextStyle(
                          color: _verificationDocument != null 
                              ? AppTheme.primaryColor 
                              : AppTheme.hintTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_verificationDocument == null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '탭하여 선택',
                          style: TextStyle(
                            color: AppTheme.lightTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
            
            // 주의사항
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '주의사항',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildNotice('개인정보가 포함된 부분은 가려주세요'),
                  _buildNotice('관리자 검토 후 1-3일 내에 결과 통보'),
                  _buildNotice('허위 정보 제출 시 계정 제재 가능'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 신청 버튼
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
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
                        '인증 신청',
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

  Widget _buildNotice(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 