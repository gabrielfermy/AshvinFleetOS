import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/l10n/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_service.dart';
import 'core/widgets/afos_scaffold.dart';

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
      body: _buildCurrentView(l10n),
    );
  }

  Widget _buildCurrentView(AppLocalizations l10n) {
    switch (_navIndex) {
      case 0:
        return _buildCardView(l10n.navCatalog, l10n.packageSelfDrive, Icons.directions_car);
      case 1:
        return _buildCardView(l10n.navMyBookings, l10n.statusBooked, Icons.calendar_today);
      case 2:
        return _buildCardView(l10n.navFieldTasks, l10n.btnCheckOut, Icons.assignment);
      case 3:
      default:
        return _buildCardView(l10n.navAdminDashboard, l10n.msgAuditProtected, Icons.dashboard);
    }
  }

  Widget _buildCardView(String title, String subtitle, IconData icon) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: AppTheme.accentTeal),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
