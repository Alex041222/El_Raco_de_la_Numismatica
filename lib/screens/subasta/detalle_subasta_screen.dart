import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/moneda_service.dart';
import '../../services/subasta_service.dart';
import '../../models/moneda_subasta_model.dart';
import '../../models/puja_model.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/imagen_widget.dart';

class DetalleSubastaScreen extends StatefulWidget {
  final String? monedaId;

  const DetalleSubastaScreen({super.key, this.monedaId});

  @override
  State<DetalleSubastaScreen> createState() => _DetalleSubastaScreenState();
}

class _DetalleSubastaScreenState extends State<DetalleSubastaScreen> {
  final _monedaService = MonedaService();
  final _subastaService = SubastaService();
  final _pujaController = TextEditingController();
  int _imagenActiva = 0;
  final PageController _pageController = PageController();
  Stream<MonedaSubasta?>? _subastaStream;

  @override
  void initState() {
    super.initState();
    if (widget.monedaId != null) {
      _subastaStream = _monedaService.escucharSubasta(widget.monedaId!);
      // Comprobar si la subasta ha caducado al abrir la pantalla
      _subastaService.comprobarYCerrarSubasta(widget.monedaId!);
    }
  }

  @override
  void dispose() {
    _pujaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Mostrar dialogo para realizar una puja
  void _mostrarDialogoPuja(MonedaSubasta moneda) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    // No se puede pujar en la propia subasta
    if (miUid == moneda.vendedorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.noPujarTuya)),
      );
      return;
    }

    _pujaController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.realizarPuja),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.pujaActual}: ${moneda.precioActual.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8860B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context)!.tuPujaDebeSerMayor} ${moneda.precioActual.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pujaController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tuPujaEuro,
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
              autofocus: true,
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
              final importe = double.tryParse(_pujaController.text.trim());
              if (importe == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Introduce un importe válido')),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await _subastaService.realizarPuja(
                  moneda.monedaId,
                  miUid,
                  importe,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Puja realizada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
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
            child: Text(AppLocalizations.of(context)!.pujar),
          ),
        ],
      ),
    );
  }

  // Calcular tiempo restante de la subasta
  String _tiempoRestante(DateTime fechaFin) {
    final ahora = DateTime.now();
    if (ahora.isAfter(fechaFin)) return 'Subasta terminada';

    final diferencia = fechaFin.difference(ahora);
    if (diferencia.inDays > 0) {
      return '${diferencia.inDays}d ${diferencia.inHours % 24}h restantes';
    } else if (diferencia.inHours > 0) {
      return '${diferencia.inHours}h ${diferencia.inMinutes % 60}m restantes';
    } else {
      return '${diferencia.inMinutes}m restantes';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay monedaId mostramos lista de subastas activas
    if (widget.monedaId == null) {
      return _ListaSubastas(
        monedaService: _monedaService,
        subastaService: _subastaService,
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: StreamBuilder<MonedaSubasta?>(
        stream: _subastaStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(AppLocalizations.of(context)!.subastaNoEncontrada));
          }

          final moneda = snapshot.data!;
          final esPropia =
              moneda.vendedorId == authProvider.usuarioFirebase?.uid;
          final haTerminado = DateTime.now().isAfter(moneda.fechaFin);

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
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFB8860B), size: 20),
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
                          return ImagenWidget(
                            imagen: moneda.imagenes[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
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

                      // Precio actual y tiempo restante
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8860B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFB8860B).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            // Precio actual
                            Text(
                              '${moneda.precioActual.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB8860B),
                              ),
                            ),
                            const Text(
                              'Puja actual',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),

                            // Tiempo restante
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  haTerminado
                                      ? Icons.timer_off
                                      : Icons.timer_outlined,
                                  size: 16,
                                  color: haTerminado
                                      ? Colors.red
                                      : const Color(0xFFB8860B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _tiempoRestante(moneda.fechaFin),
                                  style: TextStyle(
                                    color: haTerminado
                                        ? Colors.red
                                        : const Color(0xFFB8860B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Fecha fin
                            Text(
                              'Termina el ${DateFormat('dd/MM/yyyy HH:mm').format(moneda.fechaFin)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
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
                          AppLocalizations.of(context)!.estadoConservacion:
                          moneda.estadoConservacion,
                        },
                      ),
                      const SizedBox(height: 12),

                      // Historial de pujas
                      _HistorialPujas(
                        monedaId: moneda.monedaId,
                        subastaService: _subastaService,
                      ),
                      const SizedBox(height: 16),

                      // Botón pujar
                      if (!esPropia && !haTerminado)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _mostrarDialogoPuja(moneda),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8860B),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.gavel),
                            label: Text(
                              AppLocalizations.of(context)!.realizarPuja,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      // Mensaje si la subasta ha terminado
                      if (haTerminado)
                        Builder(builder: (context) {
                          final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
                          final miUid = authProvider.usuarioFirebase?.uid;
                          final esGanador = moneda.ganadorId.isNotEmpty && moneda.ganadorId == miUid;

                          // Si soy el ganador y no tengo el item en el carrito, lo agrego automáticamente
                          if (esGanador && !carritoProvider.estaEnCarrito(moneda.monedaId)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              carritoProvider.agregarItemDeSubasta(moneda);
                            });
                          }

                          if (esGanador) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B6508), Color(0xFFB8860B)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '¡Has ganado esta subasta!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Precio final: ${moneda.precioActual.toStringAsFixed(2)} €',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => context.go('/carrito'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFB8860B),
                                    ),
                                    icon: const Icon(Icons.shopping_cart),
                                    label: Text(AppLocalizations.of(context)!.irCarritoPagar),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              moneda.ganadorId.isNotEmpty
                                  ? 'Subasta terminada. Ya tiene ganador.'
                                  : 'Esta subasta ha terminado sin pujas.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),

                      // Mensaje si es propia
                      if (esPropia && !haTerminado)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.estaEsTuSubasta,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),

                      const SizedBox(height: 24),
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

