import 'package:flutter/material.dart';

class ProductStockScreen extends StatelessWidget {
  const ProductStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock'),
        backgroundColor: Colors.white,
      ),
      body: const Center(child: Text('Halaman Product Stock')),
    );
  }
}
