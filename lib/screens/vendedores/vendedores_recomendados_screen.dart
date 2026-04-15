import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../services/usuario_service.dart';
import '../../models/usuario_model.dart';

class VendedoresRecomendadosScreen extends StatelessWidget {
  const VendedoresRecomendadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioService = UsuarioService();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Vendedores recomendados'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: usuarioService.obtenerVendedoresRecomendados(),
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

          // Sin datos
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay vendedores todavía',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los vendedores con más reseñas positivas\naparecerán aquí',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final usuario = snapshot.data![index];
              // Los 3 primeros tienen medalla de oro, plata y bronce
              final medalla = index == 0
                  ? '🥇'
                  : index == 1
                  ? '🥈'
                  : index == 2
                  ? '🥉'
                  : '${index + 1}';

              return GestureDetector(
                onTap: () => context.push('/perfil/${usuario.uid}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    // Borde dorado para el primero
                    border: index == 0
                        ? Border.all(
                      color: const Color(0xFFB8860B),
                      width: 2,
                    )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Posición / medalla
                      SizedBox(
                        width: 36,
                        child: Text(
                          medalla,
                          style: TextStyle(
                            fontSize: index < 3 ? 24 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB8860B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Foto de perfil
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                        const Color(0xFFB8860B).withOpacity(0.2),
                        backgroundImage: usuario.fotoPerfil.isNotEmpty
                            ? CachedNetworkImageProvider(usuario.fotoPerfil)
                            : const AssetImage(
                            'assets/images/default_avatar.png')
                        as ImageProvider,
                      ),
                      const SizedBox(width: 12),

                      // Nombre y puntuación
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario.nombreUsuario,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Biografia si tiene
                            if (usuario.biografia.isNotEmpty)
                              Text(
                                usuario.biografia,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            // Puntuación con icono
                            Row(
                              children: [
                                Icon(
                                  usuario.puntuacion >= 0
                                      ? Icons.thumb_up
                                      : Icons.thumb_down,
                                  size: 14,
                                  color: usuario.puntuacion >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${usuario.puntuacion} puntos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: usuario.puntuacion >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Flecha
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}