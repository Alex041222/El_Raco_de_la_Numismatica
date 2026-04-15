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
import '../../models/resena_model.dart';
import '../../models/usuario_model.dart';

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
          title: const Text('Dejar reseña'),
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
                              'Positivo',
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
                              'Negativo',
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
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  border: OutlineInputBorder(),
                  hintText: 'Escribe tu experiencia con este vendedor...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
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
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final miUid = authProvider.usuarioFirebase!.uid;

    // Si uid es null mostramos nuestro perfil
    final perfilUid = widget.uid ?? miUid;
    final esMiPerfil = perfilUid == miUid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
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
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFFB8860B),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: !esMiPerfil,
                actions: [
                  // Botón editar perfil si es el mío
                  if (esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/editar-perfil'),
                    ),
                  // Botón cerrar sesión si es el mío
                  if (esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) context.go('/login');
                      },
                    ),
                  // Botón dejar reseña si es otro usuario
                  if (!esMiPerfil)
                    IconButton(
                      icon: const Icon(Icons.rate_review_outlined),
                      onPressed: () => _mostrarDialogoResena(perfilUid),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: const Color(0xFFB8860B),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Foto de perfil
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                          Colors.white.withOpacity(0.3),
                          backgroundImage: usuario?.fotoPerfil.isNotEmpty == true
                              ? CachedNetworkImageProvider(
                              usuario!.fotoPerfil)
                              : const AssetImage(
                              'assets/images/default_avatar.png')
                          as ImageProvider,
                        ),
                        const SizedBox(height: 8),

                        // Nombre de usuario
                        Text(
                          usuario?.nombreUsuario ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Puntuación
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              (usuario?.puntuacion ?? 0) >= 0
                                  ? Icons.thumb_up
                                  : Icons.thumb_down,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${usuario?.puntuacion ?? 0} puntos',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'En venta'),
                    Tab(text: 'Subastas'),
                    Tab(text: 'Compras'),
                    Tab(text: 'Reseñas'),
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
                    'Solo puedes ver tus propias compras',
                    style: TextStyle(color: Colors.grey),
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
          return const Center(
            child: Text('No hay monedas en venta',
                style: TextStyle(color: Colors.grey)),
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            '${moneda.emisor} - ${moneda.pais}',
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
                              moneda.disponible ? 'Disponible' : 'Vendida',
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
          return const Center(
            child: Text('No hay subastas',
                style: TextStyle(color: Colors.grey)),
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            '${moneda.emisor} - ${moneda.pais}',
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
                                ? 'Terminada'
                                : 'Termina: ${DateFormat('dd/MM/yyyy').format(moneda.fechaFin)}',
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
          return const Center(
            child: Text('No has realizado ninguna compra',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final pedido = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
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
          return const Center(
            child: Text('No hay reseñas todavía',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final resena = snapshot.data![index];
            final esPositiva = resena.tipo == 'positivo';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: esPositiva
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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

                  // Comentario y fecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
            );
          },
        );
      },
    );
  }
}
