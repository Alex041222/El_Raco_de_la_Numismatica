import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String pedidoId;
  final String compradorId;     // UID del usuario que compra
  final String vendedorId;      // UID del usuario que vende
  final double total;           // suma de todos los items del pedido
  final String? direccionEnvio; // opcional, solo para simular el proceso
  final DateTime fechaCreacion;

  Pedido({
    required this.pedidoId,
    required this.compradorId,
    required this.vendedorId,
    required this.total,
    this.direccionEnvio,        // no required porque es opcional
    required this.fechaCreacion,
  });

  // Convierte un documento de Firestore en un objeto Pedido
  // Se usa para mostrar el historial de compras del usuario
  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pedido(
      pedidoId: doc.id,
      compradorId: data['compradorId'] ?? '',
      vendedorId: data['vendedorId'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      direccionEnvio: data['direccionEnvio'],   // puede ser null
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convierte el objeto Pedido en un Map para guardarlo en Firestore
  // Se usa cuando el usuario finaliza la compra
  Map<String, dynamic> toFirestore() {
    return {
      'compradorId': compradorId,
      'vendedorId': vendedorId,
      'total': total,
      'direccionEnvio': direccionEnvio,   // se guarda null si no se introduce
      'fechaCreacion': fechaCreacion,
    };
  }
}