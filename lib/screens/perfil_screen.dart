// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = '';
  String _apellido = '';
  String _fechaRegistro = '';
  String _id = '';
  String _edad = '';
  String _peso = '';
  String _altura = '';
  String _genero = '';
  bool _isLoading = true;
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        String firebaseUid = currentUser.uid;

        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/usuario/$firebaseUid'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> userData =
              jsonDecode(response.body)['usuario'];

          setState(() {
            _nombre = userData['nombre'] ?? 'No disponible';
            _apellido = userData['apellido'] ?? 'No disponible';
            _fechaRegistro = userData['fecha_registro'] ?? 'No disponible';
            _id = userData['firebase_uid'] ?? 'No disponible';
            _edad = (userData['edad'] ?? '0')
                .toString(); // Asegura que sea un string
            _peso = (userData['peso'] ?? '0')
                .toString(); // Asegura que sea un string
            _altura = (userData['altura'] ?? '0')
                .toString(); // Asegura que sea un string
            _genero = userData['genero'] ?? 'No disponible';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Error al obtener datos del usuario: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/ajustes');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                                'assets/images/avatar_placeholder.png'), // Imagen de perfil
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_nombre $_apellido',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text('Usuario desde $_fechaRegistro',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              // Navegar a EditarPerfilScreen y esperar por el resultado
                              final result = await Navigator.pushNamed(
                                  context, '/editarPerfil');

                              if (result == true) {
                                // Si se devuelve `true`, volvemos a cargar los datos del usuario
                                _fetchUserData();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('INFORMACIÓN',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text('ID: $_id'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text('Edad: $_edad'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text('Peso: $_peso kg'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.height, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text('Altura: $_altura m'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text('Género: $_genero'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('EVALUACIÓN',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.person,
                                  color: Colors.grey,
                                  size: 24), // Ícono de persona
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Icon(Icons.favorite,
                                    color: Colors.red,
                                    size: 12), // Ícono de corazón
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const Text('Hábitos actuales'),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  '/evaluacion'); // Navegar a Evaluación
                            },
                            child: const Text('Evaluar'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety,
                              color: Colors.grey),
                          const SizedBox(width: 10),
                          const Text('Estado de salud'),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context,
                                  '/historial_evaluacion'); // Navegar a Historial de Evaluación
                            },
                            child: const Text('Historial'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('OBJETIVOS',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Text('Perder peso / mejorar dieta'),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/objetivos'); // Navegar a Objetivos
                            },
                            child: const Text('Establecer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
