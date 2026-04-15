import 'package:cloud_firestore/cloud_firestore.dart';

class Puja {
  final String pujaId;
  final String monedaId;    // ID de la subasta a la que pertenece la puja
  final String usuarioId;   // UID del usuario que ha pujado
  final double importe;     // cantidad pujada
  final DateTime fechaCreacion;

  Puja({
    required this.pujaId,
    required this.monedaId,
    required this.usuarioId,
    required this.importe,
    required this.fechaCreacion,
  });

  // Convierte un documento de Firestore en un objeto Puja
  // Se usa para mostrar el historial de pujas de una subasta
  factory Puja.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Puja(
      pujaId: doc.id,
      monedaId: data['monedaId'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      importe: (data['importe'] ?? 0).toDouble(),
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convierte el objeto Puja en un Map para guardarlo en Firestore
  // Se usa cuando un usuario realiza una puja nueva
  Map<String, dynamic> toFirestore() {
    return {
      'monedaId': monedaId,
      'usuarioId': usuarioId,
      'importe': importe,
      'fechaCreacion': fechaCreacion,
    };
  }
}