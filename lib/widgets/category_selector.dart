import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<Map<String, String>> categories = [
    {'id': 'all', 'name': '전체'},
    {'id': '학사', 'name': '학사'},
    {'id': '장학금', 'name': '장학금'},
    {'id': '교내프로그램', 'name': '교내프로그램'},
    {'id': '취업', 'name': '취업'},
    {'id': '기타', 'name': '기타'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF343541),
        border: Border(
          bottom: BorderSide(color: Color(0xFF565869), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category['name']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category['id']!),
              backgroundColor: const Color(0xFF40414F),
              selectedColor: const Color(0xFF19C37D),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF19C37D) : const Color(0xFF565869),
                width: 1,
              ),
              showCheckmark: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            ),
          );
        },
      ),
    );
  }
} 