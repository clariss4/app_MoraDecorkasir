import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_kasir/screens/stok_history_screen.dart';
import '../controller/stock_controller.dart';
import '../models/stok_model.dart';
import '../widgets/app_drawer.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

class StockScreen extends ConsumerWidget {  // ✅ Harus ConsumerWidget
  const StockScreen({super.key});

  @override
 Widget build(BuildContext context, WidgetRef ref) {  // ✅ Harus ada WidgetRef ref
    final products = ref.watch(stockProvider);
    final query = ref.watch(searchQueryProvider);

    final filteredProducts = query.isEmpty
        ? products
        : products
            .where((p) =>
                p.nama.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock",
          style: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E),
            ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StockHistoryScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
        ),
      ),
      drawer: AppDrawer(currentScreen: 'Stock', onScreenSelected: (screen) {}),
      body: filteredProducts.isEmpty
          ? const Center(child: Text("Produk tidak ditemukan"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                final isLow = p.stok <= p.minStok;

                return Card(
                  color: isLow ? Colors.red.shade50 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                          p.imageUrl != null ? NetworkImage(p.imageUrl!) : null,
                    ),
                    title: Text(p.nama),
                    subtitle: Text("Stok: ${p.stok} | Min: ${p.minStok}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showUpdateStockDialog(context, ref, p);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showUpdateStockDialog(
      BuildContext context, WidgetRef ref, StockModel p) {
    final controller = TextEditingController(text: p.stok.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Stok - ${p.nama}"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Stok baru"),
          ),
          actions: [
            TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                final newStock = int.tryParse(controller.text) ?? p.stok;

                final message = await ref
                    .read(stockProvider.notifier)
                    .updateStock(p.id, newStock);

                Navigator.pop(context);

                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message), backgroundColor: Colors.red));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Stok berhasil diperbarui!")));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
