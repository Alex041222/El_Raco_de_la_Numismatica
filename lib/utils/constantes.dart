import 'package:flutter/material.dart';

// Color principal de la app (dorado)
const Color kColorPrimario = Color(0xFFB8860B);

// Color de fondo crema
const Color kColorFondo = Color(0xFFFAF7F2);

// Foto de perfil por defecto cuando el usuario no tiene foto
const String kFotoPerfilDefault = 'assets/images/default_avatar.png';

// Duración máxima de las subastas en días
const List<int> kDuracionesSubasta = [1, 3, 7, 14];

// Número máximo de imágenes por moneda
const int kMaxImagenesMoneda = 5;

// Número máximo de vendedores recomendados
const int kMaxVendedoresRecomendados = 20;

// Tipos de venta
const String kTipoVentaDirecta = 'directa';
const String kTipoVentaSubasta = 'subasta';

// Tipos de reseña
const String kResenaPositiva = 'positivo';
const String kResenaNegativa = 'negativo';

// Nombres de las colecciones de Firestore
const String kColeccionUsuarios = 'usuarios';
const String kColeccionMonedasVenta = 'monedas_venta';
const String kColeccionMonedasSubasta = 'monedas_subasta';
const String kColeccionPujas = 'pujas';
const String kColeccionPedidos = 'pedidos';
const String kColeccionItemsPedido = 'items_pedido';
const String kColeccionChats = 'chats';
const String kColeccionMensajes = 'mensajes';
const String kColeccionResenas = 'resenas';