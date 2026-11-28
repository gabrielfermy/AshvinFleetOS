enum PasswordStrengthLevel { empty, weak, fair, good, strong }

/// Domain model for NIST / OWASP password security evaluation
class PasswordStrengthResult {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecial;

  const PasswordStrengthResult({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
  });

  int get score {
    int s = 0;
    if (hasMinLength) s++;
    if (hasUppercase && hasLowercase) s++;
    if (hasDigit) s++;
    if (hasSpecial) s++;
    return s;
  }

  PasswordStrengthLevel get level {
    if (!hasMinLength && score == 0) return PasswordStrengthLevel.empty;
    switch (score) {
      case 0:
      case 1:
        return PasswordStrengthLevel.weak;
      case 2:
        return PasswordStrengthLevel.fair;
      case 3:
        return PasswordStrengthLevel.good;
      case 4:
      default:
        return PasswordStrengthLevel.strong;
    }
  }

  /// Industry standard compliance: 8+ chars and contains mixed case, digits, and symbols
  bool get isSecure => hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;
}

/// Evaluator enforcing industry password complexity rules
class PasswordStrengthValidator {
  static final _uppercaseRegex = RegExp(r'[A-Z]');
  static final _lowercaseRegex = RegExp(r'[a-z]');
  static final _digitRegex = RegExp(r'[0-9]');
  static final _specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_+\-=~\[\]\\\/]');

  static PasswordStrengthResult evaluate(String password) {
    return PasswordStrengthResult(
      hasMinLength: password.length >= 8,
      hasUppercase: _uppercaseRegex.hasMatch(password),
      hasLowercase: _lowercaseRegex.hasMatch(password),
      hasDigit: _digitRegex.hasMatch(password),
      hasSpecial: _specialRegex.hasMatch(password),
    );
  }
}
