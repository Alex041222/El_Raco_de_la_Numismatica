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
import 'screens/vendedores/vendedores_recomendados_screen.dart';
GoRouter createRouter(BuildContext context) {
  return GoRouter(
    // Ruta inicial de la app
    initialLocation: '/login',

    // Redirección automática según el estado de autenticación
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final estaLogueado = authProvider.estaLogueado;
      final enLogin = state.matchedLocation == '/login';
      final enRegister = state.matchedLocation == '/register';
      final enCompletarPerfil = state.matchedLocation == '/completar-perfil';

      // Si no está logueado y no está en login o register, redirige a login
      if (!estaLogueado && !enLogin && !enRegister) return '/login';

      // Si está logueado y está en login o register, redirige a home
      if (estaLogueado && (enLogin || enRegister)) return '/home';

      // Si está en completar perfil no redirigir aunque esté logueado
      if (enCompletarPerfil) return null;

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
    ],
  );
}