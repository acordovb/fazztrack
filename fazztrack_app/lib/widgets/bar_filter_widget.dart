import 'package:fazztrack_app/constants/colors_constants.dart';
import 'package:fazztrack_app/models/bar_model.dart';
import 'package:flutter/material.dart';

class BarFilterWidget extends StatelessWidget {
  final List<BarModel> bars;
  final String? selectedBarId;
  final Function(String) onBarSelected;

  const BarFilterWidget({
    super.key,
    required this.bars,
    required this.selectedBarId,
    required this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bars.length,
          itemBuilder: (context, index) {
            final bar = bars[index];
            final isSelected = selectedBarId == bar.id;

            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  bar.nombre,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppColors.primaryDarkBlue
                            : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onBarSelected(bar.id);
                  }
                },
                backgroundColor: AppColors.card,
                selectedColor: AppColors.primaryTurquoise,
                checkmarkColor: AppColors.primaryDarkBlue,
                side: BorderSide(
                  color:
                      isSelected ? AppColors.primaryTurquoise : AppColors.card,
                  width: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
