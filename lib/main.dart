import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/carrito_provider.dart';
import 'providers/ajustes_provider.dart';
import 'router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final ajustesProvider = AjustesProvider();
  await ajustesProvider.cargarPreferencias();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider.value(value: ajustesProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppRouterWidget();
  }
}

class AppRouterWidget extends StatefulWidget {
  const AppRouterWidget({super.key});

  @override
  State<AppRouterWidget> createState() => _AppRouterWidgetState();
}

class _AppRouterWidgetState extends State<AppRouterWidget> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final ajustesProvider = Provider.of<AjustesProvider>(context);

    if (authProvider.cargandoInicial) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: ajustesProvider.themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: ajustesProvider.themeMode == ThemeMode.dark ? const Color(0xFF121212) : const Color(0xFFFAF7F2),
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFB8860B),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'El Racó de la Numismàtica',
      debugShowCheckedModeBanner: false,
      // LOCALIZACIONES
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ca'), // Català
        Locale('es'), // Castellano
        Locale('en'), // English
      ],
      locale: Locale(ajustesProvider.idioma),
      // MODO CLARO
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8860B),
          brightness: Brightness.light,
          surface: const Color(0xFFFAF7F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB8860B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      // MODO OSCURO
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8860B),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFB8860B),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
        ),
      ),
      themeMode: ajustesProvider.themeMode,
      routerConfig: _router,
    );
  }
}