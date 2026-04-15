import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();

  User? _usuarioFirebase;
  Usuario? _usuarioPerfil;
  bool _cargando = false;
  bool _cargandoInicial = true; // ← nou: true fins que Firebase comprovi la sessió
  String? _error;

  User? get usuarioFirebase => _usuarioFirebase;
  Usuario? get usuarioPerfil => _usuarioPerfil;
  bool get cargando => _cargando;
  bool get cargandoInicial => _cargandoInicial; // ← nou getter
  String? get error => _error;
  bool get estaLogueado => _usuarioFirebase != null;

  AuthProvider() {
    _authService.estadoAuth.listen((user) async {
      _usuarioFirebase = user;
      if (user != null) {
        _usuarioPerfil = await _usuarioService.obtenerUsuario(user.uid);
      } else {
        _usuarioPerfil = null;
      }
      _cargandoInicial = false; // ← ja ha comprovat la sessió
      notifyListeners();
    });
  }

  Future<void> registrar(String email, String password) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();
      await _authService.registrar(email, password);
    } catch (e) {
      _error = _traducirError(e.toString());
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _cargando = true;
      _error = null;
      notifyListeners();
      await _authService.login(email, password);
    } catch (e) {
      _error = _traducirError(e.toString());
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _usuarioPerfil = null;
    notifyListeners();
  }

  Future<void> recargarPerfil() async {
    if (_usuarioFirebase != null) {
      _usuarioPerfil =
      await _usuarioService.obtenerUsuario(_usuarioFirebase!.uid);
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  String _traducirError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Este email ya está registrado';
    } else if (error.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    } else if (error.contains('user-not-found')) {
      return 'No existe ninguna cuenta con este email';
    } else if (error.contains('invalid-email')) {
      return 'El email no es válido';
    } else if (error.contains('weak-password')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (error.contains('network-request-failed')) {
      return 'Sin conexión a internet';
    }
    return 'Ha ocurrido un error, inténtalo de nuevo';
  }
}
