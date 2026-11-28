import 'package:flutter/material.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Supported phone country dial codes
class CountryDialCode {
  final String flag;
  final String dialCode;
  final String isoCode;

  const CountryDialCode(this.flag, this.dialCode, this.isoCode);
}

const List<CountryDialCode> supportedDialCodes = [
  CountryDialCode('🇮🇩', '+62', 'ID'),
  CountryDialCode('🇲🇾', '+60', 'MY'),
  CountryDialCode('🇸🇬', '+65', 'SG'),
  CountryDialCode('🇦🇺', '+61', 'AU'),
  CountryDialCode('🇺🇸', '+1', 'US'),
  CountryDialCode('🇬🇧', '+44', 'GB'),
  CountryDialCode('🇯🇵', '+81', 'JP'),
  CountryDialCode('🇩🇪', '+49', 'DE'),
];

/// Seamless, unified Phone input field with embedded country selector
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedDialCode;
  final ValueChanged<String> onDialCodeChanged;
  final String? errorText;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedDialCode,
    required this.onDialCodeChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: l10n.authPhone,
        hintText: '812-3456-7890',
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDialCode,
                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF64748B)),
                  items: supportedDialCodes.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.dialCode,
                      child: Text(
                        '${c.flag} ${c.dialCode}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onDialCodeChanged(val);
                  },
                ),
              ),
              const SizedBox(width: 4),
              Container(
                height: 24,
                width: 1,
                color: const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
