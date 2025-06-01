import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    {'id': '전체', 'name': '전체', 'icon': '📋'},
    {'id': '공식', 'name': '공식', 'icon': '🏛️'},
    {'id': '학사', 'name': '학사', 'icon': '📚'},
    {'id': '장학금', 'name': '장학금', 'icon': '💰'},
    {'id': '교내프로그램', 'name': '교내프로그램', 'icon': '🎯'},
    {'id': '취업', 'name': '취업', 'icon': '💼'},
    {'id': '기타', 'name': '기타', 'icon': '💭'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category['id'];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(
                category: category,
                isSelected: isSelected,
                onTap: () => onCategoryChanged(category['id']!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required Map<String, String> category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : AppTheme.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category['icon'] != null) ...[
                Text(
                  category['icon']!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                category['name']!,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.primaryTextColor,
                  fontSize: 14,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 