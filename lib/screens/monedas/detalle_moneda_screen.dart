import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../services/chat_service.dart';
import '../../models/moneda_venta_model.dart';

class DetalleMonedaScreen extends StatefulWidget {
  final String monedaId;

  const DetalleMonedaScreen({super.key, required this.monedaId});

  @override
  State<DetalleMonedaScreen> createState() => _DetalleMonedaScreenState();
}

class _DetalleMonedaScreenState extends State<DetalleMonedaScreen> {
  final _monedaService = MonedaService();
  final _chatService = ChatService();

  // Índice de la imagen activa en el carrusel
  int _imagenActiva = 0;

  // Abrir chat con el vendedor
  Future<void> _abrirChat(String vendedorId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    // No se puede abrir chat con uno mismo
    if (miUid == vendedorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes chatear contigo mismo')),
      );
      return;
    }

    try {
      // Obtener o crear el chat entre los dos usuarios
      final chatId = await _chatService.obtenerOCrearChat(
        miUid,
        vendedorId,
        widget.monedaId,
      );

      if (mounted) context.push('/chat/$chatId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: FutureBuilder<MonedaVenta?>(
        future: _monedaService.obtenerMonedaVenta(widget.monedaId),
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          // Error o no encontrada
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Moneda no encontrada'));
          }

          final moneda = snapshot.data!;
          final esPropia = moneda.vendedorId ==
              authProvider.usuarioFirebase?.uid;
          final enCarrito =
          carritoProvider.estaEnCarrito(moneda.monedaId);

          return CustomScrollView(
            slivers: [
              // AppBar con carrusel de imágenes
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFFB8860B),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Carrusel de imágenes
                      PageView.builder(
                        itemCount: moneda.imagenes.isNotEmpty
                            ? moneda.imagenes.length
                            : 1,
                        onPageChanged: (index) {
                          setState(() => _imagenActiva = index);
                        },
                        itemBuilder: (context, index) {
                          if (moneda.imagenes.isEmpty) {
                            return const Center(
                              child: Icon(Icons.monetization_on,
                                  size: 80, color: Colors.white),
                            );
                          }
                          return CachedNetworkImage(
                            imageUrl: moneda.imagenes[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.monetization_on,
                                size: 80, color: Colors.white),
                          );
                        },
                      ),

                      // Indicadores del carrusel
                      if (moneda.imagenes.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              moneda.imagenes.length,
                                  (index) => Container(
                                margin:
                                const EdgeInsets.symmetric(horizontal: 3),
                                width: _imagenActiva == index ? 12 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _imagenActiva == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Contenido de la moneda
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Precio y disponibilidad
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${moneda.precio.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: moneda.disponible
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              moneda.disponible ? 'Disponible' : 'Vendida',
                              style: TextStyle(
                                color: moneda.disponible
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Datos de la moneda
                      _SeccionDatos(
                        titulo: 'Información general',
                        datos: {
                          'Emisor': moneda.emisor,
                          'País': moneda.pais,
                          'Periodo': moneda.periodo,
                          'Unidad monetaria': moneda.unidadMonetaria,
                        },
                      ),
                      const SizedBox(height: 12),

                      _SeccionDatos(
                        titulo: 'Características físicas',
                        datos: {
                          'Composición': moneda.composicion,
                          'Peso': '${moneda.peso} g',
                          'Diámetro': '${moneda.diametro} mm',
                          'Grosor': '${moneda.grosor} mm',
                          'Forma': moneda.forma,
                          'Técnica de acuñación': moneda.tecnicaAcuniacion,
                          'Estado de conservación': moneda.estadoConservacion,
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botones de acción
                      if (!esPropia && moneda.disponible) ...[
                        // Botón agregar al carrito
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: enCarrito
                                ? null
                                : () => carritoProvider.agregarItem(moneda),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8860B),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(enCarrito
                                ? Icons.check
                                : Icons.add_shopping_cart),
                            label: Text(enCarrito
                                ? 'Añadido al carrito'
                                : 'Agregar al carrito'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón contactar vendedor
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _abrirChat(moneda.vendedorId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB8860B),
                              side: const BorderSide(
                                  color: Color(0xFFB8860B)),
                            ),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Contactar vendedor'),
                          ),
                        ),
                      ],

                      // Si es propia mostramos mensaje
                      if (esPropia)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Esta moneda es tuya',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget para mostrar una sección de datos de la moneda
class _SeccionDatos extends StatelessWidget {
  final String titulo;
  final Map<String, String> datos;

  const _SeccionDatos({required this.titulo, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
          const Divider(),

          // Filas de datos
          ...datos.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Valor
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}