import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instancias de Firebase Auth y Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Devuelve el usuario actual logueado, null si no hay ninguno
  User? get usuarioActual => _auth.currentUser;

  // Stream que escucha cambios de sesión en tiempo real
  // Se usa en el provider para saber si el usuario está logueado o no
  Stream<User?> get estadoAuth => _auth.authStateChanges();

  // Registrar usuario nuevo con email y contraseña
  // Después del registro crea el documento en Firestore con datos vacíos
  // que se rellenarán en la pantalla de completar perfil
  Future<User?> registrar(String email, String password) async {
    try {
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento del usuario en Firestore con valores por defecto
      await _firestore
          .collection('usuarios')
          .doc(resultado.user!.uid)
          .set({
        'nombreUsuario': '',
        'fotoPerfil': '',       // vacío hasta que suba foto o use la de stock
        'biografia': '',
        'direccion': '',
        'puntuacion': 0,
        'fechaCreacion': DateTime.now(),
      });

      return resultado.user;
    } catch (e) {
      // Relanza el error para manejarlo en la pantalla
      rethrow;
    }
  }

  // Iniciar sesión con email y contraseña
  Future<User?> login(String email, String password) async {
    try {
      final resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado.user;
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}