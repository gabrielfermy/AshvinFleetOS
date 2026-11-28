import 'package:flutter/material.dart';
import '../theme/afos_colors.dart';
import '../theme/afos_typography.dart';

enum BadgeType { vehicleStatus, serviceType, auditStatus, generic }

/// Standard semantic status badge component conforming to AFOS Brand Suite
class AfosStatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;

  const AfosStatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.generic,
    this.icon,
    this.color,
    this.backgroundColor,
  });

  /// Factory constructor for Vehicle Status
  factory AfosStatusBadge.vehicleStatus(String status, {String? localizedLabel}) {
    return AfosStatusBadge(
      text: localizedLabel ?? status,
      type: BadgeType.vehicleStatus,
    );
  }

  /// Factory constructor for Service Package Type
  factory AfosStatusBadge.serviceType(String serviceType, {String? localizedLabel}) {
    final isSelfDrive = serviceType.toUpperCase() == 'SELF_DRIVE';
    return AfosStatusBadge(
      text: localizedLabel ?? (isSelfDrive ? 'Lepas Kunci' : 'Dengan Sopir'),
      type: BadgeType.serviceType,
      icon: isSelfDrive ? Icons.vpn_key_outlined : Icons.sports_motorsports_outlined,
    );
  }

  /// Factory constructor for Audit & KYC Status
  factory AfosStatusBadge.auditStatus(String status, {String? localizedLabel}) {
    return AfosStatusBadge(
      text: localizedLabel ?? status,
      type: BadgeType.auditStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = AfosStatusColors.of(context);
    final badgeStyle = _resolveBadgeStyle(statusColors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? badgeStyle.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (color ?? badgeStyle.fg).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || badgeStyle.icon != null) ...[
            Icon(
              icon ?? badgeStyle.icon,
              size: 13,
              color: color ?? badgeStyle.fg,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AfosTypography.licensePlate.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color ?? badgeStyle.fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  _ResolvedBadgeStyle _resolveBadgeStyle(AfosStatusColors colors) {
    switch (type) {
      case BadgeType.vehicleStatus:
        switch (text.toUpperCase()) {
          case 'AVAILABLE':
          case 'TERSEDIA':
            return _ResolvedBadgeStyle(
              fg: colors.available,
              bg: colors.availableBg,
              icon: Icons.check_circle_outline,
            );
          case 'ON_RENTAL':
          case 'DISEWA':
            return _ResolvedBadgeStyle(
              fg: colors.rented,
              bg: colors.rentedBg,
              icon: Icons.directions_car_outlined,
            );
          case 'MAINTENANCE_REQUIRED':
          case 'PERLU SERVIS':
            return _ResolvedBadgeStyle(
              fg: colors.alert,
              bg: colors.alertBg,
              icon: Icons.build_circle_outlined,
            );
          case 'BOOKED':
          case 'DIPESAN':
          default:
            return _ResolvedBadgeStyle(
              fg: colors.warning,
              bg: colors.warningBg,
              icon: Icons.schedule_outlined,
            );
        }

      case BadgeType.serviceType:
        final isSelfDrive = text.toLowerCase().contains('lepas') || text.toUpperCase() == 'SELF_DRIVE';
        return _ResolvedBadgeStyle(
          fg: isSelfDrive ? AfosColors.primaryNavy : AfosColors.jogjaTeal,
          bg: (isSelfDrive ? AfosColors.primaryNavy : AfosColors.jogjaTeal).withValues(alpha: 0.08),
          icon: isSelfDrive ? Icons.vpn_key_outlined : Icons.drive_eta_outlined,
        );

      case BadgeType.auditStatus:
        if (text.toUpperCase().contains('VERIF') || text.toUpperCase().contains('LOLOS')) {
          return _ResolvedBadgeStyle(
            fg: colors.verified,
            bg: colors.verifiedBg,
            icon: Icons.verified_user_outlined,
          );
        }
        return _ResolvedBadgeStyle(
          fg: colors.warning,
          bg: colors.warningBg,
          icon: Icons.pending_actions_outlined,
        );

      case BadgeType.generic:
      default:
        return _ResolvedBadgeStyle(
          fg: AfosColors.charcoalInk,
          bg: AfosColors.slateMist,
        );
    }
  }
}

class _ResolvedBadgeStyle {
  final Color fg;
  final Color bg;
  final IconData? icon;

  const _ResolvedBadgeStyle({
    required this.fg,
    required this.bg,
    this.icon,
  });
}
