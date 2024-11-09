// ignore_for_file: library_private_types_in_public_api, avoid_print, unused_field, use_build_context_synchronously, unnecessary_const, unused_element, prefer_const_declarations, unnecessary_to_list_in_spreads, prefer_final_fields, use_super_parameters

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Tu clave API de Google Cloud
const String apiKey = 'AIzaSyDCET053JI9U1mcBRNwp3p1jAQUfgGnwWY';

Future<String> _translateText(String text) async {
  final String url =
      'https://translation.googleapis.com/language/translate/v2?key=$apiKey';

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'q': text,
      'target': 'es', // Cambia esto si necesitas otro idioma
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['translations'][0]['translatedText'];
  } else {
    throw Exception('Error al traducir el texto: ${response.body}');
  }
}

class DietaScreen extends StatefulWidget {
  const DietaScreen({super.key});

  @override
  _DietaScreenState createState() => _DietaScreenState();
}

class _DietaScreenState extends State<DietaScreen> {
  double _proteinasConsumidas = 0;
  double _carbohidratosConsumidos = 0;
  double _grasasConsumidas = 0;
  double _caloriasConsumidas = 0;

  final double _objetivoProteinas = 120;
  final double _objetivoCarbohidratos = 150;
  final double _objetivoGrasas = 75;
  final double _objetivoCalorias = 2000;

