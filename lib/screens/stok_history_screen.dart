import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/stock_controller.dart';

class StockHistoryScreen extends ConsumerWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(stockHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("History Update Stok"),
      ),
      body: history.isEmpty
          ? const Center(child: Text("Belum ada update stok"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(item.nama),
                    subtitle: Text(
                        "Stok baru: ${item.stokBaru}\nUpdate: ${item.updatedAt.toLocal().toString().split('.')[0]}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                );
              },
            ),
    );
  }
}
