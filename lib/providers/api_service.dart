import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia esta URL a la URL base de tu API en producción o desarrollo
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Método para obtener los datos de los usuario
  Future<List<dynamic>> fetchUsuario() async {
    final response = await http.get(Uri.parse('$baseUrl/usuario'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuario');
    }
  }

  // Método para crear un nuevo usuario
  Future<void> createUsuario(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear usuario');
    }
  }

  // Método para actualizar un usuario
  Future<void> updateUsuario(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuario/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario');
    }
  }

// Método para actualizar parcialmente un usuario
  Future<void> updateUsuarioPartial(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/usuario/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar usuario parcialmente');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUsuario(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/usuario/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario');
    }
  }
}
