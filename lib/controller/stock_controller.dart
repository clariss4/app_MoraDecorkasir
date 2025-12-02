import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/stok_model.dart';
import '../models/stock_history_model.dart';
import '../services/database_service.dart';

final stockProvider =
    StateNotifierProvider<StockController, List<StockModel>>(
  (ref) => StockController(ref),
);

final stockHistoryProvider =
    StateNotifierProvider<StockHistoryController, List<StockHistory>>(
  (ref) => StockHistoryController(),
);

class StockController extends StateNotifier<List<StockModel>> {
  final Ref ref;
  final DatabaseService db = DatabaseService();

  StockController(this.ref) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final data = await db.getProducts();
      final products = data.map((e) => StockModel.fromJson(e)).toList();
      state = products;
    } catch (e) {
      print("Gagal load produk: $e");
      state = [];
    }
  }

  Future<String?> updateStock(String id, int newStock) async {
    try {
      final index = state.indexWhere((p) => p.id == id);
      if (index == -1) return "Produk tidak ditemukan";

      // update di state
      state[index] = state[index].copyWith(stok: newStock);
      state = [...state];

      // update ke database
      await db.updateProduct(id, {"stok": newStock});

      // Tambahkan ke history
      final updatedProduct = state[index];
      ref.read(stockHistoryProvider.notifier).add(updatedProduct);

      if (newStock <= updatedProduct.minStok) {
        return "Stok produk mendekati batas minimum!";
      }

      return null;
    } catch (e) {
      return "Gagal update stok: $e";
    }
  }
}

class StockHistoryController extends StateNotifier<List<StockHistory>> {
  StockHistoryController() : super([]);

  void add(StockModel product) {
    final history = StockHistory(
      productId: product.id,
      nama: product.nama,
      stokBaru: product.stok,
      updatedAt: DateTime.now(),
    );

    state = [history, ...state];
  }

  void clear() => state = [];
}
