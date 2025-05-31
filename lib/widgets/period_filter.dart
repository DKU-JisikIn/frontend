import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';

class PeriodFilter extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodFilter({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            '기간:',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: selectedPeriod,
              children: const {
                '전체기간': Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '전체',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                '일주일': Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '일주일',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              },
              onValueChanged: (String? value) {
                if (value != null) {
                  onPeriodChanged(value);
                }
              },
              backgroundColor: ThemeService().isDarkMode 
                  ? const Color(0xFF2C2C2E) 
                  : const Color(0xFFF2F2F7),
              thumbColor: ThemeService().isDarkMode 
                  ? const Color(0xFF48484A) 
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 