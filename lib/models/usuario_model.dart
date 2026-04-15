import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String uid;
  final String nombreUsuario;
  final String fotoPerfil;
  final String biografia;
  final String direccion;
  final int puntuacion;
  final DateTime fechaCreacion;

  Usuario({
    required this.uid,
    required this.nombreUsuario,
    required this.fotoPerfil,
    required this.biografia,
    required this.direccion,
    required this.puntuacion,
    required this.fechaCreacion,
  });

  // Convertir documento Firestore → objeto Usuario
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      uid: doc.id,
      nombreUsuario: data['nombreUsuario'] ?? '',
      fotoPerfil: data['fotoPerfil'] ?? '',
      biografia: data['biografia'] ?? '',
      direccion: data['direccion'] ?? '',
      puntuacion: data['puntuacion'] ?? 0,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convertir objeto Usuario → Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombreUsuario': nombreUsuario,
      'fotoPerfil': fotoPerfil,
      'biografia': biografia,
      'direccion': direccion,
      'puntuacion': puntuacion,
      'fechaCreacion': fechaCreacion,
    };
  }
}