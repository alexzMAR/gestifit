// ignore_for_file: library_private_types_in_public_api, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistorialRitmoScreen extends StatefulWidget {
  const HistorialRitmoScreen({super.key});

  @override
  _HistorialRitmoScreenState createState() => _HistorialRitmoScreenState();
}

class _HistorialRitmoScreenState extends State<HistorialRitmoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<FlSpot> _ritmoData = [];
  String _errorMessage = '';
  bool _isLoading = true;

  double? _lastRitmo;

  @override
  void initState() {
    super.initState();
    _fetchHistorialRitmo();
  }

  Future<void> _fetchHistorialRitmo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/historialRitmoCardiaco/all/$uid'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          List<dynamic> data =
              jsonDecode(response.body)['Historial RitmoCardiaco'];
          _ritmoData = data
              .map((item) {
                String? fecha = item['FechaRegistro'] as String?;
                String? ritmoValue = item['RitmoCardiaco'] as String?;
                if (fecha != null && ritmoValue != null) {
                  double ritmo = double.tryParse(ritmoValue) ?? 0.0;
                  _lastRitmo = ritmo;
                  return FlSpot(
                    DateTime.parse(fecha).millisecondsSinceEpoch.toDouble(),
                    ritmo,
                  );
                }
                return null;
              })
              .whereType<FlSpot>()
              .toList();
          _ritmoData.sort((a, b) =>
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

  String _getAdvice(double? ritmo) {
    if (ritmo == null) {
      return 'No hay información suficiente para dar consejos.';
    }
    if (ritmo < 60) return 'Tu ritmo es bajo. Considera consultar a un médico.';
    if (ritmo <= 100) {
      return 'Tu ritmo es normal. Mantén un estilo de vida saludable.';
    }
    return 'Tu ritmo es alto. Considera consultar a un médico.';
  }

  Color _getRitmoColor(double ritmo) {
    if (ritmo < 60) return Colors.blue;
    if (ritmo <= 100) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ritmo Cardíaco'),
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
                        'Progreso de Ritmo Cardíaco',
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
                                spots: _ritmoData,
                                isCurved: true,
                                barWidth: 3,
                                color: Colors.red,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(show: true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Detalles de Ritmo Cardíaco',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _ritmoData.length,
                          itemBuilder: (context, index) {
                            final evaluacion = _ritmoData[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Fecha: ${_formatDate(evaluacion.x)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    'Ritmo: ${evaluacion.y.toStringAsFixed(1)} bpm'),
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
