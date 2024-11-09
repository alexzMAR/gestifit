// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialEvaluacionScreen extends StatefulWidget {
  const HistorialEvaluacionScreen({super.key});

  @override
  _HistorialEvaluacionScreenState createState() =>
      _HistorialEvaluacionScreenState();
}

class _HistorialEvaluacionScreenState extends State<HistorialEvaluacionScreen> {
  List<Map<String, dynamic>> _evaluaciones = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final url = Uri.parse(
            'http://10.0.2.2:8000/api/evaluaciones/all/${currentUser.uid}');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _evaluaciones =
                List<Map<String, dynamic>>.from(data['evaluaciones'])
                    .reversed
                    .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Error al obtener el historial: ${response.statusCode}';
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

  List<FlSpot> _generateDataPoints() {
    List<FlSpot> dataPoints = [];
    for (var i = 0; i < _evaluaciones.length; i++) {
      final puntajeSalud = _calculateHealthScore(_evaluaciones[i]);
      dataPoints.add(FlSpot(i.toDouble(), puntajeSalud));
    }
    return dataPoints;
  }

  double _calculateHealthScore(Map<String, dynamic> evaluacion) {
    return evaluacion['horasSueno'] +
        evaluacion['comidasDiarias'] +
        evaluacion['ejercicio'] -
        evaluacion['frecuenciaTabaco'] -
        evaluacion['frecuenciaAlcohol'] -
        (evaluacion['nivelEstres'] / 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Evaluación'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Progreso de Evaluación de Salud',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateDataPoints(),
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(show: true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Detalles de Evaluaciones',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _evaluaciones.length,
                          itemBuilder: (context, index) {
                            final evaluacion = _evaluaciones[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Fecha: ${evaluacion['fecharegistro']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Horas de Sueño: ${evaluacion['horasSueno']}'),
                                    Text(
                                        'Comidas Diarias: ${evaluacion['comidasDiarias']}'),
                                    Text(
                                        'Ejercicio Semanal: ${evaluacion['ejercicio']}'),
                                    Text(
                                        'Frecuencia de Tabaco: ${evaluacion['frecuenciaTabaco']}'),
                                    Text(
                                        'Frecuencia de Alcohol: ${evaluacion['frecuenciaAlcohol']}'),
                                    Text(
                                        'Nivel de Estrés: ${evaluacion['nivelEstres']}'),
                                    Text(
                                        'Resultado: ${evaluacion['resultado']}'),
                                    Text('Consejo: ${evaluacion['consejo']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
