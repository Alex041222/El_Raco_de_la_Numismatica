import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  final String mensajeId;
  final String chatId;        // ID del chat al que pertenece el mensaje
  final String emisorId;      // UID del usuario que envía el mensaje
  final String? texto;        // texto del mensaje, null si es solo imagen
  final String? imagenURL;    // URL de la imagen en Storage, null si es solo texto
  final DateTime fechaEnvio;
  final bool leido;           // false hasta que el receptor abre el chat

  Mensaje({
    required this.mensajeId,
    required this.chatId,
    required this.emisorId,
    this.texto,               // no required porque puede ser solo imagen
    this.imagenURL,           // no required porque puede ser solo texto
    required this.fechaEnvio,
    required this.leido,
  });

  // Convierte un documento de Firestore en un objeto Mensaje
  // Se usa para mostrar los mensajes dentro de una conversación
  factory Mensaje.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mensaje(
      mensajeId: doc.id,
      chatId: data['chatId'] ?? '',
      emisorId: data['emisorId'] ?? '',
      texto: data['texto'],           // puede ser null
      imagenURL: data['imagenURL'],   // puede ser null
      fechaEnvio: (data['fechaEnvio'] as Timestamp).toDate(),
      leido: data['leido'] ?? false,  // por defecto no leido
    );
  }

  // Convierte el objeto Mensaje en un Map para guardarlo en Firestore
  // Se usa cada vez que el usuario envía un mensaje nuevo
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'emisorId': emisorId,
      'texto': texto,
      'imagenURL': imagenURL,
      'fechaEnvio': fechaEnvio,
      'leido': leido,
    };
  }
}