// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Dieta'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Monitoreo'),
        BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), label: 'Ejercicio'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Social'),
      ],
    );
  }
}
