import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/auth/domain/password_strength.dart';

void main() {
  group('PasswordStrengthValidator Tests', () {
    test('evaluates empty password as empty level with zero score', () {
      final res = PasswordStrengthValidator.evaluate('');
      expect(res.level, PasswordStrengthLevel.empty);
      expect(res.score, 0);
      expect(res.isSecure, isFalse);
    });

    test('flags short passwords even if characters are diverse', () {
      final res = PasswordStrengthValidator.evaluate('Ab1!');
      expect(res.hasMinLength, isFalse);
      expect(res.hasUppercase, isTrue);
      expect(res.hasLowercase, isTrue);
      expect(res.hasDigit, isTrue);
      expect(res.hasSpecial, isTrue);
      expect(res.isSecure, isFalse);
      expect(res.level, isNot(PasswordStrengthLevel.strong));
    });

    test('flags weak password with only lowercase characters', () {
      final res = PasswordStrengthValidator.evaluate('password');
      expect(res.hasMinLength, isTrue);
      expect(res.hasUppercase, isFalse);
      expect(res.hasLowercase, isTrue);
      expect(res.hasDigit, isFalse);
      expect(res.hasSpecial, isFalse);
      expect(res.isSecure, isFalse);
      expect(res.level, PasswordStrengthLevel.weak);
    });

    test('evaluates fair password with letters and numbers but no special chars or mixed case', () {
      final res = PasswordStrengthValidator.evaluate('password123');
      expect(res.hasMinLength, isTrue);
      expect(res.hasDigit, isTrue);
      expect(res.hasSpecial, isFalse);
      expect(res.isSecure, isFalse);
      expect(res.level, PasswordStrengthLevel.fair);
    });

    test('evaluates good password with uppercase, lowercase, numbers but no special symbols', () {
      final res = PasswordStrengthValidator.evaluate('Password123');
      expect(res.hasMinLength, isTrue);
      expect(res.hasUppercase, isTrue);
      expect(res.hasLowercase, isTrue);
      expect(res.hasDigit, isTrue);
      expect(res.hasSpecial, isFalse);
      expect(res.isSecure, isFalse);
      expect(res.level, PasswordStrengthLevel.good);
    });

    test('confirms NIST & OWASP compliance for strong password with all criteria met', () {
      final res = PasswordStrengthValidator.evaluate('AshvinFleet2026!');
      expect(res.hasMinLength, isTrue);
      expect(res.hasUppercase, isTrue);
      expect(res.hasLowercase, isTrue);
      expect(res.hasDigit, isTrue);
      expect(res.hasSpecial, isTrue);
      expect(res.score, 4);
      expect(res.level, PasswordStrengthLevel.strong);
      expect(res.isSecure, isTrue);
    });
  });
}
