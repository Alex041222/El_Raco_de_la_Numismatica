import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _verPassword = false;
  bool _verConfirmarPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Intentar el registro
    await authProvider.registrar(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // IMPORTANTE: Verificamos si no hubo error
    if (authProvider.error == null) {
      // El Router (router.dart) escucha los cambios del AuthProvider.
      // Automáticamente detectará que hay un usuario pero no tiene perfil,
      // y hará la redirección a /completar-perfil. No hace falta forzarlo aquí.
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
        authProvider.limpiarError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el authProvider para el estado de carga (CircularProgress)
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 600,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El Racó de la Numismàtica',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8860B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.crearCuenta,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.introduceEmail;
                      if (!value.contains('@')) return AppLocalizations.of(context)!.emailNoValido;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_verPassword,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_verPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.introducePassword;
                      if (value.length < 6) return AppLocalizations.of(context)!.passwordCorto;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirmar Password
                  TextFormField(
                    controller: _confirmarPasswordController,
                    obscureText: !_verConfirmarPassword,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.confirmarPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_verConfirmarPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _verConfirmarPassword = !_verConfirmarPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.introducePassword; // reuse or add confirm
                      if (value != _passwordController.text) return AppLocalizations.of(context)!.passwordsNoCoinciden;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.cargando ? null : _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB8860B),
                        foregroundColor: Colors.white,
                      ),
                      child: authProvider.cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(AppLocalizations.of(context)!.crearCuenta, style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      AppLocalizations.of(context)!.yaTienesCuenta,
                      style: TextStyle(color: Color(0xFFB8860B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
