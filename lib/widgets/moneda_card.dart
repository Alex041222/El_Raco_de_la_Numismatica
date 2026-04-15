import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/moneda_venta_model.dart';
import '../utils/constantes.dart';

// Widget reutilizable de tarjeta de moneda en venta
// Se usa en el catálogo y en el perfil del vendedor
class MonedaCard extends StatelessWidget {
  final MonedaVenta moneda;
  final bool enCarrito;
  final VoidCallback onTap;
  final VoidCallback? onAgregar; // null si no se puede agregar al carrito

  const MonedaCard({
    super.key,
    required this.moneda,
    required this.onTap,
    this.enCarrito = false,
    this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Imagen de la moneda
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen principal
                    moneda.imagenes.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: moneda.imagenes.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: kColorPrimario,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.monetization_on,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : const Center(
                      child: Icon(
                        Icons.monetization_on,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),

                    // Badge disponible / vendida
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: moneda.disponible
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          moneda.disponible ? 'Disponible' : 'Vendida',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Información de la moneda
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emisor y país
                  Text(
                    '${moneda.emisor} - ${moneda.pais}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Periodo
                  Text(
                    moneda.periodo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Precio y botón agregar al carrito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio
                      Text(
                        '${moneda.precio.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kColorPrimario,
                        ),
                      ),

                      // Botón agregar al carrito
                      if (onAgregar != null)
                        GestureDetector(
                          onTap: enCarrito ? null : onAgregar,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: enCarrito
                                  ? Colors.grey.shade300
                                  : kColorPrimario,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              enCarrito
                                  ? Icons.check
                                  : Icons.add_shopping_cart,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}