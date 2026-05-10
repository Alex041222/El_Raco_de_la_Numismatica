import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';
import '../models/item_pedido_model.dart';

class PedidoService {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear un pedido nuevo con todos sus items
  // Se usa cuando el usuario confirma la compra del carrito
  Future<void> crearPedido(Pedido pedido, List<ItemPedido> items) async {
    try {
      await _firestore.runTransaction((transaction) async {

        // ── 1. PRIMER TOTES LES LECTURES ──────────────────────────────
        // Firestore exigeix que tots els get() es facin ABANS de qualsevol set/update
        final monedaRefs = items.map((item) {
          final coleccion = item.esSubasta ? 'monedas_subasta' : 'monedas_venta';
          return _firestore.collection(coleccion).doc(item.monedaId);
        }).toList();

        final snapshots = await Future.wait(
          monedaRefs.map((ref) => transaction.get(ref)),
        );

        // Validar que totes les monedes existeixen
        for (int i = 0; i < snapshots.length; i++) {
          if (!snapshots[i].exists) {
            throw Exception('monedaNoDisponible');
          }
        }

        // ── 2. DESPRÉS TOTES LES ESCRIPTURES ──────────────────────────
        // Crear el document del pedido
        final pedidoRef = _firestore.collection('pedidos').doc(pedido.pedidoId);
        transaction.set(pedidoRef, pedido.toFirestore());

        // Crear un document per cada item del carrito
        for (final item in items) {
          final itemRef = _firestore.collection('items_pedido').doc(item.itemId);
          transaction.set(itemRef, item.toFirestore());
        }

        // Marcar cada moneda com a no disponible
        for (int i = 0; i < monedaRefs.length; i++) {
          transaction.update(monedaRefs[i], {'disponible': false});
        }
      });
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        throw Exception('monedaNoExiste');
      }
      rethrow;
    }
  }

  // Obtener los pedidos donde el usuario es el comprador
  // Se usa en la pantalla de mis compras
  Stream<List<Pedido>> obtenerMisCompras(String compradorId) {
    return _firestore
        .collection('pedidos')
        .where('compradorId', isEqualTo: compradorId)
        .orderBy('fechaCreacion', descending: true) // los más recientes primero
        .snapshots()
        .map((query) => query.docs
        .map((doc) => Pedido.fromFirestore(doc))
        .toList());
  }

  // Obtener los pedidos donde el usuario es el vendedor
  // Se usa en la pantalla de mis ventas
  Stream<List<Pedido>> obtenerMisVentas(String vendedorId) {
    return _firestore
        .collection('pedidos')
        .where('vendedorId', isEqualTo: vendedorId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((query) => query.docs
        .map((doc) => Pedido.fromFirestore(doc))
        .toList());
  }

  // Obtener los items de un pedido concreto
  // Se usa en la pantalla de detalle de pedido
  Future<List<ItemPedido>> obtenerItemsPedido(String pedidoId) async {
    try {
      final query = await _firestore
          .collection('items_pedido')
          .where('pedidoId', isEqualTo: pedidoId)
          .get();

      return query.docs
          .map((doc) => ItemPedido.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}