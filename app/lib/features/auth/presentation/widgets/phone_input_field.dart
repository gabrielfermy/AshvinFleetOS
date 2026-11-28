import 'package:flutter/material.dart';
import '../../../../core/localization/l10n/app_localizations.dart';

/// Data model representing supported phone country codes
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

/// Reusable Phone input field with country dial code dropdown
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country dial code dropdown container
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDialCode,
              items: supportedDialCodes.map((c) {
                return DropdownMenuItem<String>(
                  value: c.dialCode,
                  child: Text(
                    '${c.flag} ${c.dialCode}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onDialCodeChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Local phone digits text field
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.authPhone,
              hintText: '812-3456-7890',
              errorText: errorText,
              prefixIcon: const Icon(Icons.phone_outlined),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
