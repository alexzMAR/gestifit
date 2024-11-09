// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EscanearAlimentosScreen extends StatefulWidget {
  const EscanearAlimentosScreen({super.key});

  @override
  _EscanearAlimentosScreenState createState() =>
      _EscanearAlimentosScreenState();
}

class _EscanearAlimentosScreenState extends State<EscanearAlimentosScreen> {
  String? nombreProducto;
  String? ingredientes;
  String? valoresNutricionales;
  String? etiquetas;
  String? marcas;
  String? origen;

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer textRecognizer =
      GoogleMlKit.vision.textRecognizer(); // Inicializa el detector de texto

  @override
  void initState() {
    super.initState();
    _escanearAlimento();
  }

  Future<void> _escanearAlimento() async {
    // Seleccionar imagen de la galería
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Procesar la imagen para reconocimiento de texto
      final inputImage = InputImage.fromFilePath(image.path);
      final recognisedText = await textRecognizer.processImage(inputImage);

      String textoEscaneado = recognisedText.text;
      String productoEscaneado = textoEscaneado.isNotEmpty
          ? textoEscaneado
          : "arroz con pollo"; // Valor por defecto

      // Realizar la solicitud a la API de Spoonacular
      await _buscarInformacionNutricional(productoEscaneado);
    }
  }

  Future<void> _buscarInformacionNutricional(String productoEscaneado) async {
    final response = await http.get(Uri.parse(
      'https://api.spoonacular.com/food/products/search?query=$productoEscaneado&apiKey=AIzaSyDCET053JI9U1mcBRNwp3p1jAQUfgGnwWY',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['products'] != null && data['products'].isNotEmpty) {
        final producto = data['products'][0];

        setState(() {
          nombreProducto = producto['title'];
          ingredientes = producto['ingredients']?.join(', ') ?? 'No disponible';
          valoresNutricionales =
              "Calorías: ${producto['nutrition']['calories']}, Grasas: ${producto['nutrition']['fat']}, Carbohidratos: ${producto['nutrition']['carbohydrates']}, Proteínas: ${producto['nutrition']['protein']}";
          etiquetas = producto['tags']?.join(', ') ?? 'No disponible';
          marcas = producto['brand'] ?? 'No disponible';
          origen = producto['origin'] ?? 'No disponible';
        });
      } else {
        setState(() {
          nombreProducto = "Producto no encontrado";
        });
      }
    } else {
      throw Exception('Error al obtener datos de la API');
    }
  }

  @override
  void dispose() {
    textRecognizer.close(); // Asegúrate de cerrar el detector
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear tu Comida'),
      ),
      body: Center(
        child: nombreProducto == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nombre del producto: $nombreProducto',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Ingredientes: $ingredientes'),
                  const SizedBox(height: 10),
                  Text('Valores nutricionales: $valoresNutricionales'),
                  const SizedBox(height: 10),
                  Text('Etiquetas: $etiquetas'),
                  const SizedBox(height: 10),
                  Text('Marcas: $marcas'),
                  const SizedBox(height: 10),
                  Text('Origen: $origen'),
                ],
              ),
      ),
    );
  }
}
