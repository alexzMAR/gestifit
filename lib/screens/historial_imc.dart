// ignore_for_file: library_private_types_in_public_api, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistorialImcScreen extends StatefulWidget {
  const HistorialImcScreen({super.key});

  @override
  _HistorialImcScreenState createState() => _HistorialImcScreenState();
}

class _HistorialImcScreenState extends State<HistorialImcScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FlSpot> _imcData = [];
  String _errorMessage = '';
  bool _isLoading = true;

  double? _lastIMC;

  @override
  void initState() {
    super.initState();
    _fetchHistorialImc();
  }

  Future<void> _fetchHistorialImc() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/historialIMC/all/$uid'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body)['historialIMC'];
          _imcData = data
              .map((item) {
                String? fecha = item['FechaRegistro'] as String?;
                String? imcValue = item['IMC'] as String?;
                if (fecha != null && imcValue != null) {
                  double imc = double.tryParse(imcValue) ?? 0.0;
                  _lastIMC = imc;
                  return FlSpot(
                    DateTime.parse(fecha).millisecondsSinceEpoch.toDouble(),
                    imc,
                  );
                }
                return null;
              })
              .whereType<FlSpot>()
              .toList();
          _imcData.sort((a, b) =>
              b.x.compareTo(a.x)); // Ordenar de más reciente a más antiguo
        } else {
          setState(() {
            _errorMessage =
                'Error al obtener el historial: ${response.statusCode}';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(double timestamp) {
    return DateFormat('dd/MM')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
  }

  String _getAdvice(double? imc) {
    if (imc == null) return 'No hay información suficiente para dar consejos.';
    if (imc < 16.0) {
      return 'Considere aumentar su ingesta calórica y consultar a un nutricionista.';
    }
    if (imc < 17.0) {
      return 'Es importante mejorar su dieta y seguir un plan de alimentación.';
    }
    if (imc < 18.5) return 'Asegúrese de tener una dieta balanceada.';
    if (imc < 25.0) return '¡Excelente! Mantenga su estilo de vida saludable.';
    if (imc < 30.0) return 'Intente incorporar más ejercicio a su rutina.';
    if (imc < 35.0) {
      return 'Considere una dieta más equilibrada y consulte a un profesional.';
    }
    if (imc < 40.0) {
      return 'Es recomendable seguir un programa de pérdida de peso con un profesional.';
    }
    return 'Consulta a un médico para un plan de salud personalizado.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de IMC'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Progreso de IMC',
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
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _imcData,
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
                        'Detalles de IMC',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _imcData.length,
                          itemBuilder: (context, index) {
                            final evaluacion = _imcData[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Fecha: ${_formatDate(evaluacion.x)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    'IMC: ${evaluacion.y.toStringAsFixed(1)}'),
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
