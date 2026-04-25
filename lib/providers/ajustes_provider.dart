import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjustesProvider extends ChangeNotifier {
  // Estado del tema: true = oscuro, false = claro
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Idioma actual: 'ca' = Català, 'es' = Castellano
  String _idioma = 'ca';
  String get idioma => _idioma;

  // Cargar preferencias al iniciar
  Future<void> cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _idioma = prefs.getString('idioma') ?? 'ca';
    notifyListeners();
  }

  // Cambiar tema y guardar
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Cambiar idioma y guardar
  Future<void> setIdioma(String code) async {
    _idioma = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma', code);
  }

  // Obtener el ThemeMode para el MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
