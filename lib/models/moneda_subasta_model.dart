import 'package:cloud_firestore/cloud_firestore.dart';

class MonedaSubasta {
  // Campos de la moneda
  final String monedaId;
  final String vendedorId;        // UID del usuario que la subasta
  final List<String> imagenes;    // lista de URLs de fotos en Storage
  final String emisor;
  final String pais;
  final String periodo;
  final String unidadMonetaria;
  final String composicion;
  final double peso;
  final double diametro;
  final double grosor;
  final String forma;
  final String tecnicaAcuniacion;
  final String estadoConservacion;
  final double precioSalida;      // precio mínimo para empezar a pujar
  final double precioActual;      // se actualiza con cada puja nueva
  final String ganadorId;         // UID del usuario con la puja más alta
  final DateTime fechaFin;        // cuando cierra la subasta
  final bool disponible;          // false cuando la subasta ha terminado
  final DateTime fechaCreacion;

  MonedaSubasta({
    required this.monedaId,
    required this.vendedorId,
    required this.imagenes,
    required this.emisor,
    required this.pais,
    required this.periodo,
    required this.unidadMonetaria,
    required this.composicion,
    required this.peso,
    required this.diametro,
    required this.grosor,
    required this.forma,
    required this.tecnicaAcuniacion,
    required this.estadoConservacion,
    required this.precioSalida,
    required this.precioActual,
    required this.ganadorId,
    required this.fechaFin,
    required this.disponible,
    required this.fechaCreacion,
  });

  // Convierte un documento de Firestore en un objeto MonedaSubasta
  // Se usa cuando cargamos las subastas activas para mostrarlas en la app
  factory MonedaSubasta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonedaSubasta(
      monedaId: doc.id,
      vendedorId: data['vendedorId'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? []),
      emisor: data['emisor'] ?? '',
      pais: data['pais'] ?? '',
      periodo: data['periodo'] ?? '',
      unidadMonetaria: data['unidadMonetaria'] ?? '',
      composicion: data['composicion'] ?? '',
      peso: (data['peso'] ?? 0).toDouble(),
      diametro: (data['diametro'] ?? 0).toDouble(),
      grosor: (data['grosor'] ?? 0).toDouble(),
      forma: data['forma'] ?? '',
      tecnicaAcuniacion: data['tecnicaAcuniacion'] ?? '',
      estadoConservacion: data['estadoConservacion'] ?? '',
      precioSalida: (data['precioSalida'] ?? 0).toDouble(),
      precioActual: (data['precioActual'] ?? 0).toDouble(),
      ganadorId: data['ganadorId'] ?? '',   // vacío si aún no hay pujas
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      disponible: data['disponible'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convierte el objeto MonedaSubasta en un Map para guardarlo en Firestore
  // Se usa cuando el usuario publica una subasta nueva
  Map<String, dynamic> toFirestore() {
    return {
      'vendedorId': vendedorId,
      'imagenes': imagenes,
      'emisor': emisor,
      'pais': pais,
      'periodo': periodo,
      'unidadMonetaria': unidadMonetaria,
      'composicion': composicion,
      'peso': peso,
      'diametro': diametro,
      'grosor': grosor,
      'forma': forma,
      'tecnicaAcuniacion': tecnicaAcuniacion,
      'estadoConservacion': estadoConservacion,
      'precioSalida': precioSalida,
      'precioActual': precioActual,     // al publicar será igual a precioSalida
      'ganadorId': ganadorId,
      'fechaFin': fechaFin,
      'disponible': disponible,
      'fechaCreacion': fechaCreacion,
    };
  }
}
