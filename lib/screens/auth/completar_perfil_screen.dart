import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/usuario_service.dart';

class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({super.key});

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _biografiaController = TextEditingController();
  final _direccionController = TextEditingController();

  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Instancia del servicio de usuario
  final _usuarioService = UsuarioService();

  // Foto de perfil seleccionada, null si no ha seleccionado ninguna
  File? _fotoPerfil;

  // Controla si se está guardando el perfil
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _biografiaController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Abrir la galería para seleccionar foto de perfil
  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,    // limitamos el tamaño para no ocupar mucho Storage
      maxHeight: 512,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() => _fotoPerfil = File(imagen.path));
    }
  }

  // Guardar el perfil y redirigir a home
  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.usuarioFirebase!.uid;

      String urlFoto = '';

      // Si ha seleccionado foto la subimos a Storage
      if (_fotoPerfil != null) {
        urlFoto = await _usuarioService.subirFotoPerfil(uid, _fotoPerfil!);
      }
      // Si no ha seleccionado foto usamos la imagen de stock
      // que está en assets/images/default_avatar.png
      // guardamos string vacío y en la UI mostramos la de stock

      // Guardar los datos del perfil en Firestore
      await _usuarioService.actualizarPerfil(uid, {
        'nombreUsuario': _nombreController.text.trim(),
        'fotoPerfil': urlFoto, // <--- Aquí irá la URL https://...
        'biografia': _biografiaController.text.trim(),
        'direccion': _direccionController.text.trim(),
      });

      // Recargar el perfil en el provider
      await authProvider.recargarPerfil();

      if (mounted) context.go('/home');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: const Text('Completa tu perfil'),
        // Sin botón de volver atrás, el usuario debe completar el perfil
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const Text(
                  'Antes de continuar necesitamos algunos datos',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Selector de foto de perfil
                GestureDetector(
                  onTap: _seleccionarFoto,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFB8860B).withOpacity(0.2),
                    // Si hay foto seleccionada la muestra, si no muestra la de stock
                    backgroundImage: _fotoPerfil != null
                        ? FileImage(_fotoPerfil!)
                        : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
                    child: _fotoPerfil == null
                        ? const Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Color(0xFFB8860B),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toca para añadir foto (opcional)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Campo nombre de usuario
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    prefixIcon: Icon(Icons.person_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de usuario es obligatorio';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo biografia
                TextFormField(
                  controller: _biografiaController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Biografia (opcional)',
                    prefixIcon: Icon(Icons.info_outlined),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Campo dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección (opcional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardarPerfil,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8860B),
                      foregroundColor: Colors.white,
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Guardar y continuar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}