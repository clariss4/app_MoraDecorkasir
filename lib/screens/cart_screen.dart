import 'package:flutter/material.dart';
import 'package:pos_kasir/screens/payment_scusess_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
        actions: const [Icon(Icons.notifications_none), SizedBox(width: 16)],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------- CUSTOMER INPUT ----------------
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Add customer name...",
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  side: BorderSide(color: Colors.blue.shade400),
                ),
                child: const Text("Walk-in"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------------- TRANSACTION INFO ----------------
          const Text(
            "#TRX-20943-09972",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "17 Apr 2023, 10:30 AM",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // ---------------- SEARCH PRODUCT ----------------
          TextField(
            decoration: InputDecoration(
              hintText: "Search product...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- CART ITEM LIST ----------------
          for (int i = 0; i < 3; i++) _cartItemCard(),

          const SizedBox(height: 20),

          // ---------------- PRICE SUMMARY ----------------
          _priceSummary(),

          const SizedBox(height: 20),

          // ---------------- PAYMENT METHOD ----------------
          const Text(
            "Select Payment Method",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Radio(value: true, groupValue: true, onChanged: (_) {}),
              const Text("Cash"),

              const SizedBox(width: 20),

              Radio(value: false, groupValue: true, onChanged: (_) {}),
              const Text("Debit / Credit / e-Wallet"),
            ],
          ),

          const SizedBox(height: 25),

          // ---------------- CONFIRM ----------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                 MaterialPageRoute(builder: (_)=>
                 const PaymentSuccessScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Confirm & Print Receipt",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItemCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Transparent Glass Vase",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Rp150.000",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.remove, size: 18),
              ),
              const SizedBox(width: 12),
              const Text("2", style: TextStyle(fontSize: 15)),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.add, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _rowText("SubTotal", "Rp345.000"),
        _rowText("Discount", "-Rp2.000"),
        _rowText("Tax (10%)", "Rp20.000"),
        Divider(),
        _rowText("Total Payment", "Rp243.000", bold: true, fontSize: 17),
      ],
    );
  }
}

class _rowText extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;
  final double fontSize;

  const _rowText(
    this.left,
    this.right, {
    this.bold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
