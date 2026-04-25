import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/carrito_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: const AppRouterWidget(),
    );
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
    // Creamos el router una sola vez. Como estamos dentro de AppRouterWidget
    // que es hijo de MultiProvider, podemos acceder a AuthProvider con context.read.
    _router = createRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado inicial de carga para mostrar el loader
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.cargandoInicial) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFFAF7F2),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8860B),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}