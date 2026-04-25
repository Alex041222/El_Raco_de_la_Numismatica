import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';

class ListaChatsScreen extends StatelessWidget {
  const ListaChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatService = ChatService();
    final miUid = authProvider.usuarioFirebase!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatService.obtenerMisChats(miUid),
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB8860B)),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Sin chats
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes conversaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contacta con un vendedor desde el catálogo',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final chat = snapshot.data![index];

              // Obtener el ID del otro usuario
              final otroUsuarioId = chat.usuarioAId == miUid
                  ? chat.usuarioBId
                  : chat.usuarioAId;

              return _TarjetaChat(
                chat: chat,
                otroUsuarioId: otroUsuarioId,
                onTap: () => context.push('/chat/${chat.chatId}'),
              );
            },
          );
        },
      ),
    );
  }
}

// Widget tarjeta de chat
class _TarjetaChat extends StatelessWidget {
  final Chat chat;
  final String otroUsuarioId;
  final VoidCallback onTap;

  const _TarjetaChat({
    required this.chat,
    required this.otroUsuarioId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: UsuarioService().obtenerUsuario(otroUsuarioId),
      builder: (context, snapshot) {
        final usuario = snapshot.data;
        final nombreUsuario = usuario?.nombreUsuario ?? 'Cargando...';
        final fotoPerfil = usuario?.fotoPerfil ?? '';

        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Avatar del otro usuario
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFB8860B).withOpacity(0.2),
            backgroundImage: fotoPerfil.isNotEmpty ? NetworkImage(fotoPerfil) : null,
            child: fotoPerfil.isEmpty
                ? const Icon(Icons.person, color: Color(0xFFB8860B))
                : null,
          ),

          // Nombre del otro usuario e último mensaje
          title: Text(
            nombreUsuario,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            chat.ultimoMensaje.isEmpty
                ? 'Inicia la conversación'
                : chat.ultimoMensaje,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),

          // Fecha del último mensaje
          trailing: Text(
            _formatearFecha(chat.fechaUltimoMensaje),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        );
      },
    );
  }

  // Formatear fecha del último mensaje
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      // Hoy mostramos la hora
      return DateFormat('HH:mm').format(fecha);
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      // Esta semana mostramos el día
      return DateFormat('EEEE', 'es').format(fecha);
    } else {
      // Más de una semana mostramos la fecha
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
}