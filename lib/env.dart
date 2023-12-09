abstract class Env {
  static const String kSupabaseApiUrl = String.fromEnvironment(
    'SUPABASE_API_URL',
    defaultValue: 'https://ltbwtffhuhfnakyripjb.supabase.co',
  );
  static const String kSupabaseApiKey = String.fromEnvironment(
    'SUPABASE_API_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0Ynd0ZmZodWhmbmFreXJpcGpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA0NjMzOTgsImV4cCI6MjAxNjAzOTM5OH0'
        '.i3auA9wRIuAh8iBWA215-kHWrz5ChV_97RjxV-RTIqk',
  );
  static const String kYoloFastApiUrl = String.fromEnvironment(
    'YOLO_API_URL',
    defaultValue: 'https://possum-sunny-jaybird.ngrok-free.app',
  );
}
