import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data/services/local_session_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'app/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionService = LocalSessionService();
  final authProvider = AuthProvider(sessionService);
  
  // Restore session on app start
  await authProvider.restore();

  runApp(SevenFTrendsApp(authProvider: authProvider));
}

class SevenFTrendsApp extends StatelessWidget {
  final AuthProvider authProvider;
  
  const SevenFTrendsApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = createRouter(auth);
          
          return MaterialApp.router(
            title: '7ftrends',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              primaryColor: const Color(0xFF8B5CF6),
              textTheme: GoogleFonts.poppinsTextTheme(),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
