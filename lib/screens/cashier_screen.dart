import 'package:flutter/material.dart';
import 'package:pos_kasir/screens/cart_screen.dart';
import 'package:pos_kasir/screens/notifikasi_screen';
import 'package:pos_kasir/widgets/app_drawer.dart';


class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  int selectedCategory = 0;
  List<String> categories = ["All", "WD", "TD", "LD", "FD"];

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
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        currentScreen: 'Cashier',
        onScreenSelected: (screen) {},
      ),

      body: Column(
        children: [
          // ---------------- SEARCH BAR ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
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
         // ---------------- CATEGORY FILTER ----------------
Container(
  height: 45,
  margin: const EdgeInsets.symmetric(vertical: 8),
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final isSelected = selectedCategory == index;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(categories[index]),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              selectedCategory = index;
            });
          },
          selectedColor: const Color(0XFF7292ba),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    },
  ),
),

          const SizedBox(height: 10),

          // ---------------- PRODUCT LIST ----------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10, // nanti dynamic
              itemBuilder: (context, index) {
                return _productCard();
              },
            ),
          ),
        ],
      ),

      // ---------------- CART FLOATING BUTTON ----------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue.shade400,
        onPressed: () {
          Navigator.push(context, 
          MaterialPageRoute(builder: (_)=> const CartScreen()));
        },
        icon: const Icon(Icons.shopping_cart_outlined),
        label: const Text("Cart"),
      ),
    );
  }

  Widget _productCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 95,
            width: 95,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(width: 14),

          // PRODUCT DATA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transparent Glass Vase",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                const SizedBox(height: 4),
                const Text(
                  "Modern abstract glass vase for living rooms.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 6),
                const Text(
                  "Rp150.000",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    // MIN BUTTON
                    Container(
                      decoration: circleButtonStyle(),
                      child: const Icon(Icons.remove, size: 18),
                    ),

                    const SizedBox(width: 12),
                    const Text("0", style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 12),

                    // ADD BUTTON
                    Container(
                      decoration: circleButtonStyle(),
                      child: const Icon(Icons.add, size: 18),
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

  BoxDecoration circleButtonStyle() {
    return BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200);
  }
}
