import 'package:flutter/material.dart';

class ProductStockScreen extends StatelessWidget {
  const ProductStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Product Stock",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              "Total product stock",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // SEARCH BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // TOTAL STOCK CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3EFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Text(
                    "Total Product Stock",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7CA6D9),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "4.350 item",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7CA6D9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // LIST STOCK
            Expanded(
              child: ListView(
                children: [
                  _productItem(),
                  _productItem(),
                  _productItem(),
                  _productItem(),
                  _productItem(),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B9ACC),
        onPressed: () {},
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _productItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // IMAGE - FIXED VERSION
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/images/vas_bunga_kaca.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Tampilkan icon jika gambar tidak ditemukan
                  return const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 30,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // PRODUCT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Transparant Glass Vas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text("TD", style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Rp150.000",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text("120 item", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // MENU
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}