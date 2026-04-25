import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/completar_perfil_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/monedas/detalle_moneda_screen.dart';
import 'screens/monedas/publicar_venta_screen.dart';
import 'screens/monedas/publicar_subasta_screen.dart';
import 'screens/subasta/detalle_subasta_screen.dart';
import 'screens/carrito/carrito_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/perfil/perfil_screen.dart';
import 'screens/perfil/editar_perfil_screen.dart';
import 'screens/perfil/ajustes_screen.dart';
import 'screens/vendedores/vendedores_recomendados_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/login',
    // IMPORTANTE: Esto vincula el router con los cambios de AuthProvider
    refreshListenable: Provider.of<AuthProvider>(context, listen: false),

    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Si el AuthProvider aún está comprobando la sesión inicial de Firebase,
      // no hacemos ninguna redirección todavía para evitar saltos raros.
      if (authProvider.cargandoInicial) return null;

      final estaLogueado = authProvider.usuarioFirebase != null;
      final tienePerfil = authProvider.usuarioPerfil != null;

      final enLogin = state.matchedLocation == '/login';
      final enRegister = state.matchedLocation == '/register';
      final enCompletarPerfil = state.matchedLocation == '/completar-perfil';

      // 1. SI NO ESTÁ LOGUEADO
      if (!estaLogueado) {
        // Solo permitimos que esté en login o register
        if (!enLogin && !enRegister) return '/login';
        return null;
      }

      // 2. SI ESTÁ LOGUEADO
      if (estaLogueado) {
        // CASO A: No tiene perfil creado en Firestore (Usuario nuevo recién registrado)
        if (!tienePerfil) {
          // Si no está ya en la pantalla de completar perfil, lo obligamos a ir
          if (!enCompletarPerfil) return '/completar-perfil';
          return null;
        }

        // CASO B: Tiene perfil completo
        // Si intenta entrar a pantallas de Auth estando ya listo, lo mandamos al Home
        if (enLogin || enRegister || enCompletarPerfil) {
          return '/home';
        }
      }

      // En cualquier otro caso, que siga su ruta normal
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/completar-perfil',
        builder: (context, state) => const CompletarPerfilScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/carrito',
        builder: (context, state) => const CarritoScreen(),
      ),
      GoRoute(
        path: '/detalle-moneda/:id',
        builder: (context, state) => DetalleMonedaScreen(
          monedaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/publicar-venta',
        builder: (context, state) => const PublicarVentaScreen(),
      ),
      GoRoute(
        path: '/publicar-subasta',
        builder: (context, state) => const PublicarSubastaScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/detalle-subasta/:id',
        builder: (context, state) => DetalleSubastaScreen(
          monedaId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/perfil/:uid',
        builder: (context, state) => PerfilScreen(
          uid: state.pathParameters['uid'],
        ),
      ),
      GoRoute(
        path: '/editar-perfil',
        builder: (context, state) => const EditarPerfilScreen(),
      ),
      GoRoute(
        path: '/vendedores-recomendados',
        builder: (context, state) => const VendedoresRecomendadosScreen(),
      ),
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const AjustesScreen(),
      ),
    ],
  );
}