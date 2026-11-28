import 'package:flutter/material.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/afos_colors.dart';
import '../../domain/password_strength.dart';

/// Interactive UI widget displaying real-time password strength meter and criteria
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrengthResult result;

  const PasswordStrengthIndicator({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final level = result.level;

    if (level == PasswordStrengthLevel.empty) {
      return const SizedBox.shrink();
    }

    final (levelLabel, levelColor, activeSegments) = switch (level) {
      PasswordStrengthLevel.weak => (l10n.authPasswordWeak, AfosColors.crimsonAlert, 1),
      PasswordStrengthLevel.fair => (l10n.authPasswordFair, AfosColors.warmAmber, 2),
      PasswordStrengthLevel.good => (l10n.authPasswordGood, AfosColors.lightBlue, 3),
      PasswordStrengthLevel.strong => (l10n.authPasswordStrong, AfosColors.emeraldVerified, 4),
      PasswordStrengthLevel.empty => ('', Colors.transparent, 0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Strength bar
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index < activeSegments;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? levelColor : AfosColors.borderSlate,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              levelLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: levelColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Compact requirement checklist
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _criterionItem(l10n.authPasswordReqLength, result.hasMinLength),
            _criterionItem(l10n.authPasswordReqUppercase, result.hasUppercase),
            _criterionItem(l10n.authPasswordReqLowercase, result.hasLowercase),
            _criterionItem(l10n.authPasswordReqNumber, result.hasDigit),
            _criterionItem(l10n.authPasswordReqSpecial, result.hasSpecial),
          ],
        ),
      ],
    );
  }

  Widget _criterionItem(String label, bool isSatisfied) {
    final color = isSatisfied ? AfosColors.emeraldVerified : AfosColors.mutedSlate;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSatisfied ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
