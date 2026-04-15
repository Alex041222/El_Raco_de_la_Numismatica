import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String usuarioAId;          // UID del primer usuario (normalmente el comprador)
  final String usuarioBId;          // UID del segundo usuario (normalmente el vendedor)
  final String ultimoMensaje;       // texto del último mensaje para mostrarlo en la lista
  final DateTime fechaUltimoMensaje;// para ordenar los chats del más reciente al más antiguo
  final String? monedaRef;          // ID de la moneda sobre la que hablan, puede ser null

  Chat({
    required this.chatId,
    required this.usuarioAId,
    required this.usuarioBId,
    required this.ultimoMensaje,
    required this.fechaUltimoMensaje,
    this.monedaRef,               // no required porque es opcional
  });

  // Convierte un documento de Firestore en un objeto Chat
  // Se usa para mostrar la lista de conversaciones del usuario
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      usuarioAId: data['usuarioAId'] ?? '',
      usuarioBId: data['usuarioBId'] ?? '',
      ultimoMensaje: data['ultimoMensaje'] ?? '',
      fechaUltimoMensaje: (data['fechaUltimoMensaje'] as Timestamp).toDate(),
      monedaRef: data['monedaRef'],   // puede ser null
    );
  }

  // Convierte el objeto Chat en un Map para guardarlo en Firestore
  // Se usa cuando dos usuarios inician una conversación por primera vez
  Map<String, dynamic> toFirestore() {
    return {
      'usuarioAId': usuarioAId,
      'usuarioBId': usuarioBId,
      'ultimoMensaje': ultimoMensaje,
      'fechaUltimoMensaje': fechaUltimoMensaje,
      'monedaRef': monedaRef,
    };
  }
}