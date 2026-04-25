import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/chat_model.dart';
import '../models/mensaje_model.dart';
import 'cloudinary_service.dart';

class ChatService {
  // Instancias de Firestore y Cloudinary
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Obtener todos los chats de un usuario en tiempo real
  // Se usa en la pantalla de lista de chats
  Stream<List<Chat>> obtenerMisChats(String usuarioId) {
    return _firestore
        .collection('chats')
        .where('usuarioAId', isEqualTo: usuarioId)
        .orderBy('fechaUltimoMensaje', descending: true)
        .snapshots()
        .asyncMap((queryA) async {
      // Buscamos también los chats donde el usuario es usuarioBId
      final queryB = await _firestore
          .collection('chats')
          .where('usuarioBId', isEqualTo: usuarioId)
          .orderBy('fechaUltimoMensaje', descending: true)
          .get();

      // Combinamos los dos resultados en una sola lista
      final chatsA = queryA.docs.map((doc) => Chat.fromFirestore(doc)).toList();
      final chatsB = queryB.docs.map((doc) => Chat.fromFirestore(doc)).toList();
      final todosLosChats = [...chatsA, ...chatsB];

      // Ordenamos por fecha del último mensaje
      todosLosChats.sort((a, b) =>
          b.fechaUltimoMensaje.compareTo(a.fechaUltimoMensaje));

      return todosLosChats;
    });
  }

  // Buscar si ya existe un chat entre dos usuarios sobre una moneda
  // Si no existe lo crea, si existe devuelve el ID del existente
  Future<String> obtenerOCrearChat(
      String usuarioAId, String usuarioBId, String? monedaRef) async {
    try {
      // Buscar chat existente entre los dos usuarios
      final query = await _firestore
          .collection('chats')
          .where('usuarioAId', isEqualTo: usuarioAId)
          .where('usuarioBId', isEqualTo: usuarioBId)
          .get();

      // Si ya existe devolvemos su ID
      if (query.docs.isNotEmpty) return query.docs.first.id;

      // Buscar también en el orden inverso (A y B intercambiados)
      final queryInversa = await _firestore
          .collection('chats')
          .where('usuarioAId', isEqualTo: usuarioBId)
          .where('usuarioBId', isEqualTo: usuarioAId)
          .get();

      if (queryInversa.docs.isNotEmpty) return queryInversa.docs.first.id;

      // Si no existe creamos uno nuevo
      final nuevoChat = _firestore.collection('chats').doc();
      await nuevoChat.set({
        'usuarioAId': usuarioAId,
        'usuarioBId': usuarioBId,
        'ultimoMensaje': '',
        'fechaUltimoMensaje': DateTime.now(),
        'monedaRef': monedaRef,
      });

      return nuevoChat.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener los mensajes de un chat en tiempo real
  // Se usa en la pantalla de conversación
  Stream<List<Mensaje>> obtenerMensajes(String chatId) {
    return _firestore
        .collection('mensajes')
        .where('chatId', isEqualTo: chatId)
        .orderBy('fechaEnvio', descending: false) // los más antiguos primero
        .snapshots()
        .map((query) => query.docs
        .map((doc) => Mensaje.fromFirestore(doc))
        .toList());
  }

  // Enviar un mensaje de texto
  // Se usa cuando el usuario pulsa enviar en el chat
  Future<void> enviarMensajeTexto(
      String chatId, String emisorId, String texto) async {
    try {
      // Crear el documento del mensaje
      final mensajeRef = _firestore.collection('mensajes').doc();
      await mensajeRef.set({
        'chatId': chatId,
        'emisorId': emisorId,
        'texto': texto,
        'imagenURL': null,
        'fechaEnvio': DateTime.now(),
        'leido': false,
      });

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'ultimoMensaje': texto,
        'fechaUltimoMensaje': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Enviar un mensaje con imagen
  // Primero sube la imagen a Cloudinary y luego guarda la URL en Firestore
  Future<void> enviarMensajeImagen(
      String chatId, String emisorId, File imagen) async {
    try {
      // Subir imagen a Cloudinary
      final url = await _cloudinaryService.subirImagen(
          imagen, 
          'chats/$chatId'
      );

      // Crear el documento del mensaje con la URL de la imagen
      final mensajeRef = _firestore.collection('mensajes').doc();
      await mensajeRef.set({
        'chatId': chatId,
        'emisorId': emisorId,
        'texto': null,
        'imagenURL': url,
        'fechaEnvio': DateTime.now(),
        'leido': false,
      });

      // Actualizar el último mensaje del chat
      await _firestore.collection('chats').doc(chatId).update({
        'ultimoMensaje': '📷 Imagen',
        'fechaUltimoMensaje': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Marcar todos los mensajes de un chat como leidos
  // Se llama cuando el usuario abre la conversación
  Future<void> marcarMensajesComoLeidos(
      String chatId, String usuarioId) async {
    try {
      // Buscar mensajes no leidos que no son del propio usuario
      final query = await _firestore
          .collection('mensajes')
          .where('chatId', isEqualTo: chatId)
          .where('leido', isEqualTo: false)
          .where('emisorId', isNotEqualTo: usuarioId)
          .get();

      // Marcar cada mensaje como leido
      for (final doc in query.docs) {
        await doc.reference.update({'leido': true});
      }
    } catch (e) {
      rethrow;
    }
  }
}