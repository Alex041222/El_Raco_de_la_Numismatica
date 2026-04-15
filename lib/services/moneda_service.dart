import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/moneda_venta_model.dart';
import '../models/moneda_subasta_model.dart';
import 'dart:convert';
import 'dart:io';
import 'cloudinary_service.dart';
class MonedaService {
  // Instancias de Firestore y Storage
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  // ─── MONEDAS VENTA ───────────────────────────────────────────────

  // Obtener todas las monedas en venta disponibles
  // Se usa en el catálogo principal de ventas
  Stream<List<MonedaVenta>> obtenerMonedasVenta() {
    return _firestore
        .collection('monedas_venta')
        .where('disponible', isEqualTo: true) // solo las que no se han vendido
        .orderBy('fechaCreacion', descending: true) // las más recientes primero
        .snapshots()
        .map((query) =>
        query.docs
            .map((doc) => MonedaVenta.fromFirestore(doc))
            .toList());
  }

  // Obtener las monedas en venta de un vendedor concreto
  // Se usa en el perfil del usuario para ver sus artículos en venta
  Stream<List<MonedaVenta>> obtenerMonedasVentaPorVendedor(String vendedorId) {
    return _firestore
        .collection('monedas_venta')
        .where('vendedorId', isEqualTo: vendedorId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((query) =>
        query.docs
            .map((doc) => MonedaVenta.fromFirestore(doc))
            .toList());
  }

  // Obtener una moneda en venta por su ID
  // Se usa en la pantalla de detalle de moneda
  Future<MonedaVenta?> obtenerMonedaVenta(String monedaId) async {
    try {
      final doc = await _firestore
          .collection('monedas_venta')
          .doc(monedaId)
          .get();
      if (doc.exists) {
        return MonedaVenta.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Publicar una moneda nueva en venta
  // Se usa en la pantalla de publicar venta
  Future<void> publicarMonedaVenta(MonedaVenta moneda) async {
    try {
      await _firestore
          .collection('monedas_venta')
          .doc(moneda.monedaId)
          .set(moneda.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Marcar una moneda como vendida (disponible = false)
  // Se usa cuando se completa una compra
  Future<void> marcarComoVendida(String monedaId) async {
    try {
      await _firestore
          .collection('monedas_venta')
          .doc(monedaId)
          .update({'disponible': false});
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar una moneda en venta
  // Se usa cuando el vendedor quiere retirar su anuncio
  Future<void> eliminarMonedaVenta(String monedaId) async {
    try {
      await _firestore
          .collection('monedas_venta')
          .doc(monedaId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ─── MONEDAS SUBASTA ─────────────────────────────────────────────

  // Obtener todas las subastas activas
  // Se usa en el catálogo principal de subastas
  Stream<List<MonedaSubasta>> obtenerSubastasActivas() {
    return _firestore
        .collection('monedas_subasta')
        .where('disponible', isEqualTo: true)
        .orderBy('fechaFin', descending: false) // las que acaban antes primero
        .snapshots()
        .map((query) =>
        query.docs
            .map((doc) => MonedaSubasta.fromFirestore(doc))
            .toList());
  }

  // Obtener las subastas de un vendedor concreto
  // Se usa en el perfil del usuario para ver sus subastas
  Stream<List<MonedaSubasta>> obtenerSubastasPorVendedor(String vendedorId) {
    return _firestore
        .collection('monedas_subasta')
        .where('vendedorId', isEqualTo: vendedorId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((query) =>
        query.docs
            .map((doc) => MonedaSubasta.fromFirestore(doc))
            .toList());
  }

  // Obtener una subasta por su ID
  // Se usa en la pantalla de detalle de subasta
  Stream<MonedaSubasta?> escucharSubasta(String monedaId) {
    // Stream para que el precio actual se actualice en tiempo real
    return _firestore
        .collection('monedas_subasta')
        .doc(monedaId)
        .snapshots()
        .map((doc) => doc.exists ? MonedaSubasta.fromFirestore(doc) : null);
  }

  // Publicar una subasta nueva
  // Se usa en la pantalla de publicar subasta
  Future<void> publicarSubasta(MonedaSubasta moneda) async {
    try {
      await _firestore
          .collection('monedas_subasta')
          .doc(moneda.monedaId)
          .set(moneda.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar una subasta cuando fechaFin ha pasado
  // Se usa cuando el usuario abre una subasta caducada
  Future<void> cerrarSubasta(String monedaId, String ganadorId) async {
    try {
      await _firestore
          .collection('monedas_subasta')
          .doc(monedaId)
          .update({
        'disponible': false,
        'ganadorId': ganadorId,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ─── IMÁGENES ────────────────────────────────────────────────────

  // Subir múltiples imágenes de una moneda a Firebase Storage
  // Devuelve la lista de URLs de las imágenes subidas
  Future<List<String>> subirImagenesMoneda(String monedaId, List<File> listaImagenes) async {
    try {
      // Subimos todas las imágenes a una carpeta específica para esa moneda
      final urls = await _cloudinaryService.subirMultiplesImagenes(
          listaImagenes,
          'monedas/$monedaId'
      );
      return urls;
    } catch (e) {
      print("Error al subir imágenes: $e");
      rethrow;
    }
  }
}