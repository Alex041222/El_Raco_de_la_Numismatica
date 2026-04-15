import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String itemId;
  final String pedidoId;        // ID del pedido al que pertenece
  final String monedaId;        // ID de la moneda comprada
  final double precioUnitario;  // precio en el momento de la compra
  final String tituloSnapshot;  // nombre de la moneda en el momento de la compra
  // se guarda por si la moneda se elimina después

  ItemPedido({
    required this.itemId,
    required this.pedidoId,
    required this.monedaId,
    required this.precioUnitario,
    required this.tituloSnapshot,
  });

  // Convierte un documento de Firestore en un objeto ItemPedido
  // Se usa para mostrar el detalle de cada moneda dentro de un pedido
  factory ItemPedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemPedido(
      itemId: doc.id,
      pedidoId: data['pedidoId'] ?? '',
      monedaId: data['monedaId'] ?? '',
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      tituloSnapshot: data['tituloSnapshot'] ?? '',
    );
  }

  // Convierte el objeto ItemPedido en un Map para guardarlo en Firestore
  // Se usa al finalizar la compra, uno por cada moneda del carrito
  Map<String, dynamic> toFirestore() {
    return {
      'pedidoId': pedidoId,
      'monedaId': monedaId,
      'precioUnitario': precioUnitario,
      'tituloSnapshot': tituloSnapshot,
    };
  }
}