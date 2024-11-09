import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestifit/screens/ajustes_screen.dart';
import 'package:gestifit/screens/compartir_progreso_screen.dart';
import 'package:gestifit/screens/detalle_receta_screen.dart';
import 'package:gestifit/screens/dieta_screen.dart';
import 'package:gestifit/screens/editar_perfil_screen.dart';
import 'package:gestifit/screens/ejercicio_screen.dart';
import 'package:gestifit/screens/escanear_alimentos_screen.dart';
import 'package:gestifit/screens/escanear_codigo_screen.dart';
import 'package:gestifit/screens/evaluacion_screen.dart';
import 'package:gestifit/screens/historial_imc.dart';
import 'package:gestifit/screens/historial_ritmo.dart';
import 'package:gestifit/screens/historial_evaluacion.dart';
import 'package:gestifit/screens/ingresar_manual_screen.dart';
import 'package:gestifit/screens/medicion_imc_menores_screen.dart';
import 'package:gestifit/screens/medicion_imc_screen.dart';
import 'package:gestifit/screens/medicion_ritmo_screen.dart';
import 'package:gestifit/screens/objetivos_screen.dart';
import 'package:gestifit/screens/perfil_screen.dart';
import 'package:gestifit/screens/social_screen.dart';
import 'firebase_options.dart';
import 'package:gestifit/screens/login_screen.dart';
import 'package:gestifit/screens/monitoreo_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:gestifit/providers/theme_notifier.dart';
import 'package:gestifit/screens/user_model.dart'; // Asegúrate de importar tu modelo de usuario

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GestiFitApp());
}

class GestiFitApp extends StatelessWidget {
  const GestiFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: ChangeNotifierProvider(
        create: (_) => UserModel(), // Proveedor para el modelo de usuario
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'GestiFit',
              theme: themeNotifier.isDarkTheme
                  ? ThemeData.dark()
                  : ThemeData.light(),
              home: const MainScreen(),
              routes: {
                '/login': (context) => const LoginScreen(),
                '/monitoreo': (context) => const MonitoreoScreen(),
                '/medicion_ritmo': (context) => const MedicionRitmoScreen(),
                '/medicion_imc': (context) => const MedicionImcScreen(),
                '/historial_imc': (context) => const HistorialImcScreen(),
                '/historial_ritmo': (context) => const HistorialRitmoScreen(),
                '/historial_evaluacion': (context) =>
                    HistorialEvaluacionScreen(),
                '/perfil': (context) => const PerfilScreen(),
                '/dieta': (context) => const DietaScreen(),
                '/ejercicio': (context) => const EjercicioScreen(),
                '/social': (context) => const SocialScreen(),
                '/detalleReceta': (context) => const DetalleRecetaScreen(),
                '/escanearAlimentos': (context) =>
                    const EscanearAlimentosScreen(),
                '/escanearCodigo': (context) => const EscanearCodigoScreen(),
                '/ingresarManual': (context) => const IngresarManualScreen(),
                '/editarPerfil': (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    return EditarPerfilScreen(firebaseUid: user.uid);
                  }
                  return const LoginScreen();
                },
                '/ajustes': (context) => const AjustesScreen(),
                '/evaluacion': (context) => const EvaluacionScreen(),
                '/objetivos': (context) => const ObjetivosScreen(),
                '/compartir_progreso': (context) =>
                    const CompartirProgresoScreen(),
                '/medicion_imc_menores': (context) =>
                    const MedicionImcMenoresScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const MonitoreoScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
