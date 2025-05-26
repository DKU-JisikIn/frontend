import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/question.dart';
import '../widgets/category_selector.dart';

class NewQuestionScreen extends StatefulWidget {
  const NewQuestionScreen({super.key});

  @override
  State<NewQuestionScreen> createState() => _NewQuestionScreenState();
}

class _NewQuestionScreenState extends State<NewQuestionScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  String _selectedCategory = '학사';
  List<String> _tags = [];
  bool _isSubmitting = false;

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final question = Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        userId: 'user_001', // TODO: 실제 사용자 ID로 대체
        userName: '익명',
        createdAt: DateTime.now(),
        category: _selectedCategory,
        tags: _tags,
      );

      await _apiService.createQuestion(question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('질문이 성공적으로 등록되었습니다!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('질문 등록 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          '새 질문 작성',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitQuestion,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '등록',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택
            Text(
              '카테고리',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  items: CategorySelector.categories
                      .where((category) => category['id'] != 'all')
                      .map((category) => DropdownMenuItem(
                            value: category['id'],
                            child: Text(
                              category['name']!,
                              style: AppTheme.bodyStyle,
                            ),
                          ))
                      .toList(),
                  dropdownColor: AppTheme.surfaceColor,
                  icon: Icon(CupertinoIcons.chevron_down, color: AppTheme.primaryTextColor),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 제목 입력
            Text(
              '제목',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: '질문의 제목을 입력하세요',
                hintStyle: AppTheme.hintStyle,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            
            // 내용 입력
            Text(
              '내용',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: '질문의 상세 내용을 입력하세요',
                hintStyle: AppTheme.hintStyle,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 4,
            ),
            const SizedBox(height: 24),
            
            // 태그 입력
            Text(
              '태그 (선택사항)',
              style: AppTheme.headingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: AppTheme.bodyStyle,
                    decoration: InputDecoration(
                      hintText: '태그를 입력하고 추가 버튼을 누르세요',
                      hintStyle: AppTheme.hintStyle,
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    maxLines: 1,
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 추가된 태그들
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeTag(tag),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                '태그는 최대 5개까지 추가할 수 있습니다 (${_tags.length}/5)',
                style: AppTheme.subheadingStyle,
              ),
            ],
            
            const SizedBox(height: 32),
            
            // 주의사항
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '질문 작성 가이드',
                    style: AppTheme.headingStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 명확하고 구체적인 제목을 작성해주세요\n'
                    '• 상황을 자세히 설명해주시면 더 정확한 답변을 받을 수 있습니다\n'
                    '• 관련 태그를 추가하면 비슷한 질문을 찾기 쉬워집니다\n'
                    '• 개인정보는 포함하지 마세요',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
} 