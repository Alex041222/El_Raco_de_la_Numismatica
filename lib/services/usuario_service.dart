import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert'; // añadir este import
import '../models/usuario_model.dart';

class UsuarioService {
  // Instancias de Firestore y Storage
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener un usuario por su UID
  // Se usa para mostrar el perfil de cualquier usuario
  Future<Usuario?> obtenerUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Stream que escucha cambios del perfil en tiempo real
  // Se usa en la pantalla de perfil para actualizarse automáticamente
  Stream<Usuario?> escucharUsuario(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Usuario.fromFirestore(doc) : null);
  }

  // Actualizar datos del perfil del usuario
  // Se usa en la pantalla de editar perfil y completar perfil
  Future<void> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update(datos);
    } catch (e) {
      rethrow;
    }
  }

  // Subir foto de perfil a Firebase Storage y guardar la URL en Firestore
  // Devuelve la URL de la foto subida
  Future<String> subirFotoPerfil(String uid, File imagen) async {
    try {
      // Leer la imagen y convertirla a Base64
      final bytes = await imagen.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Guardar el Base64 en Firestore directamente
      await _firestore.collection('usuarios').doc(uid).update({
        'fotoPerfil': base64Image,
      });

      return base64Image;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener los vendedores más recomendados ordenados por puntuación
  // Se usa en la pantalla de vendedores recomendados
  Future<List<Usuario>> obtenerVendedoresRecomendados() async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .orderBy('puntuacion', descending: true)  // de mayor a menor puntuación
          .limit(20)                                 // máximo 20 vendedores
          .get();

      return query.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar la puntuación del vendedor cuando recibe una reseña
  // +1 si es positiva, -1 si es negativa
  Future<void> actualizarPuntuacion(String vendedorId, String tipo) async {
    try {
      final incremento = tipo == 'positivo' ? 1 : -1;
      await _firestore.collection('usuarios').doc(vendedorId).update({
        'puntuacion': FieldValue.increment(incremento), // suma o resta 1 directamente
      });
    } catch (e) {
      rethrow;
    }
  }
}