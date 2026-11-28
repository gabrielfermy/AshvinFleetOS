import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_controller.dart';
import 'widgets/auth_otp_step.dart';
import 'widgets/phone_input_field.dart';

class AuthModal extends ConsumerStatefulWidget {
  const AuthModal({super.key});

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> {
  bool _isSignUp = false;
  bool _showOtpStep = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  String? _formValidationError;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String _selectedDialCode = '+62';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _fillDemo(String email, String pass) {
    _emailCtrl.text = email;
    _passCtrl.text = pass;
    setState(() => _formValidationError = null);
  }

  String _formatFullPhoneNumber() {
    final rawDigits = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final cleanDigits = rawDigits.replaceFirst(RegExp(r'^0+'), '');
    return '$_selectedDialCode$cleanDigits';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _showOtpStep
              ? AuthOtpStep(
                  email: _emailCtrl.text.trim(),
                  isLoading: authState.isLoading,
                  errorMessage: authState.errorMessage,
                  onVerify: (otp) => _handleVerifyOtp(otp, l10n),
                  onResend: () => ref.read(authControllerProvider.notifier).resendOtp(_emailCtrl.text.trim()),
                  onBack: () => setState(() => _showOtpStep = false),
                )
              : _buildMainForm(l10n, authState),
        ),
      ),
    );
  }

  Widget _buildMainForm(AppLocalizations l10n, AuthStateData authState) {
    final errorMessage = _formValidationError ?? authState.errorMessage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isSignUp ? l10n.authSignUp : l10n.authSignIn,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        const SizedBox(height: 16),
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(errorMessage, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
          ),
          const SizedBox(height: 16),
        ],
        if (_isSignUp) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameCtrl,
                  decoration: InputDecoration(labelText: l10n.authFirstName, border: const OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastNameCtrl,
                  decoration: InputDecoration(labelText: l10n.authLastName, border: const OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PhoneInputField(
            controller: _phoneCtrl,
            selectedDialCode: _selectedDialCode,
            onDialCodeChanged: (code) => setState(() => _selectedDialCode = code),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.authEmail,
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: l10n.authPassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirmPass,
            decoration: InputDecoration(
              labelText: l10n.authConfirmPassword,
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: authState.isLoading ? null : () => _handleSubmit(l10n),
          child: authState.isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isSignUp ? l10n.authSignUp : l10n.authSignIn),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _isSignUp = !_isSignUp;
            _formValidationError = null;
          }),
          child: Text(_isSignUp ? l10n.authHaveAccount : l10n.authNoAccount),
        ),
        if (!_isSignUp) ...[
          const Divider(height: 32),
          Text(l10n.authQuickDemo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _demoChip(l10n.roleCustomer, 'customer@gmail.com', 'AshvinCust2026!'),
              _demoChip(l10n.roleFieldStaff, 'staff.budi@ashvin.id', 'AshvinStaff2026!'),
              _demoChip(l10n.roleAdmin, 'admin@ashvin.id', 'AshvinAdmin2026!'),
              _demoChip(l10n.roleOwner, 'owner@ashvin.id', 'AshvinOwner2026!'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _demoChip(String role, String email, String pass) {
    return ActionChip(
      avatar: const Icon(Icons.bolt, size: 16, color: AppTheme.accentTeal),
      label: Text(role, style: const TextStyle(fontSize: 12)),
      onPressed: () => _fillDemo(email, pass),
    );
  }

  Future<void> _handleSubmit(AppLocalizations l10n) async {
    setState(() => _formValidationError = null);

    if (_isSignUp) {
      if (_firstNameCtrl.text.trim().isEmpty) {
        setState(() => _formValidationError = l10n.authFirstName);
        return;
      }
      if (_passCtrl.text.length < 6) {
        setState(() => _formValidationError = l10n.authPasswordTooShort);
        return;
      }
      if (_passCtrl.text != _confirmPassCtrl.text) {
        setState(() => _formValidationError = l10n.authPasswordMismatch);
        return;
      }
      if (_phoneCtrl.text.trim().isEmpty) {
        setState(() => _formValidationError = l10n.authPhoneInvalid);
        return;
      }

      final fullName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
      final fullPhone = _formatFullPhoneNumber();

      final ok = await ref.read(authControllerProvider.notifier).signUp(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            fullName: fullName,
            phoneNumber: fullPhone,
            nationality: _selectedDialCode == '+62' ? 'ID' : 'FOREIGNER',
          );

      if (ok && mounted) {
        setState(() => _showOtpStep = true);
      }
    } else {
      final ok = await ref.read(authControllerProvider.notifier).signIn(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (ok && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.authLoggedInAs}: ${_emailCtrl.text}')),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp(String otp, AppLocalizations l10n) async {
    if (otp.length != 6) {
      setState(() => _formValidationError = l10n.authOtpInvalid);
      return;
    }

    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(
          email: _emailCtrl.text.trim(),
          token: otp,
        );

    if (ok && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authRegisterSuccess)),
      );
    }
  }
}
