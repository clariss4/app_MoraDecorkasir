import 'package:flutter/material.dart';

class RecentTransactionsScreen extends StatelessWidget {
  const RecentTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Transactions'),
        backgroundColor: Colors.white,
      ),
      body: const Center(child: Text('Halaman Recent Transactions')),
    );
  }
}
