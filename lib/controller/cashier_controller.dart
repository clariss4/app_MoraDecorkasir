import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CashierController {
  final BuildContext context;
  final void Function(VoidCallback fn) setState;

  CashierController(this.context, this.setState);

  // ================= STATE =================
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  String? selectedKategoriId;
  bool isLoading = true;
  String? error;

  String formatRupiah(num value) {
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
}


  /// CART
  /// key = productId
  /// value = { nama, harga, qty, imageUrl }
  final Map<String, Map<String, dynamic>> cart = {};

  // ================= LOAD PRODUCT =================
  Future<void> loadProducts() async {
    setState(() => isLoading = true);

    try {
      final db = DatabaseService();
      final data = await db.getProducts();

      // hanya produk dengan stok > 0
      allProducts = data.where((p) => (p['stok'] ?? 0) > 0).toList();
      applyFilter();
    } catch (e) {
      error = 'Gagal memuat produk: $e';
    }

    isLoading = false;
    setState(() {});
  }

  // ================= FILTER & SEARCH =================
  void applyFilter() {
    filteredProducts = allProducts.where((product) {
      final nama =
          product['nama']?.toString().toLowerCase() ?? '';

      final matchSearch =
          nama.contains(searchController.text.toLowerCase());

      final matchKategori =
          selectedKategoriId == null ||
          product['kategori_produk'] == selectedKategoriId;

      return matchSearch && matchKategori;
    }).toList();
  }

  void onSearchChanged(String value) {
    setState(applyFilter);
  }

  void selectKategori(String? kategoriId) {
    setState(() {
      selectedKategoriId = kategoriId;
      applyFilter();
    });
  }

  // ================= CART LOGIC =================
  void addToCart(Map<String, dynamic> product) {
    final id = product['id'];

    if (cart.containsKey(id)) {
      increaseQty(id);
      return;
    }

    cart[id] = {
      'productId': id,
      'nama': product['nama'],
      'harga': product['harga_jual'],
      'qty': 1,
      'imageUrl': product['image_url'],
    };

    setState(() {});
  }

  void increaseQty(String productId) {
    final item = cart[productId];
    if (item == null) return;

    final product =
        allProducts.firstWhere((p) => p['id'] == productId);

    if (item['qty'] < product['stok']) {
      item['qty'] += 1;
      setState(() {});
    }
  }

  void decreaseQty(String productId) {
    final item = cart[productId];
    if (item == null) return;

    if (item['qty'] > 1) {
      item['qty'] -= 1;
    } else {
      cart.remove(productId);
    }

    setState(() {});
  }

  int getQty(String productId) {
    return cart[productId]?['qty'] ?? 0;
  }

  // ================= CART SUMMARY =================
  int get totalItem {
    return cart.values.fold(
      0,
      (sum, item) => sum + (item['qty'] as int),
    );
  }

  double get totalPrice {
    return cart.values.fold(
      0.0,
      (sum, item) =>
          sum + (item['harga'] as num) * (item['qty'] as int),
    );
  }

  void clearCart() {
    cart.clear();
    setState(() {});
  }

  // ================= CLEANUP =================
  void dispose() {
    searchController.dispose();
  }
}


