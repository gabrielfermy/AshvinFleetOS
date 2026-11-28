import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/auth/domain/user_profile.dart';

void main() {
  group('UserProfile Domain Tests', () {
    test('parses UserProfile from json correctly', () {
      final json = {
        'id': 'test-uuid-123',
        'role': 'CUSTOMER',
        'full_name': 'Budi Santoso',
        'phone_number': '+6281234567890',
        'id_card_number': '3471012345670001',
        'driver_license_number': 'SIM-1234-5678',
        'nationality': 'ID',
        'emergency_contact_name': 'Dewi Santoso',
        'emergency_contact_phone': '+6281234567899',
        'preferred_locale': 'id',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'test-uuid-123');
      expect(profile.fullName, 'Budi Santoso');
      expect(profile.firstName, 'Budi');
      expect(profile.lastName, 'Santoso');
      expect(profile.role, 'CUSTOMER');
      expect(profile.isCustomer, isTrue);
      expect(profile.isManagement, isFalse);
      expect(profile.emergencyContactName, 'Dewi Santoso');
      expect(profile.emergencyContactPhone, '+6281234567899');
    });

    test('role getters differentiate customer, staff, and management', () {
      const admin = UserProfile(
        id: 'admin-1',
        role: 'ADMIN',
        fullName: 'Admin Guy',
        phoneNumber: '+62811111111',
        nationality: 'ID',
        preferredLocale: 'id',
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.isManagement, isTrue);
      expect(admin.isCustomer, isFalse);

      const owner = UserProfile(
        id: 'owner-1',
        role: 'OWNER',
        fullName: 'Owner Guy',
        phoneNumber: '+62822222222',
        nationality: 'ID',
        preferredLocale: 'id',
      );
      expect(owner.isOwner, isTrue);
      expect(owner.isManagement, isTrue);

      const staff = UserProfile(
        id: 'staff-1',
        role: 'FIELD_STAFF',
        fullName: 'Field Staff Guy',
        phoneNumber: '+62833333333',
        nationality: 'ID',
        preferredLocale: 'id',
      );
      expect(staff.isFieldStaff, isTrue);
      expect(staff.isManagement, isFalse);
    });

    test('converts to json faithfully', () {
      const profile = UserProfile(
        id: 'id-001',
        role: 'CUSTOMER',
        fullName: 'John Doe',
        phoneNumber: '+123456789',
        idCardNumber: 'PASSPORT-US-999',
        nationality: 'US',
        preferredLocale: 'en',
      );

      final json = profile.toJson();
      expect(json['id'], 'id-001');
      expect(json['full_name'], 'John Doe');
      expect(json['nationality'], 'US');
      expect(json['preferred_locale'], 'en');
    });
  });
}
