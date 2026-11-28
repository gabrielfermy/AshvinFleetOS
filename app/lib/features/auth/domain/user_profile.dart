/// User Profile domain entity mapped to user_profiles table in Supabase
class UserProfile {
  final String id;
  final String role; // 'CUSTOMER', 'FIELD_STAFF', 'ADMIN', 'OWNER'
  final String fullName;
  final String phoneNumber;
  final String? idCardNumber;
  final String? driverLicenseNumber;
  final String nationality;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String preferredLocale;

  const UserProfile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phoneNumber,
    this.idCardNumber,
    this.driverLicenseNumber,
    required this.nationality,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.preferredLocale,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'CUSTOMER',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      idCardNumber: json['id_card_number'] as String?,
      driverLicenseNumber: json['driver_license_number'] as String?,
      nationality: json['nationality'] as String? ?? 'ID',
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      preferredLocale: json['preferred_locale'] as String? ?? 'id',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'id_card_number': idCardNumber,
      'driver_license_number': driverLicenseNumber,
      'nationality': nationality,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'preferred_locale': preferredLocale,
    };
  }

  bool get isCustomer => role == 'CUSTOMER';
  bool get isFieldStaff => role == 'FIELD_STAFF';
  bool get isAdmin => role == 'ADMIN';
  bool get isOwner => role == 'OWNER';
  bool get isManagement => isAdmin || isOwner;
}
