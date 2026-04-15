import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/moneda_service.dart';
import '../../services/subasta_service.dart';
import '../../models/moneda_subasta_model.dart';
import '../../models/puja_model.dart';

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

  @override
  void initState() {
    super.initState();
    // Comprobar si la subasta ha caducado al abrir la pantalla
    if (widget.monedaId != null) {
      _subastaService.comprobarYCerrarSubasta(widget.monedaId!);
    }
  }

  @override
  void dispose() {
    _pujaController.dispose();
    super.dispose();
  }

  // Mostrar dialogo para realizar una puja
  void _mostrarDialogoPuja(MonedaSubasta moneda) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    // No se puede pujar en la propia subasta
    if (miUid == moneda.vendedorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No puedes pujar en tu propia subasta')),
      );
      return;
    }

    _pujaController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realizar puja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio actual: ${moneda.precioActual.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8860B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tu puja debe ser mayor que ${moneda.precioActual.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pujaController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tu puja (€)',
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
            child: const Text('Cancelar'),
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
            child: const Text('Pujar'),
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
      backgroundColor: const Color(0xFFFAF7F2),
      body: StreamBuilder<MonedaSubasta?>(
        stream: _monedaService.escucharSubasta(widget.monedaId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Subasta no encontrada'));
          }

          final moneda = snapshot.data!;
          final esPropia =
              moneda.vendedorId == authProvider.usuarioFirebase?.uid;
          final haTerminado = DateTime.now().isAfter(moneda.fechaFin);

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
                          'Estado de conservación':
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
                            label: const Text(
                              'Realizar puja',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      // Mensaje si la subasta ha terminado
                      if (haTerminado)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Text(
                            'Esta subasta ha terminado',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Mensaje si es propia
                      if (esPropia && !haTerminado)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Esta es tu subasta',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Subastas activas'),
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Imagen de la moneda
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                        child: moneda.imagenes.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: moneda.imagenes.first,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFB8860B)),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
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
                                '${moneda.emisor} - ${moneda.pais}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                moneda.periodo,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
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
          const Text(
            'Historial de pujas',
            style: TextStyle(
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
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Aún no hay pujas',
                    style: TextStyle(color: Colors.grey),
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
                    title: Text(
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
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm')
                          .format(puja.fechaCreacion),
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: esPrimera
                        ? const Text(
                      'Ganando',
                      style: TextStyle(
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
    );
  }
}