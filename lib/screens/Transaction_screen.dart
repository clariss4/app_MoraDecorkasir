import 'package:flutter/material.dart';

class RecentTransactionScreen extends StatelessWidget {
  const RecentTransactionScreen({super.key});

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
          "Transaction",
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
              "List of recent transactions",
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

            // TOP CARDS
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCE9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Today's Total", style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          "Rp. 2.350.000",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(Icons.savings),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8EFE0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Transactions", style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          "90",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(Icons.receipt_long),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // LIST DATA
            Expanded(
              child: ListView(
                children: [
                  _transactionItem(
                    id: "#TX-0998",
                    date: "12 Apr 2022, 14:32",
                    product: "Transparant Glass Vas",
                    detail: "2 x Rp. 150.000",
                    price: "Rp 300.000",
                    cashier: "Clarissa",
                  ),
                  _transactionItem(
                    id: "#TX-0965",
                    date: "12 Apr 2022, 14:32",
                    product: "Transparant Glass Vas",
                    detail: "2 x Rp. 150.000",
                    price: "Rp 300.000",
                    cashier: "Clarissa",
                  ),
                  _transactionItem(
                    id: "#TX-0847",
                    date: "12 Apr 2022, 14:32",
                    product: "Wooden 4R Frame Photo",
                    detail: "2 x Rp. 40.000",
                    price: "Rp 80.000",
                    cashier: "Clarissa",
                  ),
                  _transactionItem(
                    id: "#TX-0946",
                    date: "12 Apr 2022, 14:32",
                    product: "Transparant Glass Vas",
                    detail: "1 x Rp. 150.000",
                    price: "Rp 150.000",
                    cashier: "Clarissa",
                  ),
                  _transactionItem(
                    id: "#TX-0998",
                    date: "12 Apr 2022, 14:32",
                    product: "Lavender Scented Candle",
                    detail: "4 x Rp. 50.000",
                    price: "Rp 200.000",
                    cashier: "Clarissa",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B9ACC),
        onPressed: () {},
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _transactionItem({
    required String id,
    required String date,
    required String product,
    required String detail,
    required String price,
    required String cashier,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),

          const SizedBox(height: 8),
          Text(product, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(detail, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              cashier,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
