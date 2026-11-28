import 'package:flutter/material.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

/// Step widget for email OTP verification in registration modal
class AuthOtpStep extends StatefulWidget {
  final String email;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String> onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const AuthOtpStep({
    super.key,
    required this.email,
    required this.isLoading,
    this.errorMessage,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  @override
  State<AuthOtpStep> createState() => _AuthOtpStepState();
}

class _AuthOtpStepState extends State<AuthOtpStep> {
  final _otpController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.authOtpTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.authOtpSubtitle}\n${widget.email}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        // Simulated Mailpit note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 20, color: AppTheme.accentTeal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${l10n.authOtpSimulatedHint} (Mailpit: :54324)',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (widget.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(color: Colors.red.shade800, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // 6-digit OTP Input
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: l10n.authOtpCode,
            counterText: '',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.isLoading ? null : () => widget.onVerify(_otpController.text.trim()),
          child: widget.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l10n.authOtpSubmit),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.isLoading ? null : widget.onResend,
          child: Text(l10n.authOtpResend),
        ),
      ],
    );
  }
}
