// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EvaluacionScreen extends StatefulWidget {
  const EvaluacionScreen({super.key});

  @override
  _EvaluacionScreenState createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  double _horasSueno = 7.0;
  double _comidasDiarias = 3.0;
  double _ejercicio = 3.0;
  double _frecuenciaTabaco = 0.0;
  double _frecuenciaAlcohol = 0.0;
  double _nivelEstres = 5.0;
  String _resultado = '';
  String _consejo = '';

  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/modelo/modelo_ev.tflite');
      print('Modelo cargado exitosamente');
    } catch (e) {
      print('Error al cargar el modelo: $e');
    }
  }

  Future<void> _calcularEvaluacion() async {
    var input = [
      [
        _horasSueno / 12,
        _comidasDiarias / 5,
        _ejercicio / 7,
        _frecuenciaTabaco / 5,
        _frecuenciaAlcohol / 5,
        _nivelEstres / 10
      ]
    ];
    var output = List.filled(1, 0.0).reshape([1, 1]);

    try {
      _interpreter.run(input, output);

      double puntajeSalud = output[0][0];
      setState(() {
        _resultado = puntajeSalud >= 0.7
            ? 'Excelente'
            : puntajeSalud >= 0.4
                ? 'Bueno'
                : 'Mejorable';
        _consejo = _resultado == 'Excelente'
            ? 'Continúa con tus buenos hábitos para mantener un estilo de vida saludable.'
            : _resultado == 'Bueno'
                ? 'Podrías mejorar en algunos aspectos, como reducir el estrés o el consumo de alcohol.'
                : 'Mejora tus hábitos de sueño, ejercicio y alimentación para alcanzar una mejor salud.';
      });

      await _guardarEvaluacion(_resultado, _consejo);
    } catch (e) {
      print('Error en la evaluación: $e');
    }
  }

  Future<void> _guardarEvaluacion(String resultado, String consejo) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      final url = Uri.parse('http://10.0.2.2:8000/api/evaluaciones');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "firebase_uid": uid,
          "fecharegistro": DateTime.now().toIso8601String(),
          "resultado": resultado,
          "consejo": consejo,
          "horasSueno": _horasSueno.toInt(),
          "comidasDiarias": _comidasDiarias.toInt(),
          "ejercicio": _ejercicio.toInt(),
          "frecuenciaTabaco": _frecuenciaTabaco.toInt(),
          "frecuenciaAlcohol": _frecuenciaAlcohol.toInt(),
          "nivelEstres": _nivelEstres.toInt(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluación guardada exitosamente')),
        );
      } else {
        print('Error al guardar en la BD: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la evaluación')),
        );
      }
    } else {
      print('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Salud'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Evaluación de Salud',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text('¿Cuántas horas duermes cada noche?',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _horasSueno,
              min: 0,
              max: 12,
              divisions: 12,
              label: _horasSueno.toString(),
              onChanged: (value) {
                setState(() {
                  _horasSueno = value;
                });
              },
            ),
            const Text('¿Cuántas comidas completas consumes al día?',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _comidasDiarias,
              min: 0,
              max: 5,
              divisions: 5,
              label: _comidasDiarias.toString(),
              onChanged: (value) {
                setState(() {
                  _comidasDiarias = value;
                });
              },
            ),
            const Text('¿Cuántas veces a la semana haces ejercicio?',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _ejercicio,
              min: 0,
              max: 7,
              divisions: 7,
              label: _ejercicio.toString(),
              onChanged: (value) {
                setState(() {
                  _ejercicio = value;
                });
              },
            ),
            const Text('¿Con qué frecuencia consumes tabaco? (0 a 5)',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _frecuenciaTabaco,
              min: 0,
              max: 5,
              divisions: 5,
              label: _frecuenciaTabaco.toString(),
              onChanged: (value) {
                setState(() {
                  _frecuenciaTabaco = value;
                });
              },
            ),
            const Text('¿Con qué frecuencia consumes alcohol? (0 a 5)',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _frecuenciaAlcohol,
              min: 0,
              max: 5,
              divisions: 5,
              label: _frecuenciaAlcohol.toString(),
              onChanged: (value) {
                setState(() {
                  _frecuenciaAlcohol = value;
                });
              },
            ),
            const Text('¿Cuál es tu nivel de estrés (1 a 10)?',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _nivelEstres,
              min: 1,
              max: 10,
              divisions: 10,
              label: _nivelEstres.toString(),
              onChanged: (value) {
                setState(() {
                  _nivelEstres = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _calcularEvaluacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Calcular Resultado'),
            ),
            const SizedBox(height: 20),
            if (_resultado.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Resultado: $_resultado',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Consejo: $_consejo',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
