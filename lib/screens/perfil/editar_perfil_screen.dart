import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/usuario_service.dart';
import '../../l10n/app_localizations.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _usuarioService = UsuarioService();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _biografiaController = TextEditingController();
  final _direccionController = TextEditingController();

  // Nueva foto seleccionada, null si no ha cambiado
  File? _nuevaFoto;

  @override
  void initState() {
    super.initState();
    // Rellenar los campos con los datos actuales del usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuario = authProvider.usuarioPerfil;
    if (usuario != null) {
      _nombreController.text = usuario.nombreUsuario;
      _biografiaController.text = usuario.biografia;
      _direccionController.text = usuario.direccion;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _biografiaController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Seleccionar nueva foto de perfil
  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() => _nuevaFoto = File(imagen.path));
    }
  }

  // Guardar los cambios del perfil
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.usuarioFirebase!.uid;
      final nombreUsuario = _nombreController.text.trim();

      // Comprobar si el nombre de usuario ya está cogido por otro
      // (excluimos el propio UID por si el usuario guarda sin cambiar su propio nombre)
      final existe = await _usuarioService.existeNombreUsuario(nombreUsuario, excludeUid: uid);
      if (existe) {
        throw Exception(AppLocalizations.of(context)!.nombreUsuarioEnUso);
      }

      // Si ha cambiado la foto la subimos primero
      if (_nuevaFoto != null) {
        await _usuarioService.subirFotoPerfil(uid, _nuevaFoto!);
      }

      // Actualizar el resto de datos del perfil
      await _usuarioService.actualizarPerfil(uid, {
        'nombreUsuario': _nombreController.text.trim(),
        'biografia': _biografiaController.text.trim(),
        'direccion': _direccionController.text.trim(),
      });

      // Recargar el perfil en el provider para reflejar los cambios
      await authProvider.recargarPerfil();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.perfilActualizado),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorGuardar}: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuarioPerfil;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB8860B))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editarPerfil),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Selector de foto de perfil
              GestureDetector(
                onTap: _seleccionarFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFB8860B).withOpacity(0.2),
                      // Lógica corregida para mostrar la imagen:
                      backgroundImage: _nuevaFoto != null
                          ? FileImage(_nuevaFoto!) as ImageProvider // Foto nueva local
                          : (usuario?.fotoPerfil != null && usuario!.fotoPerfil.startsWith('http')
                          ? NetworkImage(usuario.fotoPerfil) // Foto de Cloudinary
                          : const AssetImage('assets/images/default_avatar.png')), // Foto por defecto
                    ),
                    // Icono de editar encima de la foto
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB8860B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.tocaCambiarFoto,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Campo nombre de usuario
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.nombreUsuario,
                  prefixIcon: const Icon(Icons.person_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.nombreObligatorio;
                  }
                  if (value.length < 3) {
                    return AppLocalizations.of(context)!.nombreCorto;
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.biografiaOpcional,
                  prefixIcon: const Icon(Icons.info_outlined),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Campo dirección
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.direccionOpcional,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8860B),
                    foregroundColor: Colors.white,
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    AppLocalizations.of(context)!.guardarCambios,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}