// Widget lista de subastas activas (pantalla principal de subastas)
class _ListaSubastas extends StatelessWidget {
  final MonedaService monedaService;
  final SubastaService subastaService;

  const _ListaSubastas({
    required this.monedaService,
    required this.subastaService,
  });

  @override
  Widget build(BuildContext context) {
    final usuarioService = UsuarioService();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subastasActivas),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<MonedaSubasta>>(
        stream: monedaService.obtenerSubastasActivas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay subastas activas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final moneda = snapshot.data![index];
              final haTerminado = DateTime.now().isAfter(moneda.fechaFin);

              // Si ha terminado la cerramos automáticamente
              if (haTerminado) {
                subastaService.comprobarYCerrarSubasta(moneda.monedaId);
              }

              return GestureDetector(
                onTap: () =>
                    context.push('/detalle-subasta/${moneda.monedaId}'),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      // Imagen de la moneda
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        child: moneda.imagenes.isNotEmpty
                            ? ImagenWidget(
                          imagen: moneda.imagenes.first,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
                        ),
                      ),

                      // Información de la subasta
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moneda.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                moneda.pais,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                moneda.periodo,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<Usuario?>(
                                future: usuarioService.obtenerUsuario(moneda.vendedorId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const SizedBox.shrink();
                                  return Row(
                                    children: [
                                      const Icon(Icons.person, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          snapshot.data!.nombreUsuario,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              // Precio actual
                              Text(
                                '${moneda.precioActual.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Tiempo restante
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(moneda.fechaFin),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Icono de flecha
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget sección de datos (igual que en detalle_moneda_screen)
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
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
          const Divider(),
          ...datos.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
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

// Widget historial de pujas
class _HistorialPujas extends StatelessWidget {
  final String monedaId;
  final SubastaService subastaService;

  const _HistorialPujas({
    required this.monedaId,
    required this.subastaService,
  });

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
          Text(
            AppLocalizations.of(context)!.historialPujas,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
          const Divider(),
          StreamBuilder<List<Puja>>(
            stream: subastaService.obtenerPujas(monedaId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFB8860B)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    AppLocalizations.of(context)!.noHayPujas,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final puja = snapshot.data![index];
                  final esPrimera = index == 0; // la puja más alta

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      esPrimera ? Icons.emoji_events : Icons.person_outlined,
                      color: esPrimera
                          ? const Color(0xFFB8860B)
                          : Colors.grey,
                      size: 20,
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${puja.importe.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: esPrimera
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: esPrimera
                                ? const Color(0xFFB8860B)
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FutureBuilder<Usuario?>(
                            future: UsuarioService().obtenerUsuario(puja.usuarioId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              return Text(
                                snapshot.data!.nombreUsuario,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(puja.fechaCreacion),
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: esPrimera
                        ? Text(
                      AppLocalizations.of(context)!.ganando,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}
