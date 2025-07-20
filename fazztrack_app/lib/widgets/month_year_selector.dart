import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:flutter/material.dart';

class MonthYearSelector extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Function(int month, int year) onChanged;

  const MonthYearSelector({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.onChanged,
  });

  @override
  State<MonthYearSelector> createState() => _MonthYearSelectorState();
}

class _MonthYearSelectorState extends State<MonthYearSelector> {
  late int selectedMonth;
  late int selectedYear;

  final List<Map<String, dynamic>> months = [
    {'value': 1, 'name': 'Enero'},
    {'value': 2, 'name': 'Febrero'},
    {'value': 3, 'name': 'Marzo'},
    {'value': 4, 'name': 'Abril'},
    {'value': 5, 'name': 'Mayo'},
    {'value': 6, 'name': 'Junio'},
    {'value': 7, 'name': 'Julio'},
    {'value': 8, 'name': 'Agosto'},
    {'value': 9, 'name': 'Septiembre'},
    {'value': 10, 'name': 'Octubre'},
    {'value': 11, 'name': 'Noviembre'},
    {'value': 12, 'name': 'Diciembre'},
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  void didUpdateWidget(MonthYearSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth ||
        widget.initialYear != oldWidget.initialYear) {
      selectedMonth = widget.initialMonth;
      selectedYear = widget.initialYear;
    }
  }

  List<int> _getYearRange() {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 2;
    final endYear = currentYear + 2;
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  void _onMonthChanged(int? newMonth) {
    if (newMonth != null && newMonth != selectedMonth) {
      setState(() {
        selectedMonth = newMonth;
      });
      widget.onChanged(selectedMonth, selectedYear);
    }
  }

  void _onYearChanged(int? newYear) {
    if (newYear != null && newYear != selectedYear) {
      setState(() {
        selectedYear = newYear;
      });
      widget.onChanged(selectedMonth, selectedYear);
    }
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTurquoise.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryTurquoise.withAlpha(50),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: AppColors.primaryTurquoise,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextStyle(
            color: AppColors.primaryTurquoise,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: AppColors.background,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primaryTurquoise,
            size: 18,
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText(item),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selector de mes
        _buildDropdown<int>(
          value: selectedMonth,
          items: months.map((month) => month['value'] as int).toList(),
          displayText:
              (month) =>
                  months.firstWhere((m) => m['value'] == month)['name']
                      as String,
          onChanged: _onMonthChanged,
          hint: 'Mes',
        ),

        const SizedBox(width: 12),

        // Selector de año
        _buildDropdown<int>(
          value: selectedYear,
          items: _getYearRange(),
          displayText: (year) => year.toString(),
          onChanged: _onYearChanged,
          hint: 'Año',
        ),
      ],
    );
  }
}
