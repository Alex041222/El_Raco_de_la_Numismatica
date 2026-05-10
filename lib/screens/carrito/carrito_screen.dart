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
import '../../l10n/app_localizations.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _pedidoService = PedidoService();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _numTarjetaController = TextEditingController();
  final _caducidadController = TextEditingController();
  final _cvvController = TextEditingController();
  final _checkoutFormKey = GlobalKey<FormState>();
  bool _cargando = false;

  @override
  void dispose() {
    _direccionController.dispose();
    _telefonoController.dispose();
    _numTarjetaController.dispose();
    _caducidadController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _confirmarCompra() async {
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);

    _direccionController.clear();
    _telefonoController.clear();
    _numTarjetaController.clear();
    _caducidadController.clear();
    _cvvController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSheet) => Padding(
          // Puja el contingut per sobre del teclat
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) => Column(
              children: [
                // Handle visual
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Títol
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Color(0xFFB8860B)),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(ctx)!.confirmarCompra,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Formulari scrollable
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Form(
                      key: _checkoutFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total a pagar
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8860B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${AppLocalizations.of(ctx)!.totalPagar}:',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${carritoProvider.total.toStringAsFixed(2)} €',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text('📦 ${AppLocalizations.of(ctx)!.envio}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),

                          // Adreça
                          TextFormField(
                            controller: _direccionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(ctx)!.direccionEnvio,
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: const OutlineInputBorder(),
                              hintText: AppLocalizations.of(ctx)!.hintDireccion,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? AppLocalizations.of(ctx)!.direccionObligatoria
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Telèfon
                          TextFormField(
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                            maxLength: 11, // 9 dígits + 2 espais
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(ctx)!.telefonoContacto,
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: const OutlineInputBorder(),
                              hintText: 'XXX XXX XXX',
                              counterText: '',
                            ),
                            onChanged: (v) {
                              final digits = v.replaceAll(' ', '');
                              // Agrupar en grups de 3: XXX XXX XXX
                              final formatted = digits
                                  .replaceAllMapped(RegExp(r'.{1,3}'), (m) => '${m.group(0)} ')
                                  .trim();
                              if (formatted != v) {
                                _telefonoController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                            },
                            validator: (v) {
                              final digits = (v ?? '').replaceAll(' ', '');
                              if (digits.isEmpty) return AppLocalizations.of(ctx)!.telefonoObligatorio;
                              if (digits.length < 9) return AppLocalizations.of(ctx)!.telefonoValido;
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          Text('💳 ${AppLocalizations.of(ctx)!.datosPago}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 10),

                          // Número targeta
                          TextFormField(
                            controller: _numTarjetaController,
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(ctx)!.numTarjeta,
                              prefixIcon: const Icon(Icons.credit_card),
                              border: const OutlineInputBorder(),
                              hintText: 'XXXX XXXX XXXX XXXX',
                              counterText: '',
                            ),
                            onChanged: (v) {
                              final digits = v.replaceAll(' ', '');
                              final formatted = digits.replaceAllMapped(RegExp(r'.{1,4}'), (m) => '${m.group(0)} ').trim();
                              if (formatted != v) {
                                _numTarjetaController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                            },
                            validator: (v) {
                              final digits = (v ?? '').replaceAll(' ', '');
                              if (digits.isEmpty) return AppLocalizations.of(ctx)!.introduce16;
                              if (digits.length != 16) return AppLocalizations.of(ctx)!.introduce16;
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              // Data caducitat
                              Expanded(
                                child: TextFormField(
                                  controller: _caducidadController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(ctx)!.caducidad,
                                    prefixIcon: const Icon(Icons.calendar_today, size: 18),
                                    border: const OutlineInputBorder(),
                                    hintText: 'MM/AA',
                                    counterText: '',
                                  ),
                                  onChanged: (v) {
                                    final digits = v.replaceAll('/', '');
                                    String formatted = digits;
                                    if (digits.length >= 3) {
                                      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
                                    }
                                    if (formatted != v) {
                                      _caducidadController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(offset: formatted.length),
                                      );
                                    }
                                  },
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Obligatori';
                                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v.trim()))
                                      return AppLocalizations.of(ctx)!.formatoMMAA;
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // CVV
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(ctx)!.cvv,
                                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                    border: const OutlineInputBorder(),
                                    hintText: '3-4 dígits',
                                    counterText: '',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Obligatori';
                                    if (v.trim().length < 3) return AppLocalizations.of(ctx)!.min3Digitos;
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Botons acció
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Color(0xFFB8860B)),
                                    foregroundColor: const Color(0xFFB8860B),
                                  ),
                                  child: Text(AppLocalizations.of(ctx)!.cancelar),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!_checkoutFormKey.currentState!.validate()) return;
                                    Navigator.pop(ctx);
                                    setState(() => _cargando = true);

                                    try {
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final uid = authProvider.usuarioFirebase!.uid;

                                      final itemsPorVendedor = <String, List<dynamic>>{};
                                      for (final moneda in carritoProvider.items) {
                                        if (!itemsPorVendedor.containsKey(moneda.vendedorId)) {
                                          itemsPorVendedor[moneda.vendedorId] = [];
                                        }
                                        itemsPorVendedor[moneda.vendedorId]!.add(moneda);
                                      }

                                      for (final entry in itemsPorVendedor.entries) {
                                        final vendedorId = entry.key;
                                        final monedas = entry.value;
                                        final total = monedas.fold<double>(0, (suma, m) => suma + m.precio);
                                        final pedidoId = const Uuid().v4();

                                        final items = monedas.map((m) => ItemPedido(
                                          itemId: const Uuid().v4(),
                                          pedidoId: pedidoId,
                                          monedaId: m.monedaId,
                                          precioUnitario: m.precio,
                                          tituloSnapshot: m.nom,
                                          esSubasta: carritoProvider.estaBloqueado(m.monedaId),
                                        )).toList();

                                        final pedido = Pedido(
                                          pedidoId: pedidoId,
                                          compradorId: uid,
                                          vendedorId: vendedorId,
                                          total: total,
                                          direccionEnvio: _direccionController.text.trim(),
                                          fechaCreacion: DateTime.now(),
                                        );

                                        await _pedidoService.crearPedido(pedido, items);
                                      }

                                      carritoProvider.vaciarTodo();

                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(context)!.compraCorrecta),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        context.pop();
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        String msg = e.toString().replaceAll('Exception: ', '');
                                        String translatedMsg = msg;
                                        if (msg == 'monedaNoDisponible') {
                                          translatedMsg = AppLocalizations.of(context)!.monedaNoDisponible;
                                        } else if (msg == 'monedaNoExiste') {
                                          translatedMsg = AppLocalizations.of(context)!.monedaNoExiste;
                                        } else {
                                          translatedMsg = '${AppLocalizations.of(context)!.errorCompra}: $msg';
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(translatedMsg),
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
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(AppLocalizations.of(ctx)!.pagar),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carritoProvider = Provider.of<CarritoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.carrito),
        actions: [
          // Botón vaciar carrito
          if (carritoProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.vaciarCarrito),
                    content: Text(AppLocalizations.of(context)!.seguroVaciar),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancelar),
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
                        child: Text(AppLocalizations.of(context)!.vaciar),
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
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.carritoVacio,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.anadeMonedas,
              style: const TextStyle(color: Colors.grey),
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
                return Card(
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
                              // Badge subasta ganada
                              if (carritoProvider.estaBloqueado(moneda.monedaId))
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB8860B).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.emoji_events, size: 11, color: Color(0xFFB8860B)),
                                      const SizedBox(width: 3),
                                      Text(
                                        AppLocalizations.of(context)!.subastaGanada,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFB8860B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

                      // Botón eliminar (solo si NO está bloqueado)
                      if (!carritoProvider.estaBloqueado(moneda.monedaId))
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () =>
                              carritoProvider.eliminar(moneda.monedaId),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.lock, color: Colors.grey, size: 20),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Resumen del total y botón comprar
          SafeArea(
            top: false,
            child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                    Text(
                      AppLocalizations.of(context)!.total,
                      style: const TextStyle(
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context)!.confirmarCompra,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}
