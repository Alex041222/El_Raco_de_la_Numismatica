import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String itemId;
  final String pedidoId;        // ID del pedido al que pertenece
  final String monedaId;        // ID de la moneda comprada
  final double precioUnitario;  // precio en el momento de la compra
  final String tituloSnapshot;  // nombre de la moneda en el momento de la compra
  final bool esSubasta;         // indica si viene de una subasta o venta directa

  ItemPedido({
    required this.itemId,
    required this.pedidoId,
    required this.monedaId,
    required this.precioUnitario,
    required this.tituloSnapshot,
    this.esSubasta = false,
  });

  // Convierte un documento de Firestore en un objeto ItemPedido
  factory ItemPedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemPedido(
      itemId: doc.id,
      pedidoId: data['pedidoId'] ?? '',
      monedaId: data['monedaId'] ?? '',
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      tituloSnapshot: data['tituloSnapshot'] ?? '',
      esSubasta: data['esSubasta'] ?? false,
    );
  }

  // Convierte el objeto ItemPedido en un Map para guardarlo en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pedidoId': pedidoId,
      'monedaId': monedaId,
      'precioUnitario': precioUnitario,
      'tituloSnapshot': tituloSnapshot,
      'esSubasta': esSubasta,
    };
  }
}