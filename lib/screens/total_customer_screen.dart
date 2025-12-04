import 'package:flutter/material.dart';

class TotalCustomerScreen extends StatelessWidget {
  const TotalCustomerScreen({super.key});

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
          "Total Customer",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "Total active customers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Search bar
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

            // LIST CUSTOMERS
            Expanded(
              child: ListView(
                children: [
                  _customerItem(
                    name: "Hanni Sigma",
                    phone: "022137236783",
                    balance: "Rp5.450.000",
                  ),
                  _customerItem(
                    name: "Sapri Gacor",
                    phone: "0547743925938",
                    balance: "Rp7.450.000",
                  ),
                  _customerItem(
                    name: "Minji Lima",
                    phone: "097452958302",
                    balance: "Rp9.090.000",
                  ),
                  _customerItem(
                    name: "Jennie Ruby",
                    phone: "041846397194",
                    balance: "Rp15.450.000",
                  ),
                  _customerItem(
                    name: "W Nia",
                    phone: "095426545493",
                    balance: "Rp8.450.000",
                  ),
                  _customerItem(
                    name: "Windah Batubara",
                    phone: "096483629475",
                    balance: "Rp5.050.000",
                  ),
                  _customerItem(
                    name: "Windah Habatusauda",
                    phone: "094376536547",
                    balance: "Rp6.400.000",
                  ),
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

  Widget _customerItem({
    required String name,
    required String phone,
    required String balance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  balance,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT SIDE
          Column(
            children: const [
              Text(
                "Active",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Icon(Icons.check, color: Colors.green, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
