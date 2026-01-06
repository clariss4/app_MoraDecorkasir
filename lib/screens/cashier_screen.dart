import 'package:flutter/material.dart';
import 'package:pos_kasir/screens/cart_screen.dart';
import 'package:pos_kasir/screens/notifikasi_screen.dart';
import 'package:pos_kasir/widgets/app_drawer.dart';
import '../controller/cashier_controller.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  late CashierController controller;

  int selectedCategory = 0;
  List<String> categories = ["All", "WD", "TD", "LD", "FD"];

  @override
  void initState() {
    super.initState();
    controller = CashierController(context, setState);
    controller.loadProducts();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cashier",
          style: TextStyle(
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(currentScreen: 'Cashier', onScreenSelected: (_) {}),
      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------- CATEGORY FILTER ----------------
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _kategoriButton(
                  categories[index],
                  index,
                  selectedCategory == index,
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- PRODUCT LIST ----------------
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProducts[index];
                      return productCard(product);
                    },
                  ),
          ),
        ],
      ),

      // ---------------- CART FLOATING BUTTON ----------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade400,
        onPressed: controller.cart.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
        icon: const Icon(Icons.shopping_cart_outlined),
        label: Text("Cart (${controller.totalItem})"),
      ),
    );
  }

  // ---------------- CATEGORY CHIP ----------------
  Widget _kategoriButton(String label, int index, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: active ? Colors.white : const Color(0xFF6F90B9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF6F90B9) : Colors.transparent,
            width: 1,
          ),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 0),
            padding: const EdgeInsets.symmetric(vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            setState(() {
              selectedCategory = index;
            });
          },
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? const Color(0xFF6F90B9) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- PRODUCT CARD ----------------
  Widget productCard(Map<String, dynamic> product) {
    final qty = controller.getQty(product['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 90,
              width: 90,
              color: Colors.grey.shade300,
              child:
                  product['image_url'] != null &&
                      product['image_url'].toString().isNotEmpty
                  ? Image.network(
                      product['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 40),
                    )
                  : const Icon(Icons.image, size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nama'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['deskripsi'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Stock: ${product['stok']}",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp${controller.formatRupiah(product['harga_jual'])}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7292ba),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => controller.addToCart(product),
                      child: const Text("Add to cart"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    qtyButton(
                      Icons.remove,
                      () => controller.decreaseQty(product['id']),
                    ),
                    const SizedBox(width: 10),
                    Text("$qty", style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 10),
                    qtyButton(
                      Icons.add,
                      () => controller.increaseQty(product['id']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 26,
        width: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
