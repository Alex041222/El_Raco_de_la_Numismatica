import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/moneda_venta_model.dart';

class CarritoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene los items del carrito de un usuario específico
  Stream<List<MonedaVenta>> obtenerCarrito(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('carrito')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MonedaVenta.fromFirestore(doc)).toList();
    });
  }

  /// Agrega un item al carrito en Firestore
  Future<void> agregarAlCarrito(String uid, MonedaVenta moneda) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(moneda.monedaId)
          .set(moneda.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Elimina un item del carrito en Firestore
  Future<void> eliminarDelCarrito(String uid, String monedaId) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(monedaId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Vacía los items no bloqueados del carrito en Firestore
  Future<void> vaciarCarrito(String uid, List<String> monedaIds) async {
    try {
      final batch = _firestore.batch();
      for (final id in monedaIds) {
        final docRef = _firestore
            .collection('usuarios')
            .doc(uid)
            .collection('carrito')
            .doc(id);
        batch.delete(docRef);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
