import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../services/moneda_service.dart';
import '../../models/moneda_subasta_model.dart';
import '../../l10n/app_localizations.dart';

class PublicarSubastaScreen extends StatefulWidget {
  const PublicarSubastaScreen({super.key});

  @override
  State<PublicarSubastaScreen> createState() => _PublicarSubastaScreenState();
}

class _PublicarSubastaScreenState extends State<PublicarSubastaScreen> {
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
  final _precioSalidaController = TextEditingController();

  // Data final escollida manualment
  DateTime? _fechaFinElegida;

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
    _precioSalidaController.dispose();
    super.dispose();
  }

  // Seleccionar imágenes de la galería
  Future<void> _seleccionarImagenes() async {
    if (_imagenes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.max5Imagenes)),
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

  // Publicar la subasta
  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.alMenosUnaImagen),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.usuarioFirebase!.uid;

      // Generar ID único para la subasta
      final monedaId = const Uuid().v4();

      // Subir imágenes a Storage y obtener URLs
      final urls = await _monedaService.subirImagenesMoneda(
          monedaId, _imagenes);

      if (_fechaFinElegida == null || _fechaFinElegida!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fechaFinValida)),
        );
        setState(() => _cargando = false);
        return;
      }

      // Calcular fecha de fin elegida manualmente
      final fechaFin = _fechaFinElegida!;
      final precioSalida = double.parse(_precioSalidaController.text.trim());

      // Crear el objeto MonedaSubasta
      final moneda = MonedaSubasta(
        monedaId: monedaId,
        vendedorId: uid,
        imagenes: urls, // <--- Lista de links cortos de Cloudinary
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
        precioSalida: precioSalida,
        precioActual: precioSalida,
        ganadorId: '',
        fechaFin: fechaFin,
        disponible: true,
        fechaCreacion: DateTime.now(),
      );

      // Publicar en Firestore
      await _monedaService.publicarSubasta(moneda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(AppLocalizations.of(context)!.publicadoCorrecto),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorPublicar}: ${e.toString().replaceAll('Exception: ', '')}'),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFB8860B),
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.publicarSubasta),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Sección imágenes
              Text(
                AppLocalizations.of(context)!.imagenes,
                style: const TextStyle(
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
                                setState(
                                        () => _imagenes.removeAt(entry.key));
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
                titulo: AppLocalizations.of(context)!.infoGeneral,
                children: [
                  _CampoTexto(
                    controller: _nomController,
                    label: AppLocalizations.of(context)!.nomMoneda,
                  ),
                  _CampoTexto(
                    controller: _paisController,
                    label: AppLocalizations.of(context)!.pais,
                  ),
                  _CampoTexto(
                    controller: _periodoController,
                    label: AppLocalizations.of(context)!.periodo,
                  ),
                  _CampoTexto(
                    controller: _unidadMonetariaController,
                    label: AppLocalizations.of(context)!.unidadMonetaria,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección características físicas
              _SeccionFormulario(
                titulo: AppLocalizations.of(context)!.caractFisicas,
                children: [
                  _CampoTexto(
                    controller: _composicionController,
                    label: AppLocalizations.of(context)!.composicion,
                  ),
                  _CampoNumero(
                    controller: _pesoController,
                    label: '${AppLocalizations.of(context)!.peso} (g)',
                  ),
                  _CampoNumero(
                    controller: _diametroController,
                    label: '${AppLocalizations.of(context)!.diametro} (mm)',
                  ),
                  _CampoNumero(
                    controller: _grosorController,
                    label: '${AppLocalizations.of(context)!.grosor} (mm)',
                  ),
                  _CampoTexto(
                    controller: _formaController,
                    label: AppLocalizations.of(context)!.forma,
                  ),
                  _CampoTexto(
                    controller: _tecnicaController,
                    label: AppLocalizations.of(context)!.tecnicaAcuniacion,
                  ),
                  _CampoTexto(
                    controller: _estadoConservacionController,
                    label: AppLocalizations.of(context)!.estadoConservacion,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sección subasta
              _SeccionFormulario(
                titulo: AppLocalizations.of(context)!.configuracionSubasta,
                children: [
                  // Precio de salida
                  _CampoNumero(
                    controller: _precioSalidaController,
                    label: AppLocalizations.of(context)!.precioSalida,
                  ),
                  const SizedBox(height: 4),

                  // Seleccionar fecha y hora de fin
              Text(
                AppLocalizations.of(context)!.duracionSubasta,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
                ),
              ),
              const SizedBox(height: 8),
              
              InkWell(
                onTap: _seleccionarFechaHora,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fechaFinElegida == null
                            ? AppLocalizations.of(context)!.seleccionarFechaFin
                            : _formatearFecha(context, _fechaFinElegida!),
                        style: TextStyle(
                          color: _fechaFinElegida == null
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFFB8860B)),
                    ],
                  ),
                ),
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
                      : Text(
                    AppLocalizations.of(context)!.publicar,
                    style: const TextStyle(fontSize: 16),
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

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null) {
        setState(() {
          _fechaFinElegida = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  // Formatear la fecha elegida
  String _formatearFecha(BuildContext context, DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${AppLocalizations.of(context)!.alas} ${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }
}

// Widgets reutilizables (mismos que en publicar_venta_screen)
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
        color: Theme.of(context).cardColor,
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

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _CampoTexto({required this.controller, required this.label});

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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.esteCampoObligatorio;
        }
        return null;
      },
    );
  }
}

class _CampoNumero extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _CampoNumero({required this.controller, required this.label});

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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.esteCampoObligatorio;
        }
        if (double.tryParse(value) == null) {
          return AppLocalizations.of(context)!.introduceNumeroValido;
        }
        if (double.parse(value) <= 0) {
          return AppLocalizations.of(context)!.valorMayorCero;
        }
        return null;
      },
    );
  }
}
