import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puja_model.dart';

class SubastaService {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las pujas de una subasta ordenadas de mayor a menor
  // Se usa en la pantalla de detalle de subasta para ver el historial
  Stream<List<Puja>> obtenerPujas(String monedaId) {
    return _firestore
        .collection('pujas')
        .where('monedaId', isEqualTo: monedaId)
        .orderBy('importe', descending: true) // la puja más alta primero
        .snapshots()
        .map((query) => query.docs
        .map((doc) => Puja.fromFirestore(doc))
        .toList());
  }

  // Realizar una puja nueva en una subasta
  // Comprueba que el importe sea mayor que el precio actual antes de pujar
  Future<void> realizarPuja(String monedaId, String usuarioId, double importe) async {
    try {
      // Primero comprobamos que la subasta sigue activa y el importe es válido
      final subastaDoc = await _firestore
          .collection('monedas_subasta')
          .doc(monedaId)
          .get();

      if (!subastaDoc.exists) throw Exception('subastaNoExiste');

      final data = subastaDoc.data() as Map<String, dynamic>;
      final precioActual = (data['precioActual'] ?? 0).toDouble();
      final fechaFin = (data['fechaFin'] as Timestamp).toDate();
      final disponible = data['disponible'] ?? false;

      // Comprobaciones antes de pujar
      if (!disponible) throw Exception('subastaTerminada');
      if (DateTime.now().isAfter(fechaFin)) throw Exception('subastaCaducada');
      if (importe <= precioActual) throw Exception('pujaMayorPrecio');

      // Crear el documento de la puja nueva
      final nuevaPuja = _firestore.collection('pujas').doc();
      await nuevaPuja.set({
        'monedaId': monedaId,
        'usuarioId': usuarioId,
        'importe': importe,
        'fechaCreacion': DateTime.now(),
      });

      // Actualizar el precio actual y el ganador en la subasta
      await _firestore
          .collection('monedas_subasta')
          .doc(monedaId)
          .update({
        'precioActual': importe,    // nuevo precio más alto
        'ganadorId': usuarioId,     // nuevo ganador
      });

    } catch (e) {
      rethrow;
    }
  }

  // Comprobar si una subasta ha caducado y cerrarla si es necesario
  // Se llama cada vez que el usuario abre la pantalla de detalle de subasta
  Future<void> comprobarYCerrarSubasta(String monedaId) async {
    try {
      final doc = await _firestore
          .collection('monedas_subasta')
          .doc(monedaId)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final fechaFin = (data['fechaFin'] as Timestamp).toDate();
      final disponible = data['disponible'] ?? false;

      // Si la fecha ha pasado y sigue marcada como disponible, la cerramos
      if (disponible && DateTime.now().isAfter(fechaFin)) {
        await _firestore
            .collection('monedas_subasta')
            .doc(monedaId)
            .update({'disponible': false});
      }
    } catch (e) {
      rethrow;
    }
  }
}