// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestifit/widget/custom_bottom_navigation_bar.dart';
import 'package:gestifit/screens/perfil_screen.dart';
import 'package:gestifit/screens/dieta_screen.dart';
import 'package:gestifit/screens/ejercicio_screen.dart';
import 'package:gestifit/screens/social_screen.dart';

class MonitoreoScreen extends StatefulWidget {
  const MonitoreoScreen({super.key});

  @override
  _MonitoreoScreenState createState() => _MonitoreoScreenState();
}

class _MonitoreoScreenState extends State<MonitoreoScreen> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const PerfilScreen(),
    const DietaScreen(),
    const MonitoreoPage(),
    const EjercicioScreen(),
    const SocialScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class MonitoreoPage extends StatefulWidget {
  const MonitoreoPage({super.key});

  @override
  _MonitoreoPageState createState() => _MonitoreoPageState();
}

class _MonitoreoPageState extends State<MonitoreoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String advice = "Cargando consejo...";
  String imcValue = "Cargando IMC...";
  String ritmoCardiacoValue = "Cargando ritmo...";
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHealthData(); // Cargar datos al inicio
  }

  // Método para obtener los datos de IMC, Ritmo Cardíaco y Consejos
  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          advice = 'Por favor, inicia sesión para continuar.';
          _isLoading = false;
        });
        return;
      }
      String uid = currentUser.uid;

      // Obtener datos de IMC
      final imcResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/historialIMC/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      // Obtener datos de ritmo cardíaco
      final ritmoResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/historialRitmoCardiaco/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      // Obtener evaluaciones
      final evaluacionesResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/evaluaciones/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (imcResponse.statusCode == 200) {
        final imcData = jsonDecode(imcResponse.body);
        imcValue =
            imcData['historialIMC']['IMC']?.toString() ?? 'No disponible';
      } else {
        imcValue = 'No disponible';
        errorMessage = 'Error al obtener IMC: ${imcResponse.statusCode}';
      }

      if (ritmoResponse.statusCode == 200) {
        final ritmoData = jsonDecode(ritmoResponse.body);
        ritmoCardiacoValue =
            ritmoData['historialRitmoCardiaco']['RitmoCardiaco']?.toString() ??
                'No disponible';
      } else {
        ritmoCardiacoValue = 'No disponible';
        errorMessage = 'Error al obtener ritmo: ${ritmoResponse.statusCode}';
      }

      if (evaluacionesResponse.statusCode == 200) {
        final evaluacionesData = jsonDecode(evaluacionesResponse.body);
        advice = evaluacionesData['evaluaciones']['consejo'] ?? 'No disponible';
      } else {
        advice = 'No disponible';
        errorMessage =
            'Error al obtener consejos: ${evaluacionesResponse.statusCode}';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        advice = 'Error al cargar los datos.';
        errorMessage = 'Excepción: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Salud'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progreso de Salud',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildHealthCard(
                'Salud Cardíaca',
                ritmoCardiacoValue,
                '',
                'assets/images/corazon_m.png',
                () async {
                  // Navegar a la pantalla de medición de ritmo cardíaco
                  await Navigator.pushNamed(context, '/medicion_ritmo');
                  // Actualizar los datos después de regresar
                  _fetchHealthData();
                },
              ),
              const SizedBox(height: 20),
              _buildHealthCard(
                'IMC',
                imcValue,
                '',
                'assets/images/imc_m.png',
                () async {
                  // Navegar a la pantalla de medición IMC
                  await Navigator.pushNamed(context, '/medicion_imc');
                  // Actualizar los datos después de regresar
                  _fetchHealthData();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Consejos Personalizados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(advice),
                            if (errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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

  Widget _buildHealthCard(String title, String value, String subValue,
      String imagePath, VoidCallback onPressed) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(imagePath, width: 40),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(subValue),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Medir'),
            ),
          ],
        ),
      ),
    );
  }
}
