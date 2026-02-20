import 'package:flutter/material.dart';

class SchedulaBottomNagivationBar extends StatelessWidget {

  final int currentIndexOfPages;
  final Function(int) onTabTapped;

  const SchedulaBottomNagivationBar({
    super.key,
    required this.currentIndexOfPages,
    required this.onTabTapped
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndexOfPages,
      onTap: onTabTapped,
      backgroundColor: Colors.indigo,
      selectedItemColor: Colors.indigo.shade100,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Prenotazioni"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "Attività"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profilo"
        )
      ],
    );
  }
}