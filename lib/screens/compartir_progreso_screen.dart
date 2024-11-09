import 'package:flutter/material.dart';

class CompartirProgresoScreen extends StatelessWidget {
  const CompartirProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
        title: const Text('Compartir Progreso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de progreso con las barras
            const Text('Progreso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.5, // Progreso de pérdida de peso
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 5),
            const Text('Pérdida de Peso: 5.0 / 10.0'),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.66, // Progreso de ganancia muscular
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            const SizedBox(height: 5),
            const Text('Ganancia Muscular: 3.0 / 5.0'),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.88, // Progreso del índice de masa corporal
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: Colors.orange,
            ),
            const SizedBox(height: 5),
            const Text('Índice de Masa Corporal: 22.0 / 25.0'),
            const SizedBox(height: 20),

            // Sección de logros desbloqueados
            const Text('Logros Desbloqueados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[50],
              ),
              child: Column(
                children: [
                  const Text('Has alcanzado 50% de pérdida de peso!',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Image.asset('assets/trophy_placeholder.png',
                      height: 50), // Imagen simulada
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón de compartir progreso
            ElevatedButton.icon(
              onPressed: () {
                // Acción para compartir progreso
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartir progreso'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50), // Botón que ocupa todo el ancho
              ),
            ),
          ],
        ),
      ),
    );
  }
}
