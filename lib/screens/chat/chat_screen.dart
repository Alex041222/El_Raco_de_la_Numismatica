import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/mensaje_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();
  bool _enviando = false;
  String _nombreOtroUsuario = 'Cargando...';

  @override
  void initState() {
    super.initState();
    // Marcar mensajes como leidos al abrir el chat
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _chatService.marcarMensajesComoLeidos(
      widget.chatId,
      authProvider.usuarioFirebase!.uid,
    );
    _cargarNombreOtroUsuario();
  }

  Future<void> _cargarNombreOtroUsuario() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final miUid = authProvider.usuarioFirebase!.uid;
      
      final doc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final otroUsuarioId = data['usuarioAId'] == miUid ? data['usuarioBId'] : data['usuarioAId'];
        
        final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(otroUsuarioId).get();
        if (userDoc.exists && userDoc.data() != null) {
          if (mounted) {
            setState(() {
              _nombreOtroUsuario = userDoc.data()!['nombreUsuario'] ?? 'Usuario';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _nombreOtroUsuario = 'Conversación';
        });
      }
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Enviar mensaje de texto
  Future<void> _enviarTexto() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    setState(() => _enviando = true);
    _mensajeController.clear();

    try {
      await _chatService.enviarMensajeTexto(widget.chatId, miUid, texto);
      // Scroll al último mensaje
      _scrollAlFinal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      setState(() => _enviando = false);
    }
  }

  // Enviar mensaje con imagen
  Future<void> _enviarImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (imagen == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final miUid = authProvider.usuarioFirebase!.uid;

    setState(() => _enviando = true);

    try {
      await _chatService.enviarMensajeImagen(
        widget.chatId,
        miUid,
        File(imagen.path),
      );
      _scrollAlFinal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar imagen: $e')),
        );
      }
    } finally {
      setState(() => _enviando = false);
    }
  }

  // Scroll automático al último mensaje
  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final miUid = authProvider.usuarioFirebase!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: Text(_nombreOtroUsuario),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: StreamBuilder<List<Mensaje>>(
              stream: _chatService.obtenerMensajes(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFB8860B)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Inicia la conversación',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Scroll al final cuando llegan mensajes nuevos
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollAlFinal();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final mensaje = snapshot.data![index];
                    final esMio = mensaje.emisorId == miUid;

                    return _BurbujaMensaje(
                      mensaje: mensaje,
                      esMio: esMio,
                    );
                  },
                );
              },
            ),
          ),

          // Barra de entrada de mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón enviar imagen
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFB8860B),
                  ),
                  onPressed: _enviando ? null : _enviarImagen,
                ),

                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAF7F2),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null, // permite múltiples líneas
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _enviarTexto(),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón enviar mensaje
                GestureDetector(
                  onTap: _enviando ? null : _enviarTexto,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB8860B),
                      shape: BoxShape.circle,
                    ),
                    child: _enviando
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget burbuja de mensaje
class _BurbujaMensaje extends StatelessWidget {
  final Mensaje mensaje;
  final bool esMio; // true si el mensaje es del usuario actual

  const _BurbujaMensaje({
    required this.mensaje,
    required this.esMio,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      // Mis mensajes a la derecha, los del otro a la izquierda
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          // Máximo 75% del ancho de la pantalla
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esMio ? const Color(0xFFB8860B) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Contenido del mensaje
            if (mensaje.imagenURL != null)
            // Mensaje con imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: mensaje.imagenURL!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                        color: Color(0xFFB8860B)),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            else
            // Mensaje de texto
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Text(
                  mensaje.texto ?? '',
                  style: TextStyle(
                    color: esMio ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),

            // Hora del mensaje y estado leido
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(mensaje.fechaEnvio),
                    style: TextStyle(
                      fontSize: 10,
                      color: esMio
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey,
                    ),
                  ),
                  // Icono de leido solo en mis mensajes
                  if (esMio) ...[
                    const SizedBox(width: 4),
                    Icon(
                      mensaje.leido ? Icons.done_all : Icons.done,
                      size: 12,
                      color: mensaje.leido
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}