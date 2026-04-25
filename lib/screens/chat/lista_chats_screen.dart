import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/chat_model.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';
import '../l10n/app_localizations.dart';
import '../../widgets/imagen_widget.dart';

class ListaChatsScreen extends StatelessWidget {
  const ListaChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseUser = authProvider.usuarioFirebase;

    // Si no hay usuario (ej. cerrando sesión), evitamos el crash
    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB8860B))),
      );
    }

    final chatService = ChatService();
    final miUid = firebaseUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.xats),
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
                    AppLocalizations.of(context)!.noConversaciones,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.contactarVendedorCatalogo,
                    style: const TextStyle(color: Colors.grey),
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
        final nombreUsuario = usuario?.nombreUsuario ?? AppLocalizations.of(context)!.cargando;
        final fotoPerfil = usuario?.fotoPerfil ?? '';

        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Avatar del otro usuario
          leading: FotoPerfilWidget(
            fotoPerfil: fotoPerfil,
            radius: 28,
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
                ? AppLocalizations.of(context)!.iniciaConversacion
                : chat.ultimoMensaje,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),

          // Fecha del último mensaje
          trailing: Text(
            _formatearFecha(context, chat.fechaUltimoMensaje),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        );
      },
    );
  }

  // Formatear fecha del último mensaje
  String _formatearFecha(BuildContext context, DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    final locale = Localizations.localeOf(context).toString();

    if (diferencia.inDays == 0) {
      // Hoy mostramos la hora
      return DateFormat('HH:mm').format(fecha);
    } else if (diferencia.inDays == 1) {
      return AppLocalizations.of(context)!.ayer;
    } else if (diferencia.inDays < 7) {
      // Esta semana mostramos el día
      return DateFormat('EEEE', locale).format(fecha);
    } else {
      // Más de una semana mostramos la fecha
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
}