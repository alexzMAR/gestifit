// ignore_for_file: unnecessary_string_interpolations, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class MedicionImcScreen extends StatefulWidget {
  const MedicionImcScreen({super.key});

  @override
  _MedicionImcScreenState createState() => _MedicionImcScreenState();
}

class _MedicionImcScreenState extends State<MedicionImcScreen> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  bool _isLoading = false;
  String _resultadoImc = '';
  String _categoriaImc = '';
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _calcularImc() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear previous error messages
    });

    final double peso = double.tryParse(_pesoController.text) ?? 0.0;
    final double altura = double.tryParse(_alturaController.text) ?? 0.0;

    // Validación de valores
    if (peso <= 49 || peso > 200) {
      setState(() {
        _errorMessage =
            'Por favor, introduce un peso válido entre 50 y 200 kg.';
        _isLoading = false;
      });
      return;
    }
    if (altura <= 129 || altura > 250) {
      setState(() {
        _errorMessage =
            'Por favor, introduce una altura válida entre 130 y 250 cm.';
        _isLoading = false;
      });
      return;
    }

    final double alturaMetros = altura / 100;
    final double imc = peso / (alturaMetros * alturaMetros);

    // Categoría del IMC
    String categoria;
    if (imc < 16.0) {
      categoria = 'Delgadez muy severa';
    } else if (imc < 17.0) {
      categoria = 'Delgadez severa';
    } else if (imc < 18.5) {
      categoria = 'Peso bajo';
    } else if (imc < 25.0) {
      categoria = 'Normal';
    } else if (imc < 30.0) {
      categoria = 'Sobrepeso';
    } else if (imc < 35.0) {
      categoria = 'Obesidad Clase 1';
    } else if (imc < 40.0) {
      categoria = 'Obesidad Clase 2';
    } else {
      categoria = 'Obesidad Clase 3';
    }

    // Actualizar la interfaz
    setState(() {
      _resultadoImc = imc.toStringAsFixed(1);
      _categoriaImc = categoria;
    });

    // Guardar en la base de datos
    await _guardarImc(imc);
  }

  Future<void> _guardarImc(double imc) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/historialIMC'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fecharegistro': DateTime.now().toIso8601String(),
            'imc': imc.toStringAsFixed(2), // Ensure IMC is in correct format
            'firebase_uid': uid,
          }),
        );

        if (response.statusCode == 201) {
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Error al guardar el IMC: ${response.statusCode} - ${response.body}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
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
        title: const Text('Medición de IMC'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Esta medición es solo para mayores de edad. Si deseas calcular el IMC para un niño, por favor usa la opción correspondiente.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            _buildTextField(_pesoController, 'Peso (Kg)'),
            const SizedBox(height: 10),
            _buildTextField(_alturaController, 'Altura (Cm)'),
            const SizedBox(height: 20),
            _buildResultSection(),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _calcularImc,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Calcular IMC',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            _buildImcInfoTable(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/historial_imc');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Ver Historial de IMC',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medicion_imc_menores');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Calcular IMC para Niños',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildResultSection() {
    if (_resultadoImc.isNotEmpty) {
      return Column(
        children: [
          Text(
            'Tu IMC es $_resultadoImc',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Categoría: $_categoriaImc',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '$_resultadoImc',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_categoriaImc',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildImcInfoTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorías de IMC',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delgadez muy severa',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              Text(
                '< 16.0',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delgadez severa',
                style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16),
              ),
              Text(
                '16.0 - 16.9',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peso bajo',
                style: TextStyle(color: Colors.lightGreen, fontSize: 16),
              ),
              Text(
                '17.0 - 18.4',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Normal',
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
              Text(
                '18.5 - 24.9',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sobrepeso',
                style: TextStyle(color: Colors.yellow, fontSize: 16),
              ),
              Text(
                '25.0 - 29.9',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obesidad clase I',
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
              Text(
                '30.0 - 34.9',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obesidad clase II',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              Text(
                '35.0 - 39.9',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obesidad clase III',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              Text(
                '> 40.0',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
