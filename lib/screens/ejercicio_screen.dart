// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads, use_super_parameters

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EjercicioScreen extends StatefulWidget {
  const EjercicioScreen({super.key});

  @override
  _EjercicioScreenState createState() => _EjercicioScreenState();
}

class _EjercicioScreenState extends State<EjercicioScreen> {
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _completedExercises = 0;
  int _recordDays = 0;
  List<bool> _daysCompleted = List.filled(7, false);
  int _totalMinutes = 0;
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _loadProgress();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(
        Uri.parse('https://exercisedb.p.rapidapi.com/exercises'),
        headers: {
          'X-RapidAPI-Key':
              '9de2c55a73msh6b305f3f8c10024p198f95jsn0487bf415e2e', // Reemplaza con tu API key
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _exercises = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load exercises: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProgress(String exercise, int minutes, int calories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedExercises = prefs.getStringList('saved_exercises') ?? [];
    savedExercises.add(exercise);
    await prefs.setStringList('saved_exercises', savedExercises);

    _totalMinutes += minutes;
    _totalCalories += calories;
    await prefs.setInt('total_minutes', _totalMinutes);
    await prefs.setInt('total_calories', _totalCalories);
  }

  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _completedExercises = prefs.getInt('completed_exercises') ?? 0;
    _recordDays = prefs.getInt('record_days') ?? 0;
    _daysCompleted = List<bool>.from(
        prefs.getStringList('days_completed')?.map((e) => e == 'true') ??
            List.filled(7, false));
    _totalMinutes = prefs.getInt('total_minutes') ?? 0;
    _totalCalories = prefs.getInt('total_calories') ?? 0;
    setState(() {});
  }

  Future<void> _updateProgress(int dayIndex) async {
    if (!_daysCompleted[dayIndex]) {
      setState(() {
        _daysCompleted[dayIndex] = true;
        _completedExercises++;
      });

      if (_completedExercises > _recordDays) {
        _recordDays = _completedExercises;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completed_exercises', _completedExercises);
      await prefs.setInt('record_days', _recordDays);
      await prefs.setStringList(
          'days_completed', _daysCompleted.map((e) => e.toString()).toList());
    }
  }

  void _viewExerciseDetail(dynamic exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Objetivo semanal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeeklyGoal('Ejercicios', '$_completedExercises'),
                  _buildWeeklyGoal('Minutos', '$_totalMinutes'),
                  _buildWeeklyGoal('Kcal', '$_totalCalories'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Record de Días: $_recordDays',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    DateTime now = DateTime.now();
                    DateTime day = now.add(Duration(days: index - 3));
                    bool isToday = DateFormat('yyyy-MM-dd').format(day) ==
                        DateFormat('yyyy-MM-dd').format(now);
                    return GestureDetector(
                      onTap: () => _updateProgress(index),
                      child: Column(
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                isToday ? Colors.blue : Colors.grey,
                            child: Text(
                              ['L', 'M', 'X', 'J', 'V', 'S', 'D'][index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Ejercicios Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                )
              else
                ..._exercises.map((exercise) {
                  return _buildExerciseCard(
                    context,
                    exercise,
                    () {
                      int minutes =
                          exercise['duration'] ?? 10; // Valor por defecto
                      int calories =
                          exercise['calories'] ?? 50; // Valor por defecto
                      _saveProgress(exercise['name'], minutes, calories);
                      _viewExerciseDetail(exercise);
                    },
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyGoal(String label, String value) {
    return Column(
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontSize: 24)),
      ],
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, dynamic exercise, VoidCallback onPressed) {
    return Card(
      child: ListTile(
        leading: exercise['gifUrl'] != null
            ? Image.network(exercise['gifUrl'])
            : null,
        title: Text(exercise['name']),
        subtitle: Text(
          'Músculos: ${exercise['muscle'] ?? 'No disponible'}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check),
          onPressed: onPressed,
        ),
        onTap: onPressed,
      ),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  final dynamic exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise['gifUrl'] != null) Image.network(exercise['gifUrl']),
            const SizedBox(height: 10),
            Text(
              exercise['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Descripción: ${exercise['description'] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Músculos trabajados: ${exercise['muscle'] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Duración: ${exercise['duration'] ?? '10'} minutos',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Calorías: ${exercise['calories'] ?? '50'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Equipo necesario: ${exercise['equipment'] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Consejos: ${exercise['tips'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
