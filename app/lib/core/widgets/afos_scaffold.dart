import 'package:flutter/material.dart';
import '../localization/l10n/app_localizations.dart';
import 'responsive_layout.dart';
import '../theme/app_theme.dart';

class AfosScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = ResponsiveLayout.getDeviceType(context) == DeviceScreenType.compact;

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
          _buildDesktopSidebar(context, l10n),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(navDestinations[selectedIndex].label),
                actions: [
                  _buildLocaleButton(),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryNavy,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
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

  Widget _buildDesktopSidebar(BuildContext context, AppLocalizations l10n) {
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
        color: isSelected ? AppTheme.primaryNavy.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.primaryNavy : Colors.grey[600],
            size: 20,
          ),
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
