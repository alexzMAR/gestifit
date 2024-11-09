import 'package:flutter/material.dart';

class DetalleRecetaScreen extends StatelessWidget {
  const DetalleRecetaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Receta'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen del plato
            Image.network(
              'https://example.com/receta.jpg',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del plato
                  Text(
                    'Pollo con arroz y vegetales',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Descripción de la receta
                  Text(
                    'Una receta saludable que combina proteínas y carbohidratos de calidad, ideal para una comida completa y balanceada.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Información nutricional
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calorías: 450 kcal',
                          style: TextStyle(fontSize: 16)),
                      Text('Proteínas: 30g', style: TextStyle(fontSize: 16)),
                      Text('Carbohidratos: 50g',
                          style: TextStyle(fontSize: 16)),
                      Text('Grasas: 15g', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Divider(height: 32),
                  // Ingredientes
                  Text(
                    'Ingredientes:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• 200g de pechuga de pollo'),
                  Text('• 100g de arroz integral'),
                  Text('• 50g de zanahorias'),
                  Text('• 50g de brócoli'),
                  Text('• Aceite de oliva y especias al gusto'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
