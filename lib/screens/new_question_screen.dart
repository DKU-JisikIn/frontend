import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../services/database_service.dart';
import '../widgets/category_selector.dart';

class NewQuestionScreen extends StatefulWidget {
  const NewQuestionScreen({super.key});

  @override
  State<NewQuestionScreen> createState() => _NewQuestionScreenState();
}

class _NewQuestionScreenState extends State<NewQuestionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  String _selectedCategory = '학사';
  List<String> _tags = [];
  bool _isSubmitting = false;

  Future<void> _submitQuestion() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final question = Question(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      userId: 'user_001', // 실제 앱에서는 로그인 시스템으로 대체
      userName: '익명',
      createdAt: DateTime.now(),
      category: _selectedCategory,
      tags: _tags,
    );

    try {
      await _databaseService.insertQuestion(question);
      if (mounted) {
        Navigator.pop(context, true); // 성공 시 true 반환
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('질문이 등록되었습니다!')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF343541),
      appBar: AppBar(
        backgroundColor: const Color(0xFF343541),
        title: const Text(
          '새 질문 작성',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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
                      color: Color(0xFF19C37D),
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
            const Text(
              '카테고리',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF40414F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF565869)),
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
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  dropdownColor: const Color(0xFF40414F),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 제목 입력
            const Text(
              '제목',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '질문의 제목을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF40414F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF565869)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF565869)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF19C37D)),
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 24),
            
            // 내용 입력
            const Text(
              '내용',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '질문의 상세 내용을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF40414F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF565869)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF565869)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF19C37D)),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 4,
            ),
            const SizedBox(height: 24),
            
            // 태그 입력
            const Text(
              '태그 (선택사항)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '태그를 입력하고 추가 버튼을 누르세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF40414F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF565869)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF565869)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF19C37D)),
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
                    backgroundColor: const Color(0xFF19C37D),
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
                      color: const Color(0xFF19C37D),
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
                            Icons.close,
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
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // 주의사항
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF444654),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '질문 작성 가이드',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 명확하고 구체적인 제목을 작성해주세요\n'
                    '• 상황을 자세히 설명해주시면 더 정확한 답변을 받을 수 있습니다\n'
                    '• 관련 태그를 추가하면 비슷한 질문을 찾기 쉬워집니다\n'
                    '• 개인정보는 포함하지 마세요',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      height: 1.4,
                    ),
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