import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class ImagenWidget extends StatelessWidget {
  final String imagen;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const ImagenWidget({
    super.key,
    required this.imagen,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  // Comprova si és Base64 vàlid
  // Una URL sempre comença per http o https
  // Tot lo demés es tracta com Base64
  bool get _esBase64 {
    if (imagen.startsWith('http://') || imagen.startsWith('https://')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (imagen.isEmpty) {
      return placeholder ?? const Center(
        child: Icon(Icons.monetization_on, size: 40, color: Colors.grey),
      );
    }

    try {
      if (_esBase64) {
        // Mostrar imagen desde Base64
        final bytes = base64Decode(imagen);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
          placeholder ?? const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      } else {
        // Mostrar imagen desde URL con caché
        return CachedNetworkImage(
          imageUrl: imagen,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => placeholder ?? const Center(
            child: CircularProgressIndicator(color: Color(0xFFB8860B)),
          ),
          errorWidget: (context, url, error) =>
          placeholder ?? const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      }
    } catch (e) {
      return placeholder ?? const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    }
  }
}

// Widget específico para foto de perfil
class FotoPerfilWidget extends StatelessWidget {
  final String fotoPerfil;
  final double radius;

  const FotoPerfilWidget({
    super.key,
    required this.fotoPerfil,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoPerfil.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
        const AssetImage('assets/images/default_avatar.png'),
      );
    }

    try {
      if (!fotoPerfil.startsWith('http://') &&
          !fotoPerfil.startsWith('https://')) {
        // Base64
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(base64Decode(fotoPerfil)),
        );
      } else {
        // URL
        return CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(fotoPerfil),
        );
      }
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundImage:
        const AssetImage('assets/images/default_avatar.png'),
      );
    }
  }
}