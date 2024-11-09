// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class MedicionRitmoScreen extends StatefulWidget {
  const MedicionRitmoScreen({super.key});

  @override
  _MedicionRitmoScreenState createState() => _MedicionRitmoScreenState();
}

class _MedicionRitmoScreenState extends State<MedicionRitmoScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isMeasuring = false;
  String _resultado = '';
  String _mensajeSalud = '';
  late AnimationController _animationController;
  Timer? _timer;
  late Interpreter _interpreter;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model_rc.tflite');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();

    await _initializeControllerFuture;

    if (_controller!.value.flashMode == FlashMode.off) {
      await _controller!.setFlashMode(FlashMode.torch);
    }

    setState(() {
      _isMeasuring = true;
    });

    _startMeasuring();
  }

  void _startMeasuring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.takePicture().then((image) {
          print(
              "Imagen capturada: ${image.path}"); // Verificar si se captura la imagen
          _processImage(image);
        });
      }
    });

    Timer(const Duration(seconds: 30), _finalizarMedicion);
  }

  void _processImage(XFile image) async {
    var inputImage = await _preprocessImage(image);
    var output = List.filled(1, 0.0).reshape([1, 1]);

    _interpreter.run(inputImage, output);

    print("Salida del modelo: $output"); // Verificar la salida del modelo

    setState(() {
      int heartRate = output[0][0].toInt();
      _resultado = 'Ritmo Cardíaco: $heartRate bpm';
      _mensajeSalud = _evaluarRitmoCardiaco(heartRate);
      _guardarRitmoCardiaco(heartRate);
    });
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(XFile image) async {
    final bytes = await image.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);

    const int width =
        224; // Asegúrate de que este tamaño coincide con tu modelo
    const int height =
        224; // Asegúrate de que este tamaño coincide con tu modelo
    img.Image resizedImage =
        img.copyResize(decodedImage!, width: width, height: height);

    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(
          width,
          (x) {
            int pixel = resizedImage.getPixel(x, y) as int;
            double r = ((pixel >> 16) & 0xFF) / 255.0;
            double g = ((pixel >> 8) & 0xFF) / 255.0;
            double b = (pixel & 0xFF) / 255.0;
            return [(r + g + b) / 3];
          },
        ),
      ),
    );

    print("Imagen procesada: $input"); // Verificar la imagen procesada
    return input;
  }

  String _evaluarRitmoCardiaco(int ritmoCardiaco) {
    if (ritmoCardiaco < 60) {
      return 'Ritmo cardíaco bajo. Consulta a un médico si te sientes mal.';
    } else if (ritmoCardiaco <= 100) {
      return 'Ritmo cardíaco normal. ¡Bien hecho!';
    } else {
      return 'Ritmo cardíaco elevado. Considera hacer una pausa y relajarte.';
    }
  }

  Future<void> _guardarRitmoCardiaco(int ritmoCardiaco) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      String fechaRegistro = DateTime.now().toIso8601String();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/historialRitmoCardiaco'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fecharegistro': fechaRegistro,
          'RitmoCardiaco': ritmoCardiaco.toString(),
          'firebase_uid': uid,
        }),
      );

      if (response.statusCode == 201) {
        print('Ritmo cardíaco guardado exitosamente');
      } else {
        print('Error al guardar el ritmo cardíaco: ${response.body}');
      }
    }
  }

  void _finalizarMedicion() {
    _timer?.cancel();
    setState(() {
      _isMeasuring = false;
    });
    _controller!.setFlashMode(FlashMode.off);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    _timer?.cancel();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medición de Ritmo Cardíaco',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _isMeasuring
            ? FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: CameraPreview(_controller!),
                        ),
                        Positioned(
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.9, end: 1.1)
                                .animate(_animationController),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 4),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 40,
                          child: Text(
                            'Coloca tu dedo sobre la cámara',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'COMIENZO',
                    style: TextStyle(fontSize: 32, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Presiona para medir',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.favorite,
                        size: 100, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _initializeCamera();
                    },
                    child: const Text('Iniciar Medición'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _resultado,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _mensajeSalud,
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/historial_ritmo');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Ver Historial de Ritmo Cardíaco',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MedicionRitmoScreen(),
  ));
}
