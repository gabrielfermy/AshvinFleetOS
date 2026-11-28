import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/l10n/app_localizations.dart';
import 'responsive_layout.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/auth_modal.dart';

class AfosScaffold extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final VoidCallback onToggleLocale;
  final String currentLocaleCode;

  const AfosScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.onToggleLocale,
    required this.currentLocaleCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = ResponsiveLayout.getDeviceType(context) == DeviceScreenType.compact;
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;

    final navDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.directions_car_outlined),
        selectedIcon: const Icon(Icons.directions_car),
        label: l10n.navCatalog,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_today_outlined),
        selectedIcon: const Icon(Icons.calendar_today),
        label: l10n.navMyBookings,
      ),
      NavigationDestination(
        icon: const Icon(Icons.assignment_outlined),
        selectedIcon: const Icon(Icons.assignment),
        label: l10n.navFieldTasks,
      ),
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.navAdminDashboard,
      ),
    ];

    if (isCompact) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            _buildLocaleButton(),
            _buildAuthAction(context, ref, profile, l10n, compact: true),
          ],
        ),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: navDestinations,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _buildDesktopSidebar(context, ref, l10n, profile),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(navDestinations[selectedIndex].label),
                actions: [
                  _buildLocaleButton(),
                  const SizedBox(width: 8),
                  _buildAuthAction(context, ref, profile, l10n, compact: false),
                  const SizedBox(width: 16),
                ],
              ),
              body: body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleButton() {
    return TextButton.icon(
      onPressed: onToggleLocale,
      icon: const Icon(Icons.language, size: 18),
      label: Text(
        currentLocaleCode.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAuthAction(
      BuildContext context, WidgetRef ref, dynamic profile, AppLocalizations l10n,
      {required bool compact}) {
    if (profile == null) {
      return TextButton.icon(
        onPressed: () => showDialog(context: context, builder: (_) => const AuthModal()),
        icon: const Icon(Icons.login, size: 18),
        label: Text(l10n.authSignIn),
      );
    }

    return PopupMenuButton<String>(
      tooltip: profile.fullName,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.accentTeal,
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(profile.fullName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(profile.role, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ],
        ),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Text('${l10n.authLoggedInAs}: ${profile.fullName} (${profile.role})'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.authSignOut, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'logout') {
          ref.read(authControllerProvider.notifier).signOut();
        }
      },
    );
  }

  Widget _buildDesktopSidebar(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, dynamic profile) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const Text(
                          'Yogyakarta Hub',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _sidebarItem(0, Icons.directions_car_outlined, l10n.navCatalog),
                  _sidebarItem(1, Icons.calendar_today_outlined, l10n.navMyBookings),
                  _sidebarItem(2, Icons.assignment_outlined, l10n.navFieldTasks),
                  _sidebarItem(3, Icons.dashboard_outlined, l10n.navAdminDashboard),
                ],
              ),
            ),
            if (profile != null) ...[
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryNavy,
                      child: Text(
                        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.fullName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text(profile.role, style: const TextStyle(fontSize: 10, color: AppTheme.accentTeal, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppTheme.primaryNavy.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: isSelected ? AppTheme.primaryNavy : Colors.grey[600], size: 20),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryNavy : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          dense: true,
          selected: isSelected,
          onTap: () => onDestinationSelected(index),
        ),
      ),
    );
  }
}
