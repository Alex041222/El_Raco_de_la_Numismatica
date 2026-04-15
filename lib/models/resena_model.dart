import 'package:cloud_firestore/cloud_firestore.dart';

class Resena {
  final String resenaId;
  final String autorId;       // UID del usuario que escribe la reseña
  final String vendedorId;    // UID del usuario que recibe la reseña
  final String comentario;    // texto de la reseña
  final String tipo;          // "positivo" o "negativo"
  final DateTime fechaCreacion;

  Resena({
    required this.resenaId,
    required this.autorId,
    required this.vendedorId,
    required this.comentario,
    required this.tipo,
    required this.fechaCreacion,
  });

  // Convierte un documento de Firestore en un objeto Resena
  // Se usa para mostrar las reseñas en el perfil del vendedor
  factory Resena.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Resena(
      resenaId: doc.id,
      autorId: data['autorId'] ?? '',
      vendedorId: data['vendedorId'] ?? '',
      comentario: data['comentario'] ?? '',
      tipo: data['tipo'] ?? 'positivo',   // por defecto positivo
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convierte el objeto Resena en un Map para guardarlo en Firestore
  // Se usa cuando un usuario deja una reseña a un vendedor
  Map<String, dynamic> toFirestore() {
    return {
      'autorId': autorId,
      'vendedorId': vendedorId,
      'comentario': comentario,
      'tipo': tipo,
      'fechaCreacion': fechaCreacion,
    };
  }
}