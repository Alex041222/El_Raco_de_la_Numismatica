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
      // Usamos una transacción para que todo se guarde junto
      // Si algo falla, no se guarda nada (evita pedidos incompletos)
      await _firestore.runTransaction((transaction) async {

        // Crear el documento del pedido
        final pedidoRef = _firestore
            .collection('pedidos')
            .doc(pedido.pedidoId);
        transaction.set(pedidoRef, pedido.toFirestore());

        // Crear un documento por cada item del carrito
        for (final item in items) {
          final itemRef = _firestore
              .collection('items_pedido')
              .doc(item.itemId);
          transaction.set(itemRef, item.toFirestore());
        }

        // Marcar cada moneda como no disponible
        for (final item in items) {
          final coleccion = item.esSubasta ? 'monedas_subasta' : 'monedas_venta';
          final monedaRef = _firestore
              .collection(coleccion)
              .doc(item.monedaId);
          
          final docSnapshot = await transaction.get(monedaRef);
          if (docSnapshot.exists) {
            transaction.update(monedaRef, {'disponible': false});
          } else {
            throw Exception('Una de las monedas ya no está disponible o ha sido eliminada por el vendedor.');
          }
        }
      });
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        throw Exception('Una de las monedas ya no existe en la base de datos.');
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