import 'package:flutter/material.dart';
import '../config/app_config.dart';

enum DeviceScreenType { compact, medium, expanded }

/// Adaptive Layout Helper identifying target screen form-factor
class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    required this.expanded,
  });

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppConfig.compactBreakpoint) {
      return DeviceScreenType.compact;
    } else if (width < AppConfig.mediumBreakpoint) {
      return DeviceScreenType.medium;
    }
    return DeviceScreenType.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.compact:
        return compact;
      case DeviceScreenType.medium:
        return medium ?? expanded;
      case DeviceScreenType.expanded:
        return expanded;
    }
  }
}
