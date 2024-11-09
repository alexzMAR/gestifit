// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class MedicionImcMenoresScreen extends StatefulWidget {
  const MedicionImcMenoresScreen({super.key});

  @override
  _MedicionImcMenoresScreenState createState() =>
      _MedicionImcMenoresScreenState();
}

class _MedicionImcMenoresScreenState extends State<MedicionImcMenoresScreen> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  String _resultadoImc = '';
  String _categoriaImc = '';
  String _errorMessage = '';
  String _percentilMensaje = '';
  String _sexoSeleccionado = 'niño';

  // Ejemplo de percentiles ajustados
  Map<String, Map<int, List<double>>> percentilesIMC = {
    'niño': {
      2: [14.5, 17.5],
      3: [14.5, 17.5],
      4: [14.0, 17.0],
      5: [14.0, 17.0],
      6: [14.0, 17.5],
      7: [14.0, 18.0],
      8: [14.5, 18.5],
      9: [15.0, 19.0],
      10: [15.0, 19.5],
      11: [15.5, 20.0],
      12: [15.5, 20.5],
      13: [16.0, 21.0],
      14: [16.5, 22.0],
      15: [17.0, 22.5],
      16: [17.0, 23.0],
      17: [17.5, 23.5],
      18: [18.0, 24.0],
    },
    'niña': {
      2: [14.0, 17.0],
      3: [14.0, 17.0],
      4: [13.5, 16.5],
      5: [13.5, 16.5],
      6: [14.0, 17.0],
      7: [14.0, 17.5],
      8: [14.5, 18.0],
      9: [15.0, 18.5],
      10: [15.0, 19.0],
      11: [15.5, 19.5],
      12: [16.0, 20.0],
      13: [16.5, 20.5],
      14: [17.0, 21.0],
      15: [17.5, 21.5],
      16: [17.5, 22.0],
      17: [18.0, 22.5],
      18: [18.5, 23.0],
    },
  };

  // Rangos de altura y peso por edad
  Map<int, Map<String, List<double>>> rangos = {
    2: {
      'peso': [10.0, 15.0],
      'altura': [85.0, 95.0]
    },
    3: {
      'peso': [12.0, 18.0],
      'altura': [90.0, 100.0]
    },
    4: {
      'peso': [14.0, 22.0],
      'altura': [95.0, 105.0]
    },
    5: {
      'peso': [16.0, 25.0],
      'altura': [100.0, 110.0]
    },
    6: {
      'peso': [18.0, 30.0],
      'altura': [105.0, 115.0]
    },
    7: {
      'peso': [20.0, 35.0],
      'altura': [110.0, 120.0]
    },
    8: {
      'peso': [22.0, 40.0],
      'altura': [115.0, 125.0]
    },
    9: {
      'peso': [25.0, 45.0],
      'altura': [120.0, 130.0]
    },
    10: {
      'peso': [28.0, 50.0],
      'altura': [125.0, 135.0]
    },
    11: {
      'peso': [30.0, 55.0],
      'altura': [130.0, 140.0]
    },
    12: {
      'peso': [35.0, 60.0],
      'altura': [135.0, 145.0]
    },
    13: {
      'peso': [40.0, 70.0],
      'altura': [140.0, 150.0]
    },
    14: {
      'peso': [45.0, 75.0],
      'altura': [145.0, 155.0]
    },
    15: {
      'peso': [50.0, 80.0],
      'altura': [150.0, 160.0]
    },
    16: {
      'peso': [55.0, 85.0],
      'altura': [155.0, 165.0]
    },
    17: {
      'peso': [60.0, 90.0],
      'altura': [160.0, 170.0]
    },
    18: {
      'peso': [65.0, 95.0],
      'altura': [165.0, 175.0]
    },
  };

  Future<void> _calcularImcMenor() async {
    final double peso = double.tryParse(_pesoController.text) ?? 0.0;
    final double altura = double.tryParse(_alturaController.text) ?? 0.0;
    final int edad = int.tryParse(_edadController.text) ?? 0;

    // Validación de valores
    if (peso <= 2.4 || peso > 100) {
      setState(() {
        _errorMessage = '¡Ingresa un peso entre 2.5 y 100 kg!';
      });
      return;
    }
    if (altura <= 44 || altura > 200) {
      setState(() {
        _errorMessage = '¡Ingresa una altura entre 45 y 200 cm!';
      });
      return;
    }
    if (edad < 2 || edad > 18) {
      setState(() {
        _errorMessage = '¡Ingresa una edad entre 2 y 18 años!';
      });
      return;
    }

    // Validación de rangos según edad
    if (rangos[edad] != null) {
      if (peso < rangos[edad]!['peso']![0] ||
          peso > rangos[edad]!['peso']![1]) {
        setState(() {
          _errorMessage = '¡Peso no válido para un niño de $edad años!';
        });
        return;
      }
      if (altura < rangos[edad]!['altura']![0] ||
          altura > rangos[edad]!['altura']![1]) {
        setState(() {
          _errorMessage = '¡Altura no válida para un niño de $edad años!';
        });
        return;
      }
    } else {
      setState(() {
        _errorMessage = '¡Rangos no disponibles para la edad seleccionada!';
      });
      return;
    }

    final double alturaMetros = altura / 100;
    final double imc = peso / (alturaMetros * alturaMetros);

    // Determinar categoría
    String categoria;
    if (imc < 14.0) {
      categoria = 'Bajo peso';
    } else if (imc < 17.0) {
      categoria = 'Normal';
    } else {
      categoria = 'Sobrepeso';
    }

    // Comparar con percentiles
    List<double> percentiles =
        percentilesIMC[_sexoSeleccionado]?[edad] ?? [0, 0];
    String percentilMensaje;
    if (imc < percentiles[0]) {
      percentilMensaje = 'Por debajo del percentil 5.';
    } else if (imc < percentiles[1]) {
      percentilMensaje = 'En el percentil normal (5-85).';
    } else {
      percentilMensaje = 'Por encima del percentil 85.';
    }

    setState(() {
      _resultadoImc = imc.toStringAsFixed(1);
      _categoriaImc = categoria;
      _percentilMensaje = percentilMensaje;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Calcula tu IMC!'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/niño_imc_baner.jpg'),
            const SizedBox(height: 20),
            _buildTextField(_pesoController, 'Peso (Kg)'),
            const SizedBox(height: 10),
            _buildTextField(_alturaController, 'Altura (Cm)'),
            const SizedBox(height: 10),
            _buildTextField(_edadController, 'Edad (Años)'),
            const SizedBox(height: 10),
            _buildSexoSelector(),
            const SizedBox(height: 20),
            _buildResultSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcularImcMenor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Calcular IMC',
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            const SizedBox(height: 30),
            _buildPercentilesSection(),
            const SizedBox(height: 30),
            _buildHealthTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSexoSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'niño',
              groupValue: _sexoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _sexoSeleccionado = value!;
                });
              },
            ),
            const Text('Niño'),
          ],
        ),
        Row(
          children: [
            Radio<String>(
              value: 'niña',
              groupValue: _sexoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _sexoSeleccionado = value!;
                });
              },
            ),
            const Text('Niña'),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    if (_resultadoImc.isNotEmpty) {
      return Column(
        children: [
          Text(
            'Tu IMC es $_resultadoImc',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Categoría: $_categoriaImc',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black54,
            ),
          ),
          Text(
            _percentilMensaje,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black54,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildHealthTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightGreenAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consejos para una vida saludable:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '🥦 Come frutas y verduras todos los días.',
            style: TextStyle(fontSize: 18),
          ),
          const Text(
            '🏃‍♂️ Haz ejercicio al menos 30 minutos al día.',
            style: TextStyle(fontSize: 18),
          ),
          const Text(
            '💧 Bebe suficiente agua.',
            style: TextStyle(fontSize: 18),
          ),
          const Text(
            '😴 Duerme lo suficiente para descansar.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Image.asset('assets/images/niño_imc_csj.jpg'),
        ],
      ),
    );
  }

  Widget _buildPercentilesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tablas de Percentiles de IMC:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Niños (2-19 años):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text('Bajo peso: <14.5 (Percentil 5)',
              style: TextStyle(fontSize: 16)),
          Text('Normal: 14.5 - 17.5 (Percentiles 5-85)',
              style: TextStyle(fontSize: 16)),
          Text('Sobrepeso: >17.5 (Percentil 85)',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 15),
          Text(
            'Niñas (2-19 años):',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text('Bajo peso: <14.0 (Percentil 5)',
              style: TextStyle(fontSize: 16)),
          Text('Normal: 14.0 - 17.0 (Percentiles 5-85)',
              style: TextStyle(fontSize: 16)),
          Text('Sobrepeso: >17.0 (Percentil 85)',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Text(
            'Recuerda que estos valores son solo una guía. Siempre es mejor consultar a un médico o nutricionista.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
