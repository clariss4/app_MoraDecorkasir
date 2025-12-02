import 'package:flutter/material.dart';
import '../widgets/navigation_drawer.dart' as custom;

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final String currentScreen;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {},
          ),
        ],
      ),

      drawer: custom.NavigationDrawer(
        currentScreen: currentScreen,
      ),

      body: body,
    );
  }
}
