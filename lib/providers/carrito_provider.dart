import 'dart:async';
import 'package:flutter/material.dart';
import '../models/moneda_venta_model.dart';
import '../models/moneda_subasta_model.dart';
import '../services/carrito_service.dart';

class CarritoProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();
  String? _uid;
  StreamSubscription? _carritoSubscription;

  // Lista de monedas añadidas al carrito
  List<MonedaVenta> _items = [];

  // IDs de items bloqueados (ganados por subasta) que no se pueden eliminar
  final Set<String> _itemsBloqueados = {};

  // Getters para acceder al estado desde las pantallas
  List<MonedaVenta> get items => _items;

  // Número de items en el carrito
  int get cantidad => _items.length;

  // Precio total de todos los items del carrito
  double get total => _items.fold(0, (suma, item) => suma + item.precio);

  /// Inicializa el carrito para un usuario, cargando los datos de Firestore
  void inicializar(String uid) {
    if (_uid == uid) return; // Ya estamos en esta cuenta
    
    _uid = uid;
    _carritoSubscription?.cancel();
    
    // Escuchar cambios en el carrito de Firestore
    _carritoSubscription = _carritoService.obtenerCarrito(uid).listen((articulos) {
      // Combinar los items de Firestore con los bloqueados (subastas)
      // Mantener los bloqueados que ya tenemos en memoria
      final itemsBloqueadosData = _items.where((item) => _itemsBloqueados.contains(item.monedaId)).toList();
      
      _items = [...articulos];
      
      // Añadir de nuevo los bloqueados si no estaban en el stream (que solo trae ventas normales)
      for (final blocked in itemsBloqueadosData) {
        if (!estaEnCarrito(blocked.monedaId)) {
          _items.add(blocked);
        }
      }
      
      notifyListeners();
    });
  }

  // Comprobar si una moneda ya está en el carrito
  bool estaEnCarrito(String monedaId) {
    return _items.any((item) => item.monedaId == monedaId);
  }

  // Comprobar si un item está bloqueado (ganado por subasta)
  bool estaBloqueado(String monedaId) {
    return _itemsBloqueados.contains(monedaId);
  }

  // Añadir una moneda al carrito
  Future<void> agregarItem(MonedaVenta moneda) async {
    if (!estaEnCarrito(moneda.monedaId)) {
      // Añadimos localmente para feedback inmediato
      _items.add(moneda);
      notifyListeners();
      
      if (_uid != null) {
        await _carritoService.agregarAlCarrito(_uid!, moneda);
      }
    }
  }

  // Añadir el premio de una subasta ganada (no eliminable y NO se guarda en subcolección carrito)
  // Las subastas ganadas ya vienen del stream de HomeScreen por estar en la colección monedas_subasta
  void agregarItemDeSubasta(MonedaSubasta subasta) {
    if (!estaEnCarrito(subasta.monedaId)) {
      final monedaVenta = MonedaVenta(
        monedaId: subasta.monedaId,
        vendedorId: subasta.vendedorId,
        imagenes: subasta.imagenes,
        nom: subasta.nom,
        pais: subasta.pais,
        periodo: subasta.periodo,
        unidadMonetaria: subasta.unidadMonetaria,
        composicion: subasta.composicion,
        peso: subasta.peso,
        diametro: subasta.diametro,
        grosor: subasta.grosor,
        forma: subasta.forma,
        tecnicaAcuniacion: subasta.tecnicaAcuniacion,
        estadoConservacion: subasta.estadoConservacion,
        precio: subasta.precioActual,
        disponible: true,
        fechaCreacion: subasta.fechaCreacion,
      );
      _items.add(monedaVenta);
      _itemsBloqueados.add(subasta.monedaId);
      notifyListeners();
    }
  }

  // Eliminar una moneda del carrito
  Future<void> eliminar(String monedaId) async {
    if (_itemsBloqueados.contains(monedaId)) return;
    
    _items.removeWhere((item) => item.monedaId == monedaId);
    notifyListeners();
    
    if (_uid != null) {
      await _carritoService.eliminarDelCarrito(_uid!, monedaId);
    }
  }

  // Vaciar el carrito (solo items normales) después de compra
  Future<void> vaciar() async {
    final idsAEliminar = _items
        .where((item) => !_itemsBloqueados.contains(item.monedaId))
        .map((e) => e.monedaId)
        .toList();
        
    _items.removeWhere((item) => !_itemsBloqueados.contains(item.monedaId));
    notifyListeners();
    
    if (_uid != null && idsAEliminar.isNotEmpty) {
      await _carritoService.vaciarCarrito(_uid!, idsAEliminar);
    }
  }

  // Vaciar TODO (se llama al cerrar sesión o tras pagar subasta)
  void vaciarTodo() {
    _carritoSubscription?.cancel();
    _carritoSubscription = null;
    _uid = null;
    _items.clear();
    _itemsBloqueados.clear();
    notifyListeners();
  }
}