import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/resena_model.dart';
import '../utils/constantes.dart';

// Widget reutilizable de tarjeta de reseña
// Se usa en el perfil del vendedor para mostrar sus reseñas
class ResenaCard extends StatelessWidget {
  final Resena resena;
  final bool mostrarBotoneEliminar; // true si es el autor de la reseña
  final VoidCallback? onEliminar;

  const ResenaCard({
    super.key,
    required this.resena,
    this.mostrarBotoneEliminar = false,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final esPositiva = resena.tipo == kResenaPositiva;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Borde verde si es positiva, rojo si es negativa
        border: Border.all(
          color: esPositiva ? Colors.green.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Icono positivo / negativo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: esPositiva
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              esPositiva ? Icons.thumb_up : Icons.thumb_down,
              color: esPositiva ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Comentario y fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de reseña
                Text(
                  esPositiva ? 'Reseña positiva' : 'Reseña negativa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: esPositiva ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),

                // Comentario
                Text(
                  resena.comentario,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Fecha
                Text(
                  DateFormat('dd/MM/yyyy').format(resena.fechaCreacion),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Botón eliminar si es el autor
          if (mostrarBotoneEliminar && onEliminar != null)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.red, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar reseña'),
                    content: const Text(
                        '¿Estás seguro de que quieres eliminar esta reseña?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onEliminar!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
