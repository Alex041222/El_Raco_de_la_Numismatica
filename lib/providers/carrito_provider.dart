import 'package:flutter/material.dart';
import '../models/moneda_venta_model.dart';
import '../models/moneda_subasta_model.dart';

class CarritoProvider extends ChangeNotifier {
  // Lista de monedas añadidas al carrito
  final List<MonedaVenta> _items = [];

  // IDs de items bloqueados (ganados por subasta) que no se pueden eliminar
  final Set<String> _itemsBloqueados = {};

  // Getters para acceder al estado desde las pantallas
  List<MonedaVenta> get items => _items;

  // Número de items en el carrito
  // Se usa para mostrar el badge en el icono del carrito
  int get cantidad => _items.length;

  // Precio total de todos los items del carrito
  double get total => _items.fold(0, (suma, item) => suma + item.precio);

  // Comprobar si una moneda ya está en el carrito
  bool estaEnCarrito(String monedaId) {
    return _items.any((item) => item.monedaId == monedaId);
  }

  // Comprobar si un item está bloqueado (ganado por subasta)
  bool estaBloqueado(String monedaId) {
    return _itemsBloqueados.contains(monedaId);
  }

  // Añadir una moneda al carrito
  // Se usa en la pantalla de detalle de moneda
  void agregarItem(MonedaVenta moneda) {
    // Evitar duplicados
    if (!estaEnCarrito(moneda.monedaId)) {
      _items.add(moneda);
      notifyListeners(); // avisa a las pantallas que el carrito ha cambiado
    }
  }

  // Añadir el premio de una subasta ganada (no eliminable)
  void agregarItemDeSubasta(MonedaSubasta subasta) {
    if (!estaEnCarrito(subasta.monedaId)) {
      // Convertimos MonedaSubasta a MonedaVenta para el carrito
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
        precio: subasta.precioActual, // precio final de la subasta
        disponible: true,
        fechaCreacion: subasta.fechaCreacion,
      );
      _items.add(monedaVenta);
      _itemsBloqueados.add(subasta.monedaId); // marcar como bloqueado
      notifyListeners();
    }
  }

  // Eliminar una moneda del carrito (solo si no está bloqueada)
  // Se usa en la pantalla del carrito
  void eliminar(String monedaId) {
    if (_itemsBloqueados.contains(monedaId)) return; // no se puede eliminar
    _items.removeWhere((item) => item.monedaId == monedaId);
    notifyListeners();
  }

  // Vaciar el carrito completamente (excepto items bloqueados)
  // Se usa después de completar una compra
  void vaciar() {
    _items.removeWhere((item) => !_itemsBloqueados.contains(item.monedaId));
    notifyListeners();
  }

  // Vaciar TODOS los items incluyendo bloqueados (tras completar pago de subasta)
  void vaciarTodo() {
    _items.clear();
    _itemsBloqueados.clear();
    notifyListeners();
  }
}