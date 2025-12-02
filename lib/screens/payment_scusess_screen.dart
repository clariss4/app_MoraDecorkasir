import 'package:flutter/material.dart';
import 'package:pos_kasir/screens/cashier_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.notifications_none), SizedBox(width: 16)],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // CHECK ICON
            CircleAvatar(
              radius: 38,
              backgroundColor: Color(0XFF7292ba),
              child: const Icon(Icons.check, color: Colors.white, size: 38),
            ),

            const SizedBox(height: 20),

            const Text(
              "Payment Successful!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),

            const SizedBox(height: 30),

            _infoRow("Transaction Number", "#TRX-20943-09972"),
            _infoRow("Date", "17 Apr 2023, 10:30 AM"),
            _infoRow("Methode", "Cash"),
            _infoRow("Paid", "Rp 300.000"),
            _infoRow("Total Payment", "Rp243.000"),
            _infoRow("Change Money", "Rp57.000"),

            const SizedBox(height: 25),
            const Divider(),

            const SizedBox(height: 15),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _blueButton(Icons.print, "Print Receipt"),
                _blueButton(Icons.chat_rounded, "Send via WhatsApp"),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CashierScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0XFF7292ba),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "New Transaction",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(color: Colors.grey)),
          Text(right, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _blueButton(IconData icon, String text) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0XFF7292ba),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
