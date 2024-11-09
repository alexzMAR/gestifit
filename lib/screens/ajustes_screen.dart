// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestifit/providers/theme_notifier.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool mensajesPush = false;
  bool actividadCuentaPush = false;
  bool anunciosProductoPush = false;
  bool recomendacionesPush = false;
  bool mensajesTexto = false;
  bool actividadCuentaTexto = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    bool isDarkTheme = themeNotifier.isDarkTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Switch(
            value: isDarkTheme,
            onChanged: (bool value) {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'NOTIFICACIONES PUSH',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Mensajes'),
            subtitle: const Text('De amigos'),
            value: mensajesPush,
            onChanged: (bool value) {
              setState(() {
                mensajesPush = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Actividad de la cuenta'),
            subtitle: const Text('Cambios realizados en tu cuenta'),
            value: actividadCuentaPush,
            onChanged: (bool value) {
              setState(() {
                actividadCuentaPush = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Anuncios de productos'),
            subtitle: const Text('Actualizaciones de funciones y más'),
            value: anunciosProductoPush,
            onChanged: (bool value) {
              setState(() {
                anunciosProductoPush = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Recomendaciones'),
            subtitle: const Text('Ideas y alertas de precios'),
            value: recomendacionesPush,
            onChanged: (bool value) {
              setState(() {
                recomendacionesPush = value;
              });
            },
          ),
          const Divider(),
          const Text(
            'NOTIFICACIONES DE MENSAJES DE TEXTO',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Mensajes'),
            subtitle: const Text('De amigos'),
            value: mensajesTexto,
            onChanged: (bool value) {
              setState(() {
                mensajesTexto = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Actividad de la cuenta'),
            subtitle: const Text('Cambios realizados en tu cuenta'),
            value: actividadCuentaTexto,
            onChanged: (bool value) {
              setState(() {
                actividadCuentaTexto = value;
              });
            },
          ),
          const SizedBox(height: 40), // Espacio antes del botón
          ElevatedButton(
            onPressed: () {
              // Acción para cerrar sesión
              // Aquí puedes agregar la lógica para cerrar sesión
              Navigator.pushReplacementNamed(
                  context, '/login'); // Ejemplo de navegación
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Color de fondo
              foregroundColor: Colors.white, // Color del texto
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
              ),
              elevation: 8, // Sombra
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
