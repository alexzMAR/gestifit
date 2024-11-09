import 'package:flutter/material.dart';

class ObjetivosScreen extends StatelessWidget {
  const ObjetivosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Botón de volver
          },
        ),
        title: const Text('Definir Objetivos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Perder Peso'),
              value: true,
              onChanged: (bool? value) {
                // Lógica para actualizar
              },
            ),
            CheckboxListTile(
              title: const Text('Ganar Masa Muscular'),
              value: false,
              onChanged: (bool? value) {
                // Lógica para actualizar
              },
            ),
            const TextField(
              decoration:
                  InputDecoration(labelText: 'Establecer plazo en semanas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Guardar objetivos
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
