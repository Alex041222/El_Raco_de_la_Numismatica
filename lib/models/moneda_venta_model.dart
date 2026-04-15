import 'package:cloud_firestore/cloud_firestore.dart';

class MonedaVenta {
  // Campos de la moneda
  final String monedaId;
  final String vendedorId;       // UID del usuario que la vende
  final List<String> imagenes;   // lista de URLs de fotos en Storage
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
  final double precio;
  final bool disponible;         // false cuando ya se ha vendido
  final DateTime fechaCreacion;

  MonedaVenta({
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
    required this.precio,
    required this.disponible,
    required this.fechaCreacion,
  });

  // Convierte un documento de Firestore en un objeto MonedaVenta
  // Se usa cuando leemos datos de Firebase para mostrarlos en la app
  factory MonedaVenta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MonedaVenta(
      monedaId: doc.id,
      vendedorId: data['vendedorId'] ?? '',
      imagenes: List<String>.from(data['imagenes'] ?? []),
      emisor: data['emisor'] ?? '',
      pais: data['pais'] ?? '',
      periodo: data['periodo'] ?? '',
      unidadMonetaria: data['unidadMonetaria'] ?? '',
      composicion: data['composicion'] ?? '',
      peso: (data['peso'] ?? 0).toDouble(),       // .toDouble() por si Firestore guarda como int
      diametro: (data['diametro'] ?? 0).toDouble(),
      grosor: (data['grosor'] ?? 0).toDouble(),
      forma: data['forma'] ?? '',
      tecnicaAcuniacion: data['tecnicaAcuniacion'] ?? '',
      estadoConservacion: data['estadoConservacion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      disponible: data['disponible'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convierte el objeto MonedaVenta en un Map para guardarlo en Firestore
  // Se usa cuando el usuario publica una moneda nueva
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
      'precio': precio,
      'disponible': disponible,
      'fechaCreacion': fechaCreacion,
    };
  }
}