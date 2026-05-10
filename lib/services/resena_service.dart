import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resena_model.dart';
import '../services/usuario_service.dart';

class ResenaService {
  // Instancias de Firestore y UsuarioService
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsuarioService _usuarioService = UsuarioService();

  // Obtener todas las reseñas de un vendedor en tiempo real
  // Se usa en el perfil del vendedor para mostrar sus reseñas
  Stream<List<Resena>> obtenerResenasDeVendedor(String vendedorId) {
    return _firestore
        .collection('resenas')
        .where('vendedorId', isEqualTo: vendedorId)
        .orderBy('fechaCreacion', descending: true) // las más recientes primero
        .snapshots()
        .map((query) => query.docs
        .map((doc) => Resena.fromFirestore(doc))
        .toList());
  }

  // Comprobar si un usuario ya ha dejado reseña a un vendedor
  // Se usa para evitar que el mismo usuario deje más de una reseña
  Future<bool> yaHaDejadoResena(String autorId, String vendedorId) async {
    try {
      final query = await _firestore
          .collection('resenas')
          .where('autorId', isEqualTo: autorId)
          .where('vendedorId', isEqualTo: vendedorId)
          .get();

      return query.docs.isNotEmpty; // true si ya existe una reseña
    } catch (e) {
      rethrow;
    }
  }

  // Crear una reseña nueva y actualizar la puntuación del vendedor
  // Se usa cuando el usuario deja una reseña en el perfil del vendedor
  Future<void> crearResena(Resena resena) async {
    try {
      // Comprobar que el usuario no ha dejado ya una reseña
      final yaExiste = await yaHaDejadoResena(resena.autorId, resena.vendedorId);
      if (yaExiste) throw Exception('resenaYaExiste');

      // Comprobar que el usuario no se reseña a si mismo
      if (resena.autorId == resena.vendedorId) {
        throw Exception('resenaATiMismo');
      }

      // Guardar la reseña en Firestore
      final resenaRef = _firestore.collection('resenas').doc();
      await resenaRef.set(resena.toFirestore());

      // Actualizar la puntuación del vendedor (+1 o -1)
      await _usuarioService.actualizarPuntuacion(resena.vendedorId, resena.tipo);
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar una reseña y revertir la puntuación del vendedor
  // Se usa si queremos permitir al usuario eliminar su reseña
  Future<void> eliminarResena(Resena resena) async {
    try {
      // Eliminar el documento de la reseña
      await _firestore.collection('resenas').doc(resena.resenaId).delete();

      // Revertir la puntuación (si era positiva restamos, si era negativa sumamos)
      final tipoRevertido = resena.tipo == 'positivo' ? 'negativo' : 'positivo';
      await _usuarioService.actualizarPuntuacion(resena.vendedorId, tipoRevertido);
    } catch (e) {
      rethrow;
    }
  }
}