import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../models/moneda_venta_model.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  // Instancia del servicio de monedas
  final _monedaService = MonedaService();

  // Texto de búsqueda para filtrar monedas
  final _busquedaController = TextEditingController();
  String _textoBusqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Catálogo'),
        actions: [
          // Botón carrito con badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/carrito'),
              ),
              if (carritoProvider.cantidad > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${carritoProvider.cantidad}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por emisor, país, periodo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() => _textoBusqueda = value.toLowerCase());
              },
            ),
          ),

          // Lista de monedas en venta
          Expanded(
            child: StreamBuilder<List<MonedaVenta>>(
              stream: _monedaService.obtenerMonedasVenta(),
              builder: (context, snapshot) {
                // Estado de carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB8860B),
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Sin datos
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No hay monedas en venta',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar por texto de búsqueda
                final monedas = snapshot.data!.where((moneda) {
                  if (_textoBusqueda.isEmpty) return true;
                  return moneda.emisor.toLowerCase().contains(_textoBusqueda) ||
                      moneda.pais.toLowerCase().contains(_textoBusqueda) ||
                      moneda.periodo.toLowerCase().contains(_textoBusqueda);
                }).toList();

                if (monedas.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Grid de monedas
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,       // 2 columnas
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,  // proporción de cada tarjeta
                  ),
                  itemCount: monedas.length,
                  itemBuilder: (context, index) {
                    final moneda = monedas[index];
                    return _TarjetaMoneda(
                      moneda: moneda,
                      enCarrito: carritoProvider.estaEnCarrito(moneda.monedaId),
                      onAgregar: () => carritoProvider.agregarItem(moneda),
                      onTap: () => context.push(
                        '/detalle-moneda/${moneda.monedaId}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de tarjeta de moneda para el grid
class _TarjetaMoneda extends StatelessWidget {
  final MonedaVenta moneda;
  final bool enCarrito;
  final VoidCallback onAgregar;
  final VoidCallback onTap;

  const _TarjetaMoneda({
    required this.moneda,
    required this.enCarrito,
    required this.onAgregar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la moneda
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: moneda.imagenes.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: moneda.imagenes.first,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Placeholder mientras carga la imagen
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFB8860B),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.monetization_on,
                    size: 60,
                    color: Colors.grey,
                  ),
                )
                    : const Center(
                  child: Icon(
                    Icons.monetization_on,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Información de la moneda
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emisor y país
                  Text(
                    '${moneda.emisor} - ${moneda.pais}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Periodo
                  Text(
                    moneda.periodo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Precio y botón agregar al carrito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${moneda.precio.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFB8860B),
                        ),
                      ),
                      // Botón agregar al carrito
                      GestureDetector(
                        onTap: enCarrito ? null : onAgregar,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: enCarrito
                                ? Colors.grey.shade300
                                : const Color(0xFFB8860B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            enCarrito
                                ? Icons.check
                                : Icons.add_shopping_cart,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}