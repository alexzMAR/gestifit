// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  // Método para invitar a un amigo
  Future<void> inviteFriend(BuildContext context) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, inicia sesión para invitar amigos.')),
      );
      return;
    }

    String invitationMessage =
        '¡Únete a la app! Mi ID de usuario es: $currentUserUid';

    // Usar el paquete share_plus para compartir
    Share.share(invitationMessage);
  }

  // Método para agregar un amigo
  Future<void> addFriend(BuildContext context, String friendUid) async {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, inicia sesión para agregar amigos.')),
      );
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Agregar el UID del amigo a la lista de amigos del usuario actual
      await firestore.collection('users').doc(currentUserUid).update({
        'friends': FieldValue.arrayUnion([friendUid])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigo agregado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar amigo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
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
                        AssetImage('assets/images/avatar_placeholder.png'),
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
              // Tarjeta de invitación
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
                      Image.asset('assets/friends_placeholder.png', height: 50),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          inviteFriend(context);
                        },
                        child: const Text('Invita a un amigo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Progreso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              const Text('Pérdida de Peso: 5.0 / 10.0'),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: 0.66,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 5),
              const Text('Ganancia Muscular: 3.0 / 5.0'),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: 0.88,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Colors.orange,
              ),
              const SizedBox(height: 5),
              const Text('Índice de Masa Corporal: 22.0 / 25.0'),
              const SizedBox(height: 20),
              const Text('Logros Desbloqueados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Compartir progreso
                  Share.share(
                      '¡Mira mi progreso en la app! Pérdida de peso: 5.0 / 10.0');
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
