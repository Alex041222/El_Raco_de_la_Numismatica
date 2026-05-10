import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/usuario_model.dart';
import 'cloudinary_service.dart';

class UsuarioService {
  // Instancias de Firestore y Cloudinary
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SECCIÓN CORREGIDA: Definimos la instancia del servicio de Cloudinary
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Obtener un usuario por su UID
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

  // Comprobar si un nombre de usuario ya existe
  Future<bool> existeNombreUsuario(String nombreUsuario, {String? excludeUid}) async {
    try {
      // Buscar usuarios con el mismo nombre exacto
      final query = await _firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: nombreUsuario)
          .get();
          
      if (query.docs.isEmpty) {
        return false; // El nombre está libre
      }
      
      // Si estamos editando (excludeUid no es null), ignoramos si el documento encontrado es el del propio usuario
      if (excludeUid != null) {
        return query.docs.any((doc) => doc.id != excludeUid);
      }
      
      // Si no hay excludeUid (registro nuevo), y la lista no está vacía, el nombre ya existe
      return true;
    } catch (e) {
      print("Error al comprobar nombre de usuario: $e");
      return true; // En caso de error, asumimos que existe para evitar duplicados
    }
  }

  // Stream que escucha cambios del perfil en tiempo real
  Stream<Usuario?> escucharUsuario(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Usuario.fromFirestore(doc) : null);
  }

  // Actualizar datos del perfil del usuario (Usa .set con merge para evitar el error NOT_FOUND)
  Future<void> actualizarPerfil(String uid, Map<String, dynamic> datos) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set(datos, SetOptions(merge: true));
    } catch (e) {
      print("Error en actualizarPerfil: $e");
      rethrow;
    }
  }

  // Subir foto de perfil a Cloudinary y guardar la URL en Firestore
  Future<String> subirFotoPerfil(String uid, File imagen) async {
    try {
      // 1. Subir a Cloudinary usando la instancia declarada arriba
      String urlImagen = await _cloudinaryService.subirImagen(
          imagen, 'perfiles');

      // 2. Guardar en Firestore usando .set con merge
      await _firestore.collection('usuarios').doc(uid).set({
        'fotoPerfil': urlImagen,
      }, SetOptions(merge: true));

      return urlImagen;
    } catch (e) {
      print("Error en subirFotoPerfil: $e");
      rethrow;
    }
  }

  // Obtener los vendedores más recomendados ordenados por puntuación
  Future<List<Usuario>> obtenerVendedoresRecomendados() async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .orderBy('puntuacion', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar la puntuación del vendedor cuando recibe una reseña
  Future<void> actualizarPuntuacion(String vendedorId, String tipo) async {
    try {
      final incremento = tipo == 'positivo' ? 1 : -1;
      await _firestore.collection('usuarios').doc(vendedorId).update({
        'puntuacion': FieldValue.increment(incremento),
      });
    } catch (e) {
      rethrow;
    }
  }
}