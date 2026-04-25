import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../services/chat_service.dart';
import '../../services/usuario_service.dart';
import '../../models/moneda_venta_model.dart';
import '../../models/usuario_model.dart';
import '../l10n/app_localizations.dart';

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
  final PageController _pageController = PageController();
  late Future<MonedaVenta?> _monedaFuture;

  @override
  void initState() {
    super.initState();
    _monedaFuture = _monedaService.obtenerMonedaVenta(widget.monedaId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Abrir chat con el vendedor
  Future<void> _abrirChat(String vendedorId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    // No se puede abrir chat con uno mismo
    if (miUid == vendedorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noChatearContigo)),
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
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorChat}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      body: FutureBuilder<MonedaVenta?>(
        future: _monedaFuture,
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          // Error o no encontrada
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(AppLocalizations.of(context)!.monedaNoEncontrada));
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
                expandedHeight: 350,
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: _imagenActiva == 0 ? null : Text(
                    moneda.nom,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFFB8860B) 
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Carrusel de imágenes
                      PageView.builder(
                        controller: _pageController,
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
                      // Nom de la moneda
                      Text(
                        moneda.nom,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

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
                              moneda.disponible ? AppLocalizations.of(context)!.disponible : AppLocalizations.of(context)!.venut,
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

                      // Vendedor
                      FutureBuilder<Usuario?>(
                        future: UsuarioService().obtenerUsuario(moneda.vendedorId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: snapshot.data!.fotoPerfil.isNotEmpty
                                      ? CachedNetworkImageProvider(snapshot.data!.fotoPerfil)
                                      : null,
                                  child: snapshot.data!.fotoPerfil.isEmpty
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  snapshot.data!.nombreUsuario,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Datos de la moneda
                      _SeccionDatos(
                        titulo: AppLocalizations.of(context)!.infoGeneral,
                        datos: {
                          AppLocalizations.of(context)!.pais: moneda.pais,
                          AppLocalizations.of(context)!.periodo: moneda.periodo,
                          AppLocalizations.of(context)!.unidadMonetaria: moneda.unidadMonetaria,
                        },
                      ),
                      const SizedBox(height: 12),

                      _SeccionDatos(
                        titulo: AppLocalizations.of(context)!.caractFisicas,
                        datos: {
                          AppLocalizations.of(context)!.composicion: moneda.composicion,
                          AppLocalizations.of(context)!.peso: '${moneda.peso} g',
                          AppLocalizations.of(context)!.diametro: '${moneda.diametro} mm',
                          AppLocalizations.of(context)!.grosor: '${moneda.grosor} mm',
                          AppLocalizations.of(context)!.forma: moneda.forma,
                          AppLocalizations.of(context)!.tecnicaAcuniacion: moneda.tecnicaAcuniacion,
                          AppLocalizations.of(context)!.estadoConservacion: moneda.estadoConservacion,
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
                                ? AppLocalizations.of(context)!.anadidoCarrito
                                : AppLocalizations.of(context)!.agregarCarrito),
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
                            label: Text(AppLocalizations.of(context)!.contactarVendedor),
                          ),
                        ),
                      ],

                      // Si es propia mostramos mensaje
                      if (esPropia)
                        Card(
                          elevation: 0,
                          color: Colors.grey.withOpacity(0.1),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                AppLocalizations.of(context)!.estaMonedaEsTuya,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
    ),
    );
  }
}