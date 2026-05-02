import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../monedas/catalogo_screen.dart';
import '../subasta/detalle_subasta_screen.dart';
import '../chat/lista_chats_screen.dart';
import '../perfil/perfil_screen.dart';
import '../vendedores/vendedores_recomendados_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice de la pestaña activa
  int _indicePestana = 0;

  // Lista de pantallas de la barra de navegación
  final List<Widget> _pantallas = [
    const CatalogoScreen(),
    const DetalleSubastaScreen(),
    const ListaChatsScreen(),
    const VendedoresRecomendadosScreen(),
    const PerfilScreen(),
  ];

  final _monedaService = MonedaService();
  StreamSubscription? _subastaSubscription;

  @override
  void initState() {
    super.initState();
    // Escoltador global de subastes guanyades
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final miUid = authProvider.usuarioFirebase?.uid;
      
      if (miUid != null) {
        _subastaSubscription = _monedaService.obtenerSubastasGanadas(miUid).listen((subastas) {
          if (!mounted) return;
          final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
          for (final subasta in subastas) {
            if (!carritoProvider.estaEnCarrito(subasta.monedaId)) {
              carritoProvider.agregarItemDeSubasta(subasta);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subastaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Muestra la pantalla activa según el índice
      body: _pantallas[_indicePestana],

      // Botón flotante para publicar moneda nueva
      floatingActionButton: _indicePestana <= 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFB8860B),
              foregroundColor: Colors.white,
              onPressed: () {
                if (_indicePestana == 0) {
                  context.push('/publicar-venta');
                } else if (_indicePestana == 1) {
                  context.push('/publicar-subasta');
                }
              },
              child: const Icon(Icons.add),
            )
          : null,

      // Barra de navegación inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indicePestana,
        onDestinationSelected: (indice) {
          setState(() => _indicePestana = indice);
        },
        indicatorColor: const Color(0xFFB8860B).withOpacity(0.2),
        destinations: [
          // Pestaña catálogo
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront, color: Color(0xFFB8860B)),
            label: AppLocalizations.of(context)!.cataleg,
          ),
          // Pestaña subastas
          NavigationDestination(
            icon: const Icon(Icons.gavel_outlined),
            selectedIcon: const Icon(Icons.gavel, color: Color(0xFFB8860B)),
            label: AppLocalizations.of(context)!.subhastes,
          ),
          // Pestaña chats
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat, color: Color(0xFFB8860B)),
            label: AppLocalizations.of(context)!.xats,
          ),
          // Pestaña vendedores recomendados
          NavigationDestination(
            icon: const Icon(Icons.star_outlined),
            selectedIcon: const Icon(Icons.star, color: Color(0xFFB8860B)),
            label: AppLocalizations.of(context)!.topVenedors,
          ),
          // Pestaña perfil
          NavigationDestination(
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person, color: Color(0xFFB8860B)),
            label: AppLocalizations.of(context)!.perfil,
          ),
        ],
      ),
    );
  }
}
