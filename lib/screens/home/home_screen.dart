import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../monedas/catalogo_screen.dart';
import '../subasta/detalle_subasta_screen.dart';
import '../chat/lista_chats_screen.dart';
import '../perfil/perfil_screen.dart';
import '../vendedores/vendedores_recomendados_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      // Muestra la pantalla activa según el índice
      body: _pantallas[_indicePestana],

      // Botón flotante para publicar moneda nueva
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        onPressed: () {
          // Muestra un dialogo para elegir tipo de publicación
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Publicar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.sell, color: Color(0xFFB8860B)),
                  title: const Text('Venta directa'),
                  subtitle: const Text('Precio fijo'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/publicar-venta');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.gavel, color: Color(0xFFB8860B)),
                  title: const Text('Subasta'),
                  subtitle: const Text('Con tiempo límite'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/publicar-subasta');
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      // Barra de navegación inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indicePestana,
        onDestinationSelected: (indice) {
          setState(() => _indicePestana = indice);
        },
        indicatorColor: const Color(0xFFB8860B).withOpacity(0.2),
        destinations: [
          // Pestaña catálogo
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFFB8860B)),
            label: 'Catálogo',
          ),
          // Pestaña subastas
          const NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel, color: Color(0xFFB8860B)),
            label: 'Subastas',
          ),
          // Pestaña chats
          const NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat, color: Color(0xFFB8860B)),
            label: 'Chats',
          ),
          // Pestaña vendedores recomendados
          const NavigationDestination(
            icon: Icon(Icons.star_outlined),
            selectedIcon: Icon(Icons.star, color: Color(0xFFB8860B)),
            label: 'Top vendedores',
          ),
          // Pestaña perfil con badge del carrito
          NavigationDestination(
            icon: Badge(
              isLabelVisible: carritoProvider.cantidad > 0,
              label: Text('${carritoProvider.cantidad}'),
              child: const Icon(Icons.person_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: carritoProvider.cantidad > 0,
              label: Text('${carritoProvider.cantidad}'),
              child: const Icon(Icons.person, color: Color(0xFFB8860B)),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}