// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestifit/screens/monitoreo_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _email = '';
  String _password = '';
  String _nombre = '';
  String _apellido = '';
  String _edad = '';
  String _height = '';
  String _weight = '';
  String _gender = '';
  String _errorMessage = '';

  Future<void> _register() async {
    try {
      // Crea el usuario con Firebase
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Llama a la función para crear el usuario en la API
        await createUserViaApi(user.uid); // Pasa el UID a la API

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MonitoreoScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Botón de retroceso
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
              onChanged: (value) => setState(() => _nombre = value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Apellido'),
              onChanged: (value) => setState(() => _apellido = value),
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(labelText: 'Correo Electrónico'),
              onChanged: (value) => setState(() => _email = value),
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              onChanged: (value) => setState(() => _password = value),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Edad'),
              onChanged: (value) => setState(() => _edad = value),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Altura (cm)'),
              onChanged: (value) => setState(() => _height = value),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              onChanged: (value) => setState(() => _weight = value),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Género'),
              value: _gender.isEmpty ? null : _gender,
              items: ['Masculino', 'Femenino', 'Otro']
                  .map((label) => DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _gender = value ?? '');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Crear Cuenta'),
            ),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  // Método para crear el usuario a través de la API
  Future<void> createUserViaApi(String firebaseUid) async {
    String apiUrl = 'http://10.0.2.2:8000/api/usuario'; // URL de la API

    Map<String, dynamic> userData = {
      'nombre': _nombre,
      'apellido': _apellido,
      'edad': int.tryParse(_edad) ?? 0,
      'altura': double.tryParse(_height) ?? 0.0,
      'peso': double.tryParse(_weight) ?? 0.0,
      'genero': _gender,
      'firebase_uid': firebaseUid, // Agrega el UID de Firebase
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 201) {
        throw Exception('Error al crear usuario en la API: ${response.body}');
      }

      print("Usuario creado con éxito en la API.");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print("Error al crear usuario en la API: $e");
    }
  }
}
