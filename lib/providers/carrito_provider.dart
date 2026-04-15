import 'package:flutter/material.dart';
import '../models/moneda_venta_model.dart';

class CarritoProvider extends ChangeNotifier {
  // Lista de monedas añadidas al carrito
  final List<MonedaVenta> _items = [];

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

  // Añadir una moneda al carrito
  // Se usa en la pantalla de detalle de moneda
  void agregarItem(MonedaVenta moneda) {
    // Evitar duplicados
    if (!estaEnCarrito(moneda.monedaId)) {
      _items.add(moneda);
      notifyListeners(); // avisa a las pantallas que el carrito ha cambiado
    }
  }

  // Eliminar una moneda del carrito
  // Se usa en la pantalla del carrito
  void eliminar(String monedaId) {
    _items.removeWhere((item) => item.monedaId == monedaId);
    notifyListeners();
  }

  // Vaciar el carrito completamente
  // Se usa después de completar una compra
  void vaciar() {
    _items.clear();
    notifyListeners();
  }
}