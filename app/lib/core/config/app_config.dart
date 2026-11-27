/// Application configuration for Ashvin FleetOS (AFOS)
class AppConfig {
  static const String appName = 'Ashvin FleetOS';
  static const String appVersion = '0.1.0';

  // Supabase Local Docker Stack Ports
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );

  // Responsive Breakpoints (dp)
  static const double compactBreakpoint = 600.0;
  static const double mediumBreakpoint = 1024.0;

  // Maintenance & Oil Change Thresholds (KM)
  static const int maintenanceThresholdKm = 5000;
  static const int oilChangeThresholdKm = 10000;
  static const int taxReminderDaysBefore = 30;
}
