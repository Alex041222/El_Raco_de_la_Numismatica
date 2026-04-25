import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../services/pedido_service.dart';
import '../../services/resena_service.dart';
import '../../services/usuario_service.dart';
import '../../models/moneda_venta_model.dart';
import '../../models/moneda_subasta_model.dart';
import '../../models/pedido_model.dart';
import '../../models/item_pedido_model.dart';
import '../../models/resena_model.dart';
import '../../models/usuario_model.dart';
import '../l10n/app_localizations.dart';

class PerfilScreen extends StatefulWidget {
  // Si uid es null mostramos nuestro propio perfil
  // Si uid tiene valor mostramos el perfil de otro usuario
  final String? uid;

  const PerfilScreen({super.key, this.uid});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  final _monedaService = MonedaService();
  final _pedidoService = PedidoService();
  final _resenaService = ResenaService();
  final _usuarioService = UsuarioService();

  // Controlador de pestañas
  late TabController _tabController;

  // Controladores para el formulario de reseña
  final _comentarioController = TextEditingController();
  String _tipoResena = 'positivo';

  @override
  void initState() {
    super.initState();
    // 4 pestañas: en venta, subastas, compras, reseñas
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  // Mostrar dialogo para dejar reseña
  void _mostrarDialogoResena(String vendedorId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    _comentarioController.clear();
    _tipoResena = 'positivo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.dejarResena),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector positivo / negativo
              Row(
                children: [
                  // Botón positivo
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setStateDialog(() => _tipoResena = 'positivo'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tipoResena == 'positivo'
                              ? Colors.green
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 18,
                              color: _tipoResena == 'positivo'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.positivo,
                              style: TextStyle(
                                color: _tipoResena == 'positivo'
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botón negativo
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setStateDialog(() => _tipoResena = 'negativo'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _tipoResena == 'negativo'
                              ? Colors.red
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_down,
                              size: 18,
                              color: _tipoResena == 'negativo'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.negativo,
                              style: TextStyle(
                                color: _tipoResena == 'negativo'
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo comentario
              TextField(
                controller: _comentarioController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.comentario,
                  border: const OutlineInputBorder(),
                  hintText: AppLocalizations.of(context)!.escribeComentario,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_comentarioController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Escribe un comentario')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  await _resenaService.crearResena(
                    Resena(
                      resenaId: '',
                      autorId: miUid,
                      vendedorId: vendedorId,
                      comentario: _comentarioController.text.trim(),
                      tipo: _tipoResena,
                      fechaCreacion: DateTime.now(),
                    ),
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reseña enviada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8860B),
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.enviar),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = authProvider.usuarioFirebase;

    // Si no hay usuario (ej. cerrando sesión), mostramos un cargando para evitar pantalla roja
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB8860B))),
      );
    }

    final miUid = firebaseUser.uid;

    // Si uid es null mostramos nuestro perfil
    final perfilUid = widget.uid ?? miUid;
    final esMiPerfil = perfilUid == miUid;

    return Scaffold(
      body: StreamBuilder<Usuario?>(
        stream: _usuarioService.escucharUsuario(perfilUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          final usuario = snapshot.data;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: const Color(0xFFB8860B),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: !esMiPerfil,
                actions: [
                  if (esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push('/ajustes'),
                    ),
                  if (esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/editar-perfil'),
                    ),
                  if (esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) context.go('/login');
                      },
                    ),
                  if (!esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.rate_review_outlined),
                      onPressed: () => _mostrarDialogoResena(perfilUid),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? [const Color(0xFF1A1406), const Color(0xFF2D2208)]
                            : [const Color(0xFF8B6508), const Color(0xFFB8860B)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ESPACIADOR PARA BAJAR EL CONTENIDO
                        const SizedBox(height: 60),

                        // Foto de perfil con borde decorativo
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white24,
                            backgroundImage: usuario?.fotoPerfil.isNotEmpty == true
                                ? CachedNetworkImageProvider(usuario!.fotoPerfil)
                                : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nombre de usuario con sombra para legibilidad
                        Text(
                          usuario?.nombreUsuario ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        // Puntuación mejor organizada
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (usuario?.puntuacion ?? 0) >= 0
                                    ? Icons.stars
                                    : Icons.trending_down,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${usuario?.puntuacion ?? 0} ${AppLocalizations.of(context)!.reputacion}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Biografia
                        if (usuario?.biografia != null && usuario!.biografia.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              usuario.biografia,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],

                        // Direcció
                        if (usuario?.direccion != null && usuario!.direccion.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 13, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(
                                usuario.direccion,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20), // Espacio antes de las tabs
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  isScrollable: true,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.misVentas),
                    Tab(text: AppLocalizations.of(context)!.subhastes),
                    Tab(text: AppLocalizations.of(context)!.compres),
                    Tab(text: AppLocalizations.of(context)!.ressenyes),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña monedas en venta
                _MonedasEnVenta(
                  vendedorId: perfilUid,
                  monedaService: _monedaService,
                ),

                // Pestaña subastas
                _SubastasUsuario(
                  vendedorId: perfilUid,
                  monedaService: _monedaService,
                ),

                // Pestaña compras (solo visible en mi perfil)
                esMiPerfil
                    ? _MisCompras(
                  compradorId: miUid,
                  pedidoService: _pedidoService,
                )
                    : const Center(
                  child: Text(
                    AppLocalizations.of(context)!.soloTusCompras,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                // Pestaña reseñas
                _Resenas(
                  vendedorId: perfilUid,
                  resenaService: _resenaService,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget pestaña monedas en venta
class _MonedasEnVenta extends StatelessWidget {
  final String vendedorId;
  final MonedaService monedaService;

  const _MonedasEnVenta({
    required this.vendedorId,
    required this.monedaService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MonedaVenta>>(
      stream: monedaService.obtenerMonedasVentaPorVendedor(vendedorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB8860B)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noHayMonedas,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final moneda = snapshot.data![index];
            return GestureDetector(
              onTap: () =>
                  context.push('/detalle-moneda/${moneda.monedaId}'),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: moneda.imagenes.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: moneda.imagenes.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFB8860B)),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
                        )
                            : const Center(
                          child: Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moneda.nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${moneda.precio.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: Color(0xFFB8860B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Badge disponible / vendida
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: moneda.disponible
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              moneda.disponible ? AppLocalizations.of(context)!.disponible : AppLocalizations.of(context)!.venut,
                              style: TextStyle(
                                fontSize: 10,
                                color: moneda.disponible
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget pestaña subastas del usuario
class _SubastasUsuario extends StatelessWidget {
  final String vendedorId;
  final MonedaService monedaService;

  const _SubastasUsuario({
    required this.vendedorId,
    required this.monedaService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MonedaSubasta>>(
      stream: monedaService.obtenerSubastasPorVendedor(vendedorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB8860B)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noHaySubastas,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final moneda = snapshot.data![index];
            final haTerminado = DateTime.now().isAfter(moneda.fechaFin);

            return GestureDetector(
              onTap: () => context
                  .push('/detalle-subasta/${moneda.monedaId}'),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                  children: [
                    // Imagen
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: moneda.imagenes.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: moneda.imagenes.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.monetization_on,
                            color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moneda.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${moneda.precioActual.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: Color(0xFFB8860B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            haTerminado
                                ? AppLocalizations.of(context)!.terminada
                                : '${AppLocalizations.of(context)!.termina}: ${DateFormat('dd/MM/yyyy').format(moneda.fechaFin)}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              haTerminado ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget pestaña mis compras
class _MisCompras extends StatelessWidget {
  final String compradorId;
  final PedidoService pedidoService;

  const _MisCompras({
    required this.compradorId,
    required this.pedidoService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pedido>>(
      stream: pedidoService.obtenerMisCompras(compradorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB8860B)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noHayCompras,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final pedido = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FutureBuilder<List<ItemPedido>>(
                  future: PedidoService().obtenerItemsPedido(pedido.pedidoId),
                  builder: (context, itemsSnapshot) {
                    final primerItem = itemsSnapshot.hasData && itemsSnapshot.data!.isNotEmpty 
                        ? itemsSnapshot.data!.first 
                        : null;

                    return Row(
                      children: [
                        // Foto del primer artículo
                        if (primerItem != null)
                          FutureBuilder<dynamic>(
                            future: primerItem.esSubasta 
                                ? MonedaService().obtenerMonedaSubasta(primerItem.monedaId)
                                : MonedaService().obtenerMonedaVenta(primerItem.monedaId),
                            builder: (context, monedaSnapshot) {
                              final foto = monedaSnapshot.hasData && (monedaSnapshot.data!.imagenes as List).isNotEmpty
                                  ? monedaSnapshot.data!.imagenes.first
                                  : null;
                              
                              return Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: foto != null
                                      ? CachedNetworkImage(
                                          imageUrl: foto,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.monetization_on, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        
                        // Información del pedido
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pedido #${pedido.pedidoId.substring(0, 8)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${pedido.total.toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      color: Color(0xFFB8860B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(pedido.fechaCreacion),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (pedido.direccionEnvio != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Envío a: ${pedido.direccionEnvio}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis),
                                  maxLines: 1,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget pestaña reseñas
class _Resenas extends StatelessWidget {
  final String vendedorId;
  final ResenaService resenaService;

  const _Resenas({
    required this.vendedorId,
    required this.resenaService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Resena>>(
      stream: resenaService.obtenerResenasDeVendedor(vendedorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFB8860B)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.capRessenya,
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final resena = snapshot.data![index];
            final esPositiva = resena.tipo == 'positivo';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: esPositiva
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono positivo / negativo
                  Icon(
                    esPositiva ? Icons.thumb_up : Icons.thumb_down,
                    color: esPositiva ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),

                  // Comentario, usuario y fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Usuario?>(
                          future: UsuarioService().obtenerUsuario(resena.autorId),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data?.nombreUsuario ?? 'Usuario',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFFB8860B),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Text(
                          resena.comentario,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(resena.fechaCreacion),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
}