  List<dynamic> _recetasRecomendadas = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _fetchRecetas();
  }

  Future<void> _fetchRecetas() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/random?number=5&apiKey=78d95c6fef0b48b4913816579636cc33&language=es'));
      if (response.statusCode == 200) {
        final List<dynamic> recetas = json.decode(response.body)['recipes'];
        List<dynamic> traducciones = [];

        // Traducir títulos de recetas
        for (var receta in recetas) {
          String traducido = await _translateText(receta['title']);
          receta['title'] = traducido; // Asigna el título traducido
          traducciones.add(receta); // Guarda la receta traducida
        }

        setState(() {
          _recetasRecomendadas =
              traducciones; // Actualiza el estado con las traducciones
        });
      } else {
        throw Exception('Error al cargar las recetas');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchRecetas(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?query=$query&number=5&apiKey=78d95c6fef0b48b4913816579636cc33&language=es'));
      if (response.statusCode == 200) {
        final List<dynamic> recetas = json.decode(response.body)['results'];
        List<dynamic> traducciones = [];

        // Traducir títulos de recetas
        for (var receta in recetas) {
          String traducido = await _translateText(receta['title']);
          receta['title'] = traducido; // Asigna el título traducido
          traducciones.add(receta); // Guarda la receta traducida
        }

        setState(() {
          _recetasRecomendadas =
              traducciones; // Actualiza el estado con las traducciones
        });
      } else {
        throw Exception('Error al buscar recetas');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showRecipeDetails(int recipeId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=78d95c6fef0b48b4913816579636cc33&language=es'));
      if (response.statusCode == 200) {
        final recipeDetails = json.decode(response.body);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeDetails)));
      } else {
        throw Exception('Error al cargar los detalles de la receta');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dieta'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? result = await showSearch(
                context: context,
                delegate: RecipeSearchDelegate(onSearch: _searchRecetas),
              );
              if (result != null) {
                _busqueda = result;
                _searchRecetas(result);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Calendario de selección de día
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  DateTime now = DateTime.now();
                  DateTime day = now.add(Duration(days: index - 3));
                  bool isToday = DateFormat('yyyy-MM-dd').format(day) ==
                      DateFormat('yyyy-MM-dd').format(now);
                  return Column(
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal),
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isToday ? Colors.blue : Colors.grey,
                        child: Text(
                          ['L', 'M', 'X', 'J', 'V', 'S', 'D'][index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const Divider(),

            // Gráfico de macros
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Consumo de Hoy',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_caloriasConsumidas.toStringAsFixed(0)}/$_objetivoCalorias kcal',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildMacroProgress(
                'Proteínas', _proteinasConsumidas, _objetivoProteinas),
            _buildMacroProgress('Carbohidratos', _carbohidratosConsumidos,
                _objetivoCarbohidratos),
            _buildMacroProgress('Grasas', _grasasConsumidas, _objetivoGrasas),
            _buildMacroProgress(
                'Calorías', _caloriasConsumidas, _objetivoCalorias),
            const Divider(),

            // Cuadro de alimentación
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Alimentación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildMealTile(context, 'Desayuno'),
            _buildMealTile(context, 'Almuerzo'),
            _buildMealTile(context, 'Cena'),
            _buildMealTile(context, 'Snacks'),

            const Divider(),

            // Recetas recomendadas
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recetas recomendadas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recetasRecomendadas.length,
                itemBuilder: (context, index) {
                  final receta = _recetasRecomendadas[index];
                  return GestureDetector(
                    onTap: () => _showRecipeDetails(receta['id']),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          image: DecorationImage(
                            image: NetworkImage(receta['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.black.withOpacity(0.5),
                            child: Text(
                              receta['title'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Opción para buscar más recetas
            TextButton(
              onPressed: () {
                _fetchRecetas();
              },
              child: const Text('Buscar más recetas'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir el progreso de cada macro
  Widget _buildMacroProgress(String macro, double consumido, double objetivo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(macro, style: const TextStyle(fontSize: 16)),
              Text('${consumido.toStringAsFixed(0)}/$objetivo g'),
            ],
          ),
          LinearProgressIndicator(
              value: objetivo > 0 ? consumido / objetivo : 0),
        ],
      ),
    );
  }

  // Construir cada sección de comida (Desayuno, Almuerzo, Cena, Snacks)
  Widget _buildMealTile(BuildContext context, String mealName) {
    return ListTile(
      leading: const Icon(Icons.fastfood),
      title: Text(mealName),
      trailing: const Icon(Icons.add),
      onTap: () {
        _showAddFoodOptions(context);
      },
    );
  }

  // Mostrar opciones para añadir alimento
  void _showAddFoodOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Escanear alimentos'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/escanearAlimentos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear código'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/escanearCodigo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Añadir manualmente'),
              onTap: () async {
                Navigator.of(context).pop();
                final result =
                    await Navigator.of(context).pushNamed('/ingresarManual');

                // Actualizar los valores del gráfico de macros
                if (result != null && result is Map<String, double>) {
                  setState(() {
                    _proteinasConsumidas += result['proteinas'] ?? 0;
                    _carbohidratosConsumidos += result['carbohidratos'] ?? 0;
                    _grasasConsumidas += result['grasas'] ?? 0;
                    _caloriasConsumidas += result['calorias'] ?? 0;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// Pantalla de Detalle de Receta
class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final String? userId; // Marcar userId como opcional

  const RecipeDetailScreen(this.recipe, {this.userId, Key? key})
      : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? translatedRecipe;

  @override
  void initState() {
    super.initState();
    _translateRecipe();
  }

  Future<void> _translateRecipe() async {
    Map<String, dynamic> recipeCopy = Map.from(widget.recipe);

    // Traducir ingredientes
    if (recipeCopy['extendedIngredients'] != null) {
      for (var ingredient in recipeCopy['extendedIngredients']) {
        ingredient['name'] = await _translateText(ingredient['name']);
      }
    }

    // Traducir instrucciones
    if (recipeCopy['instructions'] != null) {
      recipeCopy['instructions'] =
          await _translateText(recipeCopy['instructions']);
    }

    setState(() {
      translatedRecipe = recipeCopy;
    });
  }

  Future<void> _saveRecipe(BuildContext context) async {
    final recipeId = widget.recipe['id'];

    if (recipeId != null &&
        widget.userId != null &&
        widget.userId!.isNotEmpty) {
      final url = Uri.parse('http://10.0.2.2:8000/api/dieta');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: '{"userId": "${widget.userId}", "recipeId": "$recipeId"}',
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receta guardada exitosamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar la receta')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red al guardar la receta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe['title'] ?? 'Detalle de la Receta',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent.shade700,
      ),
      body: translatedRecipe == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.recipe['image'] ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            height: 200,
                            width: double.infinity,
                            child: const Center(
                              child: Text(
                                'Imagen no disponible',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ingredientes
                    const Text(
                      'Ingredientes:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 8),
                    translatedRecipe!['extendedIngredients'] != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: translatedRecipe!['extendedIngredients']
                                .map<Widget>((ingredient) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text(
                            'No hay ingredientes disponibles.',
                            style: TextStyle(color: Colors.red),
                          ),

                    const SizedBox(height: 20),

                    // Instrucciones
                    const Text(
                      'Instrucciones:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      translatedRecipe!['instructions'] ??
                          'No hay instrucciones disponibles.',
                      style: const TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 20),

                    // Valores nutricionales
                    const Text(
                      'Valores nutricionales:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 8),
                    if (widget.recipe['nutrition'] != null &&
                        widget.recipe['nutrition']['nutrients'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.recipe['nutrition']['nutrients']
                            .map<Widget>((nutrient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '${nutrient['name']}: ${nutrient['amount']} ${nutrient['unit']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Text(
                        'No hay información nutricional disponible.',
                        style: TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 30),

                    // Botón de Guardar
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _saveRecipe(context),
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar receta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Delegado de búsqueda de recetas
class RecipeSearchDelegate extends SearchDelegate<String> {
  final Future<void> Function(String) onSearch;

  RecipeSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return Container(); // No hay que mostrar nada aquí.
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListTile(
      title: Text('Buscar recetas: $query'),
    );
  }
}
