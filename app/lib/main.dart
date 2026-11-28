import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/l10n/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_service.dart';
import 'core/widgets/afos_scaffold.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/auth_modal.dart';
import 'features/catalog/presentation/catalog_screen.dart';
import 'features/catalog/domain/vehicle.dart';
import 'features/booking/presentation/booking_modal.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('id'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: AfosApp()));
}

class AfosApp extends ConsumerWidget {
  const AfosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    return AfosScaffold(
      selectedIndex: _navIndex,
      currentLocaleCode: currentLocale.languageCode,
      onToggleLocale: () {
        final nextLocale = currentLocale.languageCode == 'id'
            ? const Locale('en')
            : const Locale('id');
        ref.read(localeProvider.notifier).state = nextLocale;
      },
      onDestinationSelected: (index) {
        setState(() => _navIndex = index);
      },
      body: _buildCurrentView(l10n, authState.profile),
    );
  }

  Widget _buildCurrentView(AppLocalizations l10n, dynamic profile) {
    switch (_navIndex) {
      case 0:
        return CatalogScreen(
          onSelectVehicle: (vehicle) => _handleSelectVehicle(vehicle, profile),
        );
      case 1:
        return _buildBookingsView(l10n, profile);
      case 2:
        return _buildFieldOperationsView(l10n, profile);
      case 3:
      default:
        return _buildDashboardView(l10n, profile);
    }
  }

  void _handleSelectVehicle(Vehicle vehicle, dynamic profile) {
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in or register to book a vehicle.')),
      );
      showDialog(context: context, builder: (_) => const AuthModal());
      return;
    }

    showDialog(
      context: context,
      builder: (_) => BookingModal(vehicle: vehicle),
    );
  }

  Widget _buildBookingsView(AppLocalizations l10n, dynamic profile) {
    if (profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.navMyBookings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => showDialog(context: context, builder: (_) => const AuthModal()),
              child: Text(l10n.authSignIn),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_added, size: 40, color: AppTheme.accentTeal),
              const SizedBox(height: 12),
              Text(
                'AFOS-B2C-202611-001',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text('Toyota All New Avanza • Status: ON_RENTAL', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('View Digital Agreement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldOperationsView(AppLocalizations l10n, dynamic profile) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment, size: 48, color: AppTheme.primaryNavy),
              const SizedBox(height: 16),
              Text(l10n.navFieldTasks, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Mobile Check-Out / Check-In Inspection Console', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView(AppLocalizations l10n, dynamic profile) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dashboard, size: 48, color: AppTheme.accentTeal),
              const SizedBox(height: 16),
              Text(l10n.navAdminDashboard, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.msgAuditProtected, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
