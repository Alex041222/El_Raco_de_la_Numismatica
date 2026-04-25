import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/pedido_service.dart';
import '../../models/pedido_model.dart';
import '../../models/item_pedido_model.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _pedidoService = PedidoService();
  final _direccionController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _direccionController.dispose();
    super.dispose();
  }

  // Confirmar la compra de todos los items del carrito
  Future<void> _confirmarCompra() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
    final uid = authProvider.usuarioFirebase!.uid;

    // Mostrar dialogo para introducir dirección (opcional)
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: ${carritoProvider.total.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB8860B),
              ),
            ),
            const SizedBox(height: 16),
            // Campo dirección opcional para simular envío
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección de envío (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Introduce tu dirección',
              ),
              maxLines: 2,
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
              Navigator.pop(context);
              setState(() => _cargando = true);

              try {
                // Agrupar items por vendedor para crear un pedido por vendedor
                final itemsPorVendedor = <String, List<dynamic>>{};
                for (final moneda in carritoProvider.items) {
                  if (!itemsPorVendedor.containsKey(moneda.vendedorId)) {
                    itemsPorVendedor[moneda.vendedorId] = [];
                  }
                  itemsPorVendedor[moneda.vendedorId]!.add(moneda);
                }

                // Crear un pedido por cada vendedor
                for (final entry in itemsPorVendedor.entries) {
                  final vendedorId = entry.key;
                  final monedas = entry.value;

                  // Calcular total de este vendedor
                  final total = monedas.fold<double>(
                      0, (suma, m) => suma + m.precio);

                  // Generar ID del pedido
                  final pedidoId = const Uuid().v4();

                  // Crear items del pedido
                  final items = monedas.map((m) => ItemPedido(
                    itemId: const Uuid().v4(),
                    pedidoId: pedidoId,
                    monedaId: m.monedaId,
                    precioUnitario: m.precio,
                    tituloSnapshot: m.nom,
                  )).toList();

                  // Crear pedido
                  final pedido = Pedido(
                    pedidoId: pedidoId,
                    compradorId: uid,
                    vendedorId: vendedorId,
                    total: total,
                    direccionEnvio: _direccionController.text.trim().isEmpty
                        ? null
                        : _direccionController.text.trim(),
                    fechaCreacion: DateTime.now(),
                  );

                  await _pedidoService.crearPedido(pedido, items);
                }

                // Vaciar el carrito después de comprar
                carritoProvider.vaciar();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra realizada correctamente!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al realizar la compra: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _cargando = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8860B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Carrito'),
        actions: [
          // Botón vaciar carrito
          if (carritoProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vaciar carrito'),
                    content: const Text(
                        '¿Estás seguro de que quieres vaciar el carrito?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          carritoProvider.vaciar();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Vaciar'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: carritoProvider.items.isEmpty
      // Carrito vacío
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Añade monedas desde el catálogo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
      // Lista de items del carrito
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: carritoProvider.items.length,
              itemBuilder: (context, index) {
                final moneda = carritoProvider.items[index];
                return Container(
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
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFB8860B)),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
                        )
                            : Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.monetization_on,
                              size: 40, color: Colors.grey),
                        ),
                      ),

                      // Información de la moneda
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
                              const SizedBox(height: 4),
                              Text(
                                moneda.periodo,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${moneda.precio.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB8860B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón eliminar del carrito
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () =>
                            carritoProvider.eliminar(moneda.monedaId),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Resumen del total y botón comprar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${carritoProvider.total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón confirmar compra
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _confirmarCompra,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8860B),
                      foregroundColor: Colors.white,
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text(
                      'Confirmar compra',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}