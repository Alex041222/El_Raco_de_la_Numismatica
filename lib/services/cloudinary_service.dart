import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

class CloudinaryService {
  // CONFIGURACIÓN: Reemplaza con tus datos de Cloudinary
  final _cloudinary = CloudinaryPublic(
      'duwpfg50x',
      'Numista', // El preset debe ser "Unsigned"
      cache: false
  );

  Future<String> subirImagen(File imagen, String carpeta) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagen.path, folder: carpeta),
      );
      return response.secureUrl;
    } catch (e) {
      print("Error en Cloudinary: $e");
      rethrow;
    }
  }

  Future<List<String>> subirMultiplesImagenes(List<File> imagenes, String carpeta) async {
    List<String> urls = [];
    for (var imagen in imagenes) {
      String url = await subirImagen(imagen, carpeta);
      urls.add(url);
    }
    return urls;
  }
}