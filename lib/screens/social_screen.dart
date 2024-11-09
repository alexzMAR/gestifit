import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Agrega el engranaje para los ajustes
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navegar a la pantalla de ajustes
              Navigator.pushNamed(context, '/ajustes');
            },
          ),
        ],
        title: const Text('Social'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/avatar_placeholder.png'),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Michael Jordan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('ID: SDASV565DSDSA55984',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Invitación a un amigo
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Invita a un colega',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Image.asset('assets/friends_placeholder.png',
                          height: 50), // Imagen simulada
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Acción de invitar a un amigo
                        },
                        child: const Text('Invita a un amigo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sección de Progreso
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
              // Botón de Logros
              const Text('Logros Desbloqueados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Acción para compartir el progreso
                  Navigator.pushNamed(context, '/compartir_progreso');
                },
                child: const Text('Compartir progreso'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
