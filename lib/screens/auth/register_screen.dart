import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

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
      if (mounted) {
        // Forzamos la navegación a completar perfil.
        // Si el Router intenta mandarte a Home, esta instrucción
        // debería ganar si el Router tiene la excepción configurada.
        context.go('/completar-perfil');
      }
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
      backgroundColor: const Color(0xFFFAF7F2),
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
                    width: 250, // Reducido un poco para que quepa mejor en pantallas pequeñas
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8860B),
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
                      if (value == null || value.isEmpty) return 'Introduce tu email';
                      if (!value.contains('@')) return 'El email no es válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_verPassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_verPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Introduce tu contraseña';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirmar Password
                  TextFormField(
                    controller: _confirmarPasswordController,
                    obscureText: !_verConfirmarPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_verConfirmarPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _verConfirmarPassword = !_verConfirmarPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                      if (value != _passwordController.text) return 'Las contraseñas no coinciden';
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
                          : const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
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