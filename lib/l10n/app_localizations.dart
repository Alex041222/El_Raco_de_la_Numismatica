import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ca, this message translates to:
  /// **'El Racó de la Numismàtica'**
  String get appTitle;

  /// No description provided for @ajustes.
  ///
  /// In ca, this message translates to:
  /// **'Ajustos'**
  String get ajustes;

  /// No description provided for @modoFosc.
  ///
  /// In ca, this message translates to:
  /// **'Mode Fosc'**
  String get modoFosc;

  /// No description provided for @idioma.
  ///
  /// In ca, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @perfil.
  ///
  /// In ca, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @editarPerfil.
  ///
  /// In ca, this message translates to:
  /// **'Editar Perfil'**
  String get editarPerfil;

  /// No description provided for @tancarSessio.
  ///
  /// In ca, this message translates to:
  /// **'Tancar Sessió'**
  String get tancarSessio;

  /// No description provided for @compres.
  ///
  /// In ca, this message translates to:
  /// **'Compres'**
  String get compres;

  /// No description provided for @subhastes.
  ///
  /// In ca, this message translates to:
  /// **'Subhastes'**
  String get subhastes;

  /// No description provided for @vendes.
  ///
  /// In ca, this message translates to:
  /// **'Vendes'**
  String get vendes;

  /// No description provided for @ressenyes.
  ///
  /// In ca, this message translates to:
  /// **'Ressenyes'**
  String get ressenyes;

  /// No description provided for @capRessenya.
  ///
  /// In ca, this message translates to:
  /// **'Encara no tens ressenyes'**
  String get capRessenya;

  /// No description provided for @comprar.
  ///
  /// In ca, this message translates to:
  /// **'Comprar'**
  String get comprar;

  /// No description provided for @pujar.
  ///
  /// In ca, this message translates to:
  /// **'Pujar'**
  String get pujar;

  /// No description provided for @preuActual.
  ///
  /// In ca, this message translates to:
  /// **'Preu actual'**
  String get preuActual;

  /// No description provided for @tempsRestant.
  ///
  /// In ca, this message translates to:
  /// **'Temps restant'**
  String get tempsRestant;

  /// No description provided for @iniciarSessio.
  ///
  /// In ca, this message translates to:
  /// **'Iniciar sessió'**
  String get iniciarSessio;

  /// No description provided for @registre.
  ///
  /// In ca, this message translates to:
  /// **'Registrar-se'**
  String get registre;

  /// No description provided for @email.
  ///
  /// In ca, this message translates to:
  /// **'Correu electrònic'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ca, this message translates to:
  /// **'Contrasenya'**
  String get password;

  /// No description provided for @confirmarPassword.
  ///
  /// In ca, this message translates to:
  /// **'Confirmar contrasenya'**
  String get confirmarPassword;

  /// No description provided for @guardar.
  ///
  /// In ca, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @cancelar.
  ///
  /// In ca, this message translates to:
  /// **'Cancel·lar'**
  String get cancelar;

  /// No description provided for @cataleg.
  ///
  /// In ca, this message translates to:
  /// **'Catàleg'**
  String get cataleg;

  /// No description provided for @xats.
  ///
  /// In ca, this message translates to:
  /// **'Xats'**
  String get xats;

  /// No description provided for @topVenedors.
  ///
  /// In ca, this message translates to:
  /// **'   Top\nVenedors'**
  String get topVenedors;

  /// No description provided for @buscar.
  ///
  /// In ca, this message translates to:
  /// **'Buscar'**
  String get buscar;

  /// No description provided for @carrito.
  ///
  /// In ca, this message translates to:
  /// **'Carret'**
  String get carrito;

  /// No description provided for @misCompras.
  ///
  /// In ca, this message translates to:
  /// **'Les meves compres'**
  String get misCompras;

  /// No description provided for @misVentas.
  ///
  /// In ca, this message translates to:
  /// **'En venda'**
  String get misVentas;

  /// No description provided for @valoraciones.
  ///
  /// In ca, this message translates to:
  /// **'Valoracions'**
  String get valoraciones;

  /// No description provided for @reputacion.
  ///
  /// In ca, this message translates to:
  /// **'punts de reputació'**
  String get reputacion;

  /// No description provided for @dejarResena.
  ///
  /// In ca, this message translates to:
  /// **'Deixar ressenya'**
  String get dejarResena;

  /// No description provided for @positivo.
  ///
  /// In ca, this message translates to:
  /// **'Positiu'**
  String get positivo;

  /// No description provided for @negativo.
  ///
  /// In ca, this message translates to:
  /// **'Negatiu'**
  String get negativo;

  /// No description provided for @comentario.
  ///
  /// In ca, this message translates to:
  /// **'Comentari'**
  String get comentario;

  /// No description provided for @enviar.
  ///
  /// In ca, this message translates to:
  /// **'Enviar'**
  String get enviar;

  /// No description provided for @escribeComentario.
  ///
  /// In ca, this message translates to:
  /// **'Escriu el teu comentari...'**
  String get escribeComentario;

  /// No description provided for @noHayMonedas.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha monedes'**
  String get noHayMonedas;

  /// No description provided for @noHaySubastas.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha subhastes'**
  String get noHaySubastas;

  /// No description provided for @noHayCompras.
  ///
  /// In ca, this message translates to:
  /// **'No has fet cap compra'**
  String get noHayCompras;

  /// No description provided for @soloTusCompras.
  ///
  /// In ca, this message translates to:
  /// **'Només pots veure les teves pròpies compres'**
  String get soloTusCompras;

  /// No description provided for @disponible.
  ///
  /// In ca, this message translates to:
  /// **'Disponible'**
  String get disponible;

  /// No description provided for @venut.
  ///
  /// In ca, this message translates to:
  /// **'Venut'**
  String get venut;

  /// No description provided for @terminada.
  ///
  /// In ca, this message translates to:
  /// **'Acabada'**
  String get terminada;

  /// No description provided for @termina.
  ///
  /// In ca, this message translates to:
  /// **'Acaba'**
  String get termina;

  /// No description provided for @hintBuscar.
  ///
  /// In ca, this message translates to:
  /// **'Busca per nom, país, període...'**
  String get hintBuscar;

  /// No description provided for @noResultados.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han trobat resultats'**
  String get noResultados;

  /// No description provided for @noChatearContigo.
  ///
  /// In ca, this message translates to:
  /// **'No pots xatejar amb tu mateix'**
  String get noChatearContigo;

  /// No description provided for @errorChat.
  ///
  /// In ca, this message translates to:
  /// **'Error en obrir el xat'**
  String get errorChat;

  /// No description provided for @monedaNoEncontrada.
  ///
  /// In ca, this message translates to:
  /// **'Moneda no trobada'**
  String get monedaNoEncontrada;

  /// No description provided for @infoGeneral.
  ///
  /// In ca, this message translates to:
  /// **'Informació general'**
  String get infoGeneral;

  /// No description provided for @pais.
  ///
  /// In ca, this message translates to:
  /// **'País'**
  String get pais;

  /// No description provided for @periodo.
  ///
  /// In ca, this message translates to:
  /// **'Període'**
  String get periodo;

  /// No description provided for @unidadMonetaria.
  ///
  /// In ca, this message translates to:
  /// **'Unitat monetària'**
  String get unidadMonetaria;

  /// No description provided for @caractFisicas.
  ///
  /// In ca, this message translates to:
  /// **'Característiques físiques'**
  String get caractFisicas;

  /// No description provided for @composicion.
  ///
  /// In ca, this message translates to:
  /// **'Composició'**
  String get composicion;

  /// No description provided for @peso.
  ///
  /// In ca, this message translates to:
  /// **'Pes'**
  String get peso;

  /// No description provided for @diametro.
  ///
  /// In ca, this message translates to:
  /// **'Diàmetre'**
  String get diametro;

  /// No description provided for @grosor.
  ///
  /// In ca, this message translates to:
  /// **'Gruix'**
  String get grosor;

  /// No description provided for @forma.
  ///
  /// In ca, this message translates to:
  /// **'Forma'**
  String get forma;

  /// No description provided for @tecnicaAcuniacion.
  ///
  /// In ca, this message translates to:
  /// **'Tècnica d\'encunyació'**
  String get tecnicaAcuniacion;

  /// No description provided for @estadoConservacion.
  ///
  /// In ca, this message translates to:
  /// **'Estat de conservació'**
  String get estadoConservacion;

  /// No description provided for @anadidoCarrito.
  ///
  /// In ca, this message translates to:
  /// **'Afegit al carret'**
  String get anadidoCarrito;

  /// No description provided for @agregarCarrito.
  ///
  /// In ca, this message translates to:
  /// **'Afegir al carret'**
  String get agregarCarrito;

  /// No description provided for @contactarVendedor.
  ///
  /// In ca, this message translates to:
  /// **'Contactar amb el venedor'**
  String get contactarVendedor;

  /// No description provided for @estaMonedaEsTuya.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta moneda és teva'**
  String get estaMonedaEsTuya;

  /// No description provided for @noPujarTuya.
  ///
  /// In ca, this message translates to:
  /// **'No pots pujar en la teva pròpia subhasta'**
  String get noPujarTuya;

  /// No description provided for @realizarPuja.
  ///
  /// In ca, this message translates to:
  /// **'Realitzar puja'**
  String get realizarPuja;

  /// No description provided for @tuPujaDebeSerMayor.
  ///
  /// In ca, this message translates to:
  /// **'La teva puja ha de ser major que'**
  String get tuPujaDebeSerMayor;

  /// No description provided for @tuPujaEuro.
  ///
  /// In ca, this message translates to:
  /// **'La teva puja (€)'**
  String get tuPujaEuro;

  /// No description provided for @importeValido.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un import vàlid'**
  String get importeValido;

  /// No description provided for @pujaCorrecta.
  ///
  /// In ca, this message translates to:
  /// **'Puja realitzada correctament'**
  String get pujaCorrecta;

  /// No description provided for @restantes.
  ///
  /// In ca, this message translates to:
  /// **'restants'**
  String get restantes;

  /// No description provided for @subastaNoEncontrada.
  ///
  /// In ca, this message translates to:
  /// **'Subhasta no trobada'**
  String get subastaNoEncontrada;

  /// No description provided for @pujaActual.
  ///
  /// In ca, this message translates to:
  /// **'Puja actual'**
  String get pujaActual;

  /// No description provided for @hasGanadoSubasta.
  ///
  /// In ca, this message translates to:
  /// **'Has guanyat aquesta subhasta!'**
  String get hasGanadoSubasta;

  /// No description provided for @irCarritoPagar.
  ///
  /// In ca, this message translates to:
  /// **'Anar al carret a pagar'**
  String get irCarritoPagar;

  /// No description provided for @yaTieneGanador.
  ///
  /// In ca, this message translates to:
  /// **'Subhasta acabada. Ja té guanyador.'**
  String get yaTieneGanador;

  /// No description provided for @terminadaSinPujas.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta subhasta ha acabat sense pujes.'**
  String get terminadaSinPujas;

  /// No description provided for @estaEsTuSubasta.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta és la teva subhasta'**
  String get estaEsTuSubasta;

  /// No description provided for @subastasActivas.
  ///
  /// In ca, this message translates to:
  /// **'Subhastes actives'**
  String get subastasActivas;

  /// No description provided for @noHaySubastasActivas.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha subhastes actives'**
  String get noHaySubastasActivas;

  /// No description provided for @historialPujas.
  ///
  /// In ca, this message translates to:
  /// **'Historial de pujes'**
  String get historialPujas;

  /// No description provided for @noHayPujas.
  ///
  /// In ca, this message translates to:
  /// **'Encara no hi ha pujes'**
  String get noHayPujas;

  /// No description provided for @ganando.
  ///
  /// In ca, this message translates to:
  /// **'Guanyant'**
  String get ganando;

  /// No description provided for @confirmarCompra.
  ///
  /// In ca, this message translates to:
  /// **'Confirmar compra'**
  String get confirmarCompra;

  /// No description provided for @totalPagar.
  ///
  /// In ca, this message translates to:
  /// **'Total a pagar'**
  String get totalPagar;

  /// No description provided for @envio.
  ///
  /// In ca, this message translates to:
  /// **'Enviament'**
  String get envio;

  /// No description provided for @direccionEnvio.
  ///
  /// In ca, this message translates to:
  /// **'Adreça d\'enviament'**
  String get direccionEnvio;

  /// No description provided for @hintDireccion.
  ///
  /// In ca, this message translates to:
  /// **'Carrer, número, ciutat...'**
  String get hintDireccion;

  /// No description provided for @direccionObligatoria.
  ///
  /// In ca, this message translates to:
  /// **'L\'adreça és obligatòria'**
  String get direccionObligatoria;

  /// No description provided for @telefonoContacto.
  ///
  /// In ca, this message translates to:
  /// **'Telèfon de contacte'**
  String get telefonoContacto;

  /// No description provided for @telefonoObligatorio.
  ///
  /// In ca, this message translates to:
  /// **'El telèfon és obligatori'**
  String get telefonoObligatorio;

  /// No description provided for @telefonoValido.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un telèfon vàlid'**
  String get telefonoValido;

  /// No description provided for @datosPago.
  ///
  /// In ca, this message translates to:
  /// **'Dades de pagament'**
  String get datosPago;

  /// No description provided for @numTarjeta.
  ///
  /// In ca, this message translates to:
  /// **'Número de targeta'**
  String get numTarjeta;

  /// No description provided for @introduce16.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix els 16 dígits'**
  String get introduce16;

  /// No description provided for @caducidad.
  ///
  /// In ca, this message translates to:
  /// **'Caducitat'**
  String get caducidad;

  /// No description provided for @formatoMMAA.
  ///
  /// In ca, this message translates to:
  /// **'Format MM/AA'**
  String get formatoMMAA;

  /// No description provided for @cvv.
  ///
  /// In ca, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @min3Digitos.
  ///
  /// In ca, this message translates to:
  /// **'Mín. 3 dígits'**
  String get min3Digitos;

  /// No description provided for @pagoSimulado.
  ///
  /// In ca, this message translates to:
  /// **'🔒 Pagament simulat — no es realitzarà cap càrrec real'**
  String get pagoSimulado;

  /// No description provided for @pagar.
  ///
  /// In ca, this message translates to:
  /// **'Pagar'**
  String get pagar;

  /// No description provided for @compraCorrecta.
  ///
  /// In ca, this message translates to:
  /// **'Compra realitzada correctament!'**
  String get compraCorrecta;

  /// No description provided for @errorCompra.
  ///
  /// In ca, this message translates to:
  /// **'Error en realitzar la compra'**
  String get errorCompra;

  /// No description provided for @vaciarCarrito.
  ///
  /// In ca, this message translates to:
  /// **'Buidar carret'**
  String get vaciarCarrito;

  /// No description provided for @seguroVaciar.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols buidar el carret?'**
  String get seguroVaciar;

  /// No description provided for @vaciar.
  ///
  /// In ca, this message translates to:
  /// **'Buidar'**
  String get vaciar;

  /// No description provided for @carritoVacio.
  ///
  /// In ca, this message translates to:
  /// **'El teu carret està buit'**
  String get carritoVacio;

  /// No description provided for @anadeMonedas.
  ///
  /// In ca, this message translates to:
  /// **'Afegeix monedes des del catàleg'**
  String get anadeMonedas;

  /// No description provided for @subastaGanada.
  ///
  /// In ca, this message translates to:
  /// **'Subhasta guanyada'**
  String get subastaGanada;

  /// No description provided for @total.
  ///
  /// In ca, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @introduceEmail.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu correu electrònic'**
  String get introduceEmail;

  /// No description provided for @emailNoValido.
  ///
  /// In ca, this message translates to:
  /// **'El correu electrònic no és vàlid'**
  String get emailNoValido;

  /// No description provided for @introducePassword.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix la teva contrasenya'**
  String get introducePassword;

  /// No description provided for @passwordCorto.
  ///
  /// In ca, this message translates to:
  /// **'La contrasenya ha de tenir almenys 6 caràcters'**
  String get passwordCorto;

  /// No description provided for @noTienesCuenta.
  ///
  /// In ca, this message translates to:
  /// **'No tens compte? Registra\'t'**
  String get noTienesCuenta;

  /// No description provided for @yaTienesCuenta.
  ///
  /// In ca, this message translates to:
  /// **'Ja tens compte? Inicia sessió'**
  String get yaTienesCuenta;

  /// No description provided for @crearCuenta.
  ///
  /// In ca, this message translates to:
  /// **'Crear compte'**
  String get crearCuenta;

  /// No description provided for @passwordsNoCoinciden.
  ///
  /// In ca, this message translates to:
  /// **'Les contrasenyes no coincideixen'**
  String get passwordsNoCoinciden;

  /// No description provided for @completaPerfil.
  ///
  /// In ca, this message translates to:
  /// **'Completa el teu perfil'**
  String get completaPerfil;

  /// No description provided for @antesContinuar.
  ///
  /// In ca, this message translates to:
  /// **'Abans de continuar necessitem algunes dades'**
  String get antesContinuar;

  /// No description provided for @anadirFotoOpcional.
  ///
  /// In ca, this message translates to:
  /// **'Toca per afegir foto (opcional)'**
  String get anadirFotoOpcional;

  /// No description provided for @nombreUsuario.
  ///
  /// In ca, this message translates to:
  /// **'Nom d\'usuari'**
  String get nombreUsuario;

  /// No description provided for @nombreObligatorio.
  ///
  /// In ca, this message translates to:
  /// **'El nom d\'usuari és obligatori'**
  String get nombreObligatorio;

  /// No description provided for @nombreCorto.
  ///
  /// In ca, this message translates to:
  /// **'El nom ha de tenir almenys 3 caràcters'**
  String get nombreCorto;

  /// No description provided for @biografiaOpcional.
  ///
  /// In ca, this message translates to:
  /// **'Biografia (opcional)'**
  String get biografiaOpcional;

  /// No description provided for @direccionOpcional.
  ///
  /// In ca, this message translates to:
  /// **'Adreça (opcional)'**
  String get direccionOpcional;

  /// No description provided for @guardarContinuar.
  ///
  /// In ca, this message translates to:
  /// **'Guardar i continuar'**
  String get guardarContinuar;

  /// No description provided for @errorPerfil.
  ///
  /// In ca, this message translates to:
  /// **'Error en guardar el perfil'**
  String get errorPerfil;

  /// No description provided for @conversacion.
  ///
  /// In ca, this message translates to:
  /// **'Conversa'**
  String get conversacion;

  /// No description provided for @iniciaConversacion.
  ///
  /// In ca, this message translates to:
  /// **'Inicia la conversa'**
  String get iniciaConversacion;

  /// No description provided for @escribeMensaje.
  ///
  /// In ca, this message translates to:
  /// **'Escriu un missatge...'**
  String get escribeMensaje;

  /// No description provided for @cargando.
  ///
  /// In ca, this message translates to:
  /// **'Carregant...'**
  String get cargando;

  /// No description provided for @errorEnviar.
  ///
  /// In ca, this message translates to:
  /// **'Error en enviar'**
  String get errorEnviar;

  /// No description provided for @errorEnviarImagen.
  ///
  /// In ca, this message translates to:
  /// **'Error en enviar la imatge'**
  String get errorEnviarImagen;

  /// No description provided for @noConversaciones.
  ///
  /// In ca, this message translates to:
  /// **'No tens converses'**
  String get noConversaciones;

  /// No description provided for @contactarVendedorCatalogo.
  ///
  /// In ca, this message translates to:
  /// **'Contacta amb un venedor des del catàleg'**
  String get contactarVendedorCatalogo;

  /// No description provided for @ayer.
  ///
  /// In ca, this message translates to:
  /// **'Ahir'**
  String get ayer;

  /// No description provided for @activat.
  ///
  /// In ca, this message translates to:
  /// **'Activat'**
  String get activat;

  /// No description provided for @desactivat.
  ///
  /// In ca, this message translates to:
  /// **'Desactivat'**
  String get desactivat;

  /// No description provided for @info.
  ///
  /// In ca, this message translates to:
  /// **'Informació'**
  String get info;

  /// No description provided for @version.
  ///
  /// In ca, this message translates to:
  /// **'Versió'**
  String get version;

  /// No description provided for @publicarVenta.
  ///
  /// In ca, this message translates to:
  /// **'Publicar moneda en venda'**
  String get publicarVenta;

  /// No description provided for @publicarSubasta.
  ///
  /// In ca, this message translates to:
  /// **'Publicar subhasta'**
  String get publicarSubasta;

  /// No description provided for @nomMoneda.
  ///
  /// In ca, this message translates to:
  /// **'Nom de la moneda'**
  String get nomMoneda;

  /// No description provided for @nomObligatorioMoneda.
  ///
  /// In ca, this message translates to:
  /// **'El nom és obligatori'**
  String get nomObligatorioMoneda;

  /// No description provided for @precioVenta.
  ///
  /// In ca, this message translates to:
  /// **'Preu de venda (€)'**
  String get precioVenta;

  /// No description provided for @precioObligatorio.
  ///
  /// In ca, this message translates to:
  /// **'El preu és obligatori'**
  String get precioObligatorio;

  /// No description provided for @precioInicial.
  ///
  /// In ca, this message translates to:
  /// **'Preu inicial (€)'**
  String get precioInicial;

  /// No description provided for @duracionSubasta.
  ///
  /// In ca, this message translates to:
  /// **'Durada de la subhasta (dies)'**
  String get duracionSubasta;

  /// No description provided for @imagenesMoneda.
  ///
  /// In ca, this message translates to:
  /// **'Imatges de la moneda (màx. 5)'**
  String get imagenesMoneda;

  /// No description provided for @max5Imagenes.
  ///
  /// In ca, this message translates to:
  /// **'Màxim 5 imatges'**
  String get max5Imagenes;

  /// No description provided for @alMenosUnaImagen.
  ///
  /// In ca, this message translates to:
  /// **'Afegeix almenys una imatge'**
  String get alMenosUnaImagen;

  /// No description provided for @publicar.
  ///
  /// In ca, this message translates to:
  /// **'Publicar'**
  String get publicar;

  /// No description provided for @publicadoCorrecto.
  ///
  /// In ca, this message translates to:
  /// **'Publicat correctament'**
  String get publicadoCorrecto;

  /// No description provided for @esteCampoObligatorio.
  ///
  /// In ca, this message translates to:
  /// **'Aquest camp és obligatori'**
  String get esteCampoObligatorio;

  /// No description provided for @introduceNumeroValido.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix un número vàlid'**
  String get introduceNumeroValido;

  /// No description provided for @valorMayorCero.
  ///
  /// In ca, this message translates to:
  /// **'El valor ha de ser major que 0'**
  String get valorMayorCero;

  /// No description provided for @imagenes.
  ///
  /// In ca, this message translates to:
  /// **'Imatges'**
  String get imagenes;

  /// No description provided for @precio.
  ///
  /// In ca, this message translates to:
  /// **'Preu'**
  String get precio;

  /// No description provided for @configuracionSubasta.
  ///
  /// In ca, this message translates to:
  /// **'Configuració de la subhasta'**
  String get configuracionSubasta;

  /// No description provided for @precioSalida.
  ///
  /// In ca, this message translates to:
  /// **'Preu de sortida (€)'**
  String get precioSalida;

  /// No description provided for @seleccionarFechaFin.
  ///
  /// In ca, this message translates to:
  /// **'Seleccionar data i hora de fi'**
  String get seleccionarFechaFin;

  /// No description provided for @alas.
  ///
  /// In ca, this message translates to:
  /// **'a les'**
  String get alas;

  /// No description provided for @escribeComentarioObligatorio.
  ///
  /// In ca, this message translates to:
  /// **'Escriu un comentari'**
  String get escribeComentarioObligatorio;

  /// No description provided for @resenaEnviada.
  ///
  /// In ca, this message translates to:
  /// **'Ressenya enviada correctament'**
  String get resenaEnviada;

  /// No description provided for @perfilActualizado.
  ///
  /// In ca, this message translates to:
  /// **'Perfil actualitzat correctament'**
  String get perfilActualizado;

  /// No description provided for @errorGuardar.
  ///
  /// In ca, this message translates to:
  /// **'Error en guardar'**
  String get errorGuardar;

  /// No description provided for @monedaPublicada.
  ///
  /// In ca, this message translates to:
  /// **'Moneda publicada correctament'**
  String get monedaPublicada;

  /// No description provided for @errorPublicar.
  ///
  /// In ca, this message translates to:
  /// **'Error en publicar'**
  String get errorPublicar;

  /// No description provided for @fechaFinValida.
  ///
  /// In ca, this message translates to:
  /// **'Selecciona una data de fi vàlida (en el futur)'**
  String get fechaFinValida;

  /// No description provided for @subastaNoExiste.
  ///
  /// In ca, this message translates to:
  /// **'La subhasta no existeix'**
  String get subastaNoExiste;

  /// No description provided for @subastaTerminada.
  ///
  /// In ca, this message translates to:
  /// **'La subhasta ja ha acabat'**
  String get subastaTerminada;

  /// No description provided for @subastaCaducada.
  ///
  /// In ca, this message translates to:
  /// **'La subhasta ha caducat'**
  String get subastaCaducada;

  /// No description provided for @pujaMayorPrecio.
  ///
  /// In ca, this message translates to:
  /// **'La puja ha de ser major que el preu actual'**
  String get pujaMayorPrecio;

  /// No description provided for @resenaYaExiste.
  ///
  /// In ca, this message translates to:
  /// **'Ja has deixat una ressenya a aquest venedor'**
  String get resenaYaExiste;

  /// No description provided for @resenaATiMismo.
  ///
  /// In ca, this message translates to:
  /// **'No pots deixar-te una ressenya a tu mateix'**
  String get resenaATiMismo;

  /// No description provided for @monedaNoDisponible.
  ///
  /// In ca, this message translates to:
  /// **'Una de les monedes ja no està disponible o ha estat eliminada pel venedor.'**
  String get monedaNoDisponible;

  /// No description provided for @monedaNoExiste.
  ///
  /// In ca, this message translates to:
  /// **'Una de les monedes ja no existeix a la base de dades.'**
  String get monedaNoExiste;

  /// No description provided for @nombreUsuarioEnUso.
  ///
  /// In ca, this message translates to:
  /// **'El nom d\'usuari ja està escollit, tria\'n un altre'**
  String get nombreUsuarioEnUso;

  /// No description provided for @venedorsRecomanats.
  ///
  /// In ca, this message translates to:
  /// **'Venedors recomanats'**
  String get venedorsRecomanats;

  /// No description provided for @noVenedors.
  ///
  /// In ca, this message translates to:
  /// **'Encara no hi ha venedors'**
  String get noVenedors;

  /// No description provided for @venedorsMasRessenyes.
  ///
  /// In ca, this message translates to:
  /// **'Els venedors amb més ressenyes positives apareixeran aquí'**
  String get venedorsMasRessenyes;

  /// No description provided for @tocaCambiarFoto.
  ///
  /// In ca, this message translates to:
  /// **'Toca per canviar la foto'**
  String get tocaCambiarFoto;

  /// No description provided for @guardarCambios.
  ///
  /// In ca, this message translates to:
  /// **'Guardar canvis'**
  String get guardarCambios;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
