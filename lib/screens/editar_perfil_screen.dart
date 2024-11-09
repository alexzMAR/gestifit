// ignore_for_file: use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditarPerfilScreen extends StatefulWidget {
  final String firebaseUid;

  const EditarPerfilScreen({Key? key, required this.firebaseUid})
      : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _apellido = '';
  String _edad = '';
  String _genero = '';
  String _peso = '';
  String _altura = '';
  File? _fotoPerfil;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _fotoPerfil = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Preparar datos para la actualización
    Map<String, dynamic> requestData = {};

    if (_nombre.isNotEmpty) requestData['nombre'] = _nombre;
    if (_apellido.isNotEmpty) requestData['apellido'] = _apellido;
    if (_edad.isNotEmpty) requestData['edad'] = _edad;
    if (_genero.isNotEmpty) requestData['genero'] = _genero;
    if (_peso.isNotEmpty) requestData['peso'] = _peso;
    if (_altura.isNotEmpty) requestData['altura'] = _altura;

    // Si se seleccionó una foto de perfil, agregarla
    if (_fotoPerfil != null) {
      requestData['foto_perfil'] = _fotoPerfil!.path;
    }

    try {
      // Realizar la solicitud PATCH solo si hay datos a actualizar
      if (requestData.isNotEmpty) {
        final response = await http.patch(
          Uri.parse('http://10.0.2.2:8000/api/usuario/${widget.firebaseUid}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          // Mostrar mensaje de éxito
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Éxito'),
                content: const Text('Actualización exitosa'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      Navigator.pop(context,
                          true); // Volver a la pantalla anterior con valor `true` indicando éxito
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Error al actualizar: ${response.body}');
        }
      } else {
        // Si no hay datos para actualizar, mostrar un mensaje o manejar el caso
        print('No hay datos para actualizar.');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _fotoPerfil != null
                      ? FileImage(_fotoPerfil!)
                      : const AssetImage('assets/avatar_placeholder.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => _nombre = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                onChanged: (value) => _apellido = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
                onChanged: (value) => _edad = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                onChanged: (value) => _peso = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
                onChanged: (value) => _altura = value,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Género'),
                value: _genero.isEmpty ? null : _genero,
                items: ['Masculino', 'Femenino', 'Otro']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _genero = value ?? '');
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Grabar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
