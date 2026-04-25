import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/ajustes_provider.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ajustesProvider = Provider.of<AjustesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ajustes),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // SECCIÓN: APARIENCIA
          _buildSeccion(context, l10n.modoFosc),
          SwitchListTile(
            title: Text(l10n.modoFosc),
            subtitle: Text(ajustesProvider.isDarkMode ? l10n.activat : l10n.desactivat),
            secondary: Icon(
              ajustesProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: const Color(0xFFB8860B),
            ),
            activeColor: const Color(0xFFB8860B),
            value: ajustesProvider.isDarkMode,
            onChanged: (bool value) {
              ajustesProvider.toggleTheme(value);
            },
          ),

          const Divider(),

          // SECCIÓN: IDIOMA
          _buildSeccion(context, l10n.idioma),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFFB8860B)),
            title: Text(l10n.idioma),
            subtitle: Text(_getNombreIdioma(ajustesProvider.idioma)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _mostrarSelectorIdioma(context, ajustesProvider);
            },
          ),

          const Divider(),

          // SECCIÓN: INFORMACIÓN
          _buildSeccion(context, l10n.info),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFFB8860B)),
            title: Text(l10n.version),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(BuildContext context, String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getNombreIdioma(String code) {
    switch (code) {
      case 'ca': return 'Català';
      case 'es': return 'Castellano';
      case 'en': return 'English';
      default: return 'Català';
    }
  }

  void _mostrarSelectorIdioma(BuildContext context, AjustesProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.idioma,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildIdiomaOption(context, provider, 'ca', 'Català'),
              _buildIdiomaOption(context, provider, 'es', 'Castellano'),
              _buildIdiomaOption(context, provider, 'en', 'English'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdiomaOption(BuildContext context, AjustesProvider provider, String code, String nombre) {
    return ListTile(
      title: Text(nombre),
      leading: Radio<String>(
        value: code,
        groupValue: provider.idioma,
        activeColor: const Color(0xFFB8860B),
        onChanged: (String? value) {
          provider.setIdioma(value!);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        provider.setIdioma(code);
        Navigator.pop(context);
      },
    );
  }
}
