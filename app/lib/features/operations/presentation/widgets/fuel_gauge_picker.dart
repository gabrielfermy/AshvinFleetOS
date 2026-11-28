import 'package:flutter/material.dart';
import '../../../../core/theme/afos_colors.dart';

/// 8-bar fuel gauge level selector (Scale 1/8 to 8/8)
class FuelGaugePicker extends StatelessWidget {
  final int selectedLevel; // 1 to 8
  final ValueChanged<int> onLevelChanged;
  final String label;

  const FuelGaugePicker({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
    this.label = 'Level Bahan Bakar (BBM)',
  });

  Color _getBarColor(int barIndex) {
    if (barIndex > selectedLevel) return AfosColors.borderSlate;
    if (selectedLevel <= 2) return AfosColors.crimsonAlert;
    if (selectedLevel <= 4) return AfosColors.warmAmber;
    return AfosColors.emeraldVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AfosColors.primaryNavy,
              ),
            ),
            Text(
              '$selectedLevel / 8 (${(selectedLevel / 8 * 100).toInt()}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getBarColor(selectedLevel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(8, (index) {
            final barNumber = index + 1;
            final isSelected = barNumber <= selectedLevel;
            final color = _getBarColor(barNumber);

            return Expanded(
              child: GestureDetector(
                onTap: () => onLevelChanged(barNumber),
                child: Container(
                  height: 28,
                  margin: EdgeInsets.only(right: index < 7 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? color : AfosColors.borderSlate,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$barNumber',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AfosColors.mutedSlate,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
