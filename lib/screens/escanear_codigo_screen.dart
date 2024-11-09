// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EscanearCodigoScreen extends StatelessWidget {
  const EscanearCodigoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _iniciarEscaneo(context); // Iniciar escaneo al construir la pantalla
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código de Barras'),
      ),
      body: const Center(
        child: Text(
          'Escaneando...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _iniciarEscaneo(BuildContext context) async {
    var result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      final producto = await obtenerInformacionProducto(result.rawContent);
      _mostrarResultado(context, producto);
    } else {
      _mostrarError(context, 'No se escaneó ningún código');
    }
  }

  Future<Map<String, dynamic>?> obtenerInformacionProducto(
      String codigo) async {
    final response = await http.get(Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$codigo.json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['product']; // Retorna la información del producto
    } else {
      throw Exception('Error al obtener información del producto');
    }
  }

  void _mostrarResultado(BuildContext context, Map<String, dynamic>? producto) {
    if (producto == null) {
      _mostrarError(context, 'Producto no encontrado');
      return;
    }

    // Obtener datos del producto
    String nombreProducto = producto['product_name'] ?? 'Producto Desconocido';
    String ingredientes = producto['ingredients_text'] ?? 'No disponible';
    String? calorias =
        producto['nutriments']?['energy-kcal']?.toString() ?? 'No disponible';
    String? grasas =
        producto['nutriments']?['fat']?.toString() ?? 'No disponible';
    String? carbohidratos =
        producto['nutriments']?['carbohydrates']?.toString() ?? 'No disponible';
    String? proteinas =
        producto['nutriments']?['proteins']?.toString() ?? 'No disponible';
    String etiquetas =
        (producto['labels_tags'] != null && producto['labels_tags'].isNotEmpty)
            ? producto['labels_tags'].join(', ')
            : 'No disponible';
    String marcas = producto['brands'] ?? 'No disponible';
    String origen = producto['countries_tags'] != null &&
            producto['countries_tags'].isNotEmpty
        ? producto['countries_tags'].join(', ')
        : 'No disponible';

    // Mostrar el cuadro de diálogo con la información
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(nombreProducto),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ingredientes: $ingredientes'),
                Text('Calorías: $calorias kcal'),
                Text('Grasas: $grasas g'),
                Text('Carbohidratos: $carbohidratos g'),
                Text('Proteínas: $proteinas g'),
                Text('Etiquetas: $etiquetas'),
                Text('Marca: $marcas'),
                Text('Origen: $origen'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Llamar a la función para guardar el producto
                guardarProducto(
                    nombreProducto, calorias, grasas, carbohidratos, proteinas);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> guardarProducto(String nombre, String? calorias, String? grasas,
      String? carbohidratos, String? proteinas) async {
    // Aquí debes implementar la lógica para guardar el producto en otra API
    final url = 'https://tu-api.com/guardar'; // Reemplaza con tu URL
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'calorias': calorias,
        'grasas': grasas,
        'carbohidratos': carbohidratos,
        'proteinas': proteinas,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar el producto');
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}
