import 'dart:convert';
import 'package:http/http.dart' as http;

class Recipe {
  String title;
  final String imageUrl;

  Recipe({required this.title, required this.imageUrl});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      imageUrl: json['image'],
    );
  }
}

// Función para traducir texto (ejemplo simple)
Future<String> translateText(String text, String targetLanguage) async {
  // Implementar la lógica de traducción aquí.
  // Este es solo un ejemplo y debería ser reemplazado con una llamada a una API real.
  return text; // Retornar el texto sin cambios (por simplicidad)
}

Future<List<Recipe>> fetchRecipes() async {
  final response = await http.get(Uri.parse(
      'https://api.spoonacular.com/recipes/random?number=3&apiKey=78d95c6fef0b48b4913816579636cc33&language=es'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> recipesJson = data['recipes'];

    List<Recipe> recipes =
        recipesJson.map((json) => Recipe.fromJson(json)).toList();

    // Traducir los títulos de las recetas
    for (var recipe in recipes) {
      recipe.title = await translateText(recipe.title, 'es');
    }

    return recipes;
  } else {
    throw Exception('Failed to load recipes');
  }
}
