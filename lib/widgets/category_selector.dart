import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<Map<String, String>> categories = [
    {'id': '전체', 'name': '전체'},
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
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
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
                  color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category['id']!),
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                width: 1,
              ),
              showCheckmark: false,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
} 