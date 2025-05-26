import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  static const List<Map<String, String>> periods = [
    {'id': '전체기간', 'name': '전체기간'},
    {'id': '일주일', 'name': '일주일'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Text(
              '기간:',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: periods.length,
              itemBuilder: (context, index) {
                final period = periods[index];
                final isSelected = selectedPeriod == period['id'];
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      period['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => onPeriodChanged(period['id']!),
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      width: 1,
                    ),
                    showCheckmark: false,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.standard,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 