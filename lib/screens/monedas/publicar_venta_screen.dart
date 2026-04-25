import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../services/moneda_service.dart';
import '../../models/moneda_venta_model.dart';


class PublicarVentaScreen extends StatefulWidget {
  const PublicarVentaScreen({super.key});

  @override
  State<PublicarVentaScreen> createState() => _PublicarVentaScreenState();
}

class _PublicarVentaScreenState extends State<PublicarVentaScreen> {
  final _monedaService = MonedaService();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;

  // Controladores de texto
  final _nomController = TextEditingController();
  final _paisController = TextEditingController();
  final _periodoController = TextEditingController();
  final _unidadMonetariaController = TextEditingController();
  final _composicionController = TextEditingController();
  final _pesoController = TextEditingController();
  final _diametroController = TextEditingController();
  final _grosorController = TextEditingController();
  final _formaController = TextEditingController();
  final _tecnicaController = TextEditingController();
  final _estadoConservacionController = TextEditingController();
  final _precioController = TextEditingController();

  // Lista de imágenes seleccionadas
  final List<File> _imagenes = [];

  @override
  void dispose() {
    _nomController.dispose();
    _paisController.dispose();
    _periodoController.dispose();
    _unidadMonetariaController.dispose();
    _composicionController.dispose();
    _pesoController.dispose();
    _diametroController.dispose();
    _grosorController.dispose();
    _formaController.dispose();
    _tecnicaController.dispose();
    _estadoConservacionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // Seleccionar imágenes de la galería
  Future<void> _seleccionarImagenes() async {
    // Máximo 5 imágenes por moneda
    if (_imagenes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 imágenes por moneda')),
      );
      return;
    }

    final picker = ImagePicker();
    final imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (imagen != null) {
      setState(() => _imagenes.add(File(imagen.path)));
    }
  }

  // Publicar la moneda en venta
  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos una imagen de la moneda'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.usuarioFirebase!.uid;
      // Generar ID único para la moneda
      final monedaId = const Uuid().v4();

      // Subir imágenes a Cloudinary y obtener URLs reales
      // Ahora subirImagenesMoneda devuelve [https://..., https://...]
      final urls = await _monedaService.subirImagenesMoneda(
          monedaId, _imagenes);

      // Crear el objeto MonedaVenta con las URLs de la nube
      final moneda = MonedaVenta(
        monedaId: monedaId,
        vendedorId: uid,
        imagenes: urls, // <--- Lista de strings (URLs)
        nom: _nomController.text.trim(),
        pais: _paisController.text.trim(),
        periodo: _periodoController.text.trim(),
        unidadMonetaria: _unidadMonetariaController.text.trim(),
        composicion: _composicionController.text.trim(),
        peso: double.parse(_pesoController.text.trim()),
        diametro: double.parse(_diametroController.text.trim()),
        grosor: double.parse(_grosorController.text.trim()),
        forma: _formaController.text.trim(),
        tecnicaAcuniacion: _tecnicaController.text.trim(),
        estadoConservacion: _estadoConservacionController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        disponible: true,
        fechaCreacion: DateTime.now(),
      );

      // Publicar en Firestore
      await _monedaService.publicarMonedaVenta(moneda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moneda publicada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
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
        title: const Text('Publicar venta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Sección imágenes
              const Text(
                'Imágenes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
                ),
              ),
              const SizedBox(height: 8),

              // Fila de imágenes seleccionadas
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Botón añadir imagen
                    GestureDetector(
                      onTap: _seleccionarImagenes,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFB8860B), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFFB8860B),
                          size: 36,
                        ),
                      ),
                    ),

                    // Imágenes seleccionadas
                    ..._imagenes.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(entry.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Botón eliminar imagen
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _imagenes.removeAt(entry.key));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sección información general
              _SeccionFormulario(
                titulo: 'Información general',
                children: [
                  _CampoTexto(
                    controller: _nomController,
                    label: 'Nom de la moneda',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _paisController,
                    label: 'País',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _periodoController,
                    label: 'Periodo',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _unidadMonetariaController,
                    label: 'Unidad monetaria',
                    obligatorio: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección características físicas
              _SeccionFormulario(
                titulo: 'Características físicas',
                children: [
                  _CampoTexto(
                    controller: _composicionController,
                    label: 'Composición',
                    obligatorio: true,
                  ),
                  _CampoNumero(
                    controller: _pesoController,
                    label: 'Peso (g)',
                    obligatorio: true,
                  ),
                  _CampoNumero(
                    controller: _diametroController,
                    label: 'Diámetro (mm)',
                    obligatorio: true,
                  ),
                  _CampoNumero(
                    controller: _grosorController,
                    label: 'Grosor (mm)',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _formaController,
                    label: 'Forma',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _tecnicaController,
                    label: 'Técnica de acuñación',
                    obligatorio: true,
                  ),
                  _CampoTexto(
                    controller: _estadoConservacionController,
                    label: 'Estado de conservación',
                    obligatorio: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección precio
              _SeccionFormulario(
                titulo: 'Precio',
                children: [
                  _CampoNumero(
                    controller: _precioController,
                    label: 'Precio (€)',
                    obligatorio: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botón publicar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8860B),
                    foregroundColor: Colors.white,
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Publicar moneda',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget sección del formulario con título y campos
class _SeccionFormulario extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _SeccionFormulario({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8860B),
            ),
          ),
          const SizedBox(height: 12),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          )),
        ],
      ),
    );
  }
}

// Widget campo de texto genérico
class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obligatorio;

  const _CampoTexto({
    required this.controller,
    required this.label,
    this.obligatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: obligatorio
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      }
          : null,
    );
  }
}

// Widget campo numérico con validación de número
class _CampoNumero extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obligatorio;

  const _CampoNumero({
    required this.controller,
    required this.label,
    this.obligatorio = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: obligatorio
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (double.tryParse(value) == null) {
          return 'Introduce un número válido';
        }
        if (double.parse(value) <= 0) {
          return 'El valor debe ser mayor que 0';
        }
        return null;
      }
          : null,
    );
  }
}