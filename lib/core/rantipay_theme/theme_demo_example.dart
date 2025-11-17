import 'package:flutter/material.dart';
import 'ranti_theme.dart';
import 'theme_config.dart';

/// Ejemplo de demostración del nuevo sistema de temas RantiPay V2
/// Muestra cómo usar el nuevo sistema y verificar compatibilidad
class ThemeDemoExample extends StatefulWidget {
  const ThemeDemoExample({super.key});

  @override
  State<ThemeDemoExample> createState() => _ThemeDemoExampleState();
}

class _ThemeDemoExampleState extends State<ThemeDemoExample> {
  String currentThemeMode = RantiThemeConfig.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RantiPay Theme V2 Demo',
      theme: RantiPayTheme.getCurrentTheme(context),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RantiPay Theme V2 Demo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de tema
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selector de Tema',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildThemeChip('Claro', RantiThemeConfig.light),
                          _buildThemeChip('Oscuro', RantiThemeConfig.dark),
                          _buildThemeChip('Alto Contraste', RantiThemeConfig.highContrast),
                          _buildThemeChip('Sepia', RantiThemeConfig.sepia),
                          _buildThemeChip('TikTok', RantiThemeConfig.tiktok),
                          _buildThemeChip('Uber', RantiThemeConfig.uber),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Ejemplo de TextField
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campos de Texto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Nombre de usuario',
                          hintText: 'Ingresa tu nombre de usuario',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Ingresa tu contraseña',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: Icon(Icons.visibility),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Ejemplo de botones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Botones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Botón Primario'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Botón Secundario'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Botón de Texto'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Información del tema actual
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Tema',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Tema actual: $currentThemeMode'),
                      Text('Material 3: ${Theme.of(context).useMaterial3}'),
                      Text('Brillo: ${Theme.of(context).brightness}'),
                      Text('Color primario: ${Theme.of(context).colorScheme.primary}'),
                      Text('Color de superficie: ${Theme.of(context).colorScheme.surface}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeChip(String label, String themeMode) {
    final isSelected = currentThemeMode == themeMode;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            currentThemeMode = themeMode;
            RantiThemeConfig.updateThemeMode(themeMode);
          });
        }
      },
    );
  }
}

/// Función main para demostrar el uso
void main() {
  runApp(const ThemeDemoExample());
}