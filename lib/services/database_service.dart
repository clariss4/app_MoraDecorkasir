import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔹 PRODUK (sesuai tabel 'produk')
  // Di DatabaseService.dart
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _supabase.from('produk').select();
    return response;
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _supabase.from('produk').insert(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _supabase.from('produk').update(data).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('produk').delete().eq('id', id);
  }

  // 🔹 KATEGORI
  Future<List<Map<String, dynamic>>> getKategori() async {
    final response = await _supabase
        .from('kategori')
        .select('id, nama, deskripsi');
    return response;
  }

  // 🔹 PELANGGAN (sesuai tabel 'pelanggan')
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await _supabase.from('pelanggan').select();
    return response;
  }

  Future<void> addCustomer(Map<String, dynamic> data) async {
    await _supabase.from('pelanggan').insert(data);
  }

  // 🔹 PELANGGAN - TAMBAHAN UNTUK UPDATE & DELETE
  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    await _supabase.from('pelanggan').update(data).eq('id', id);
  }

  Future<void> deleteCustomer(String id) async {
    await _supabase.from('pelanggan').delete().eq('id', id);
  }

  // 🔹 PELANGGAN - DENGAN SEARCH BERDASARKAN NAMA
  Future<List<Map<String, dynamic>>> searchCustomers(String? query) async {
    var request = _supabase.from('pelanggan').select();

    if (query != null && query.trim().isNotEmpty) {
      request = request.ilike('nama', '%$query%'); // hanya cari di kolom 'nama'
    }

    final response = await request;
    return response.cast<Map<String, dynamic>>();
  }

  // 🔹 PENJUALAN (sesuai tabel 'penjualan')
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _supabase.from('penjualan').select();
    return response;
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _supabase.from('penjualan').insert(data);
  }

  // 🔹 DASHBOARD STATS
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Total stok produk
      final productsResponse = await _supabase.from('produk').select('stok');
      final totalProducts = productsResponse.fold<int>(
        0,
        (sum, item) => sum + (item['stok'] as int? ?? 0),
      );

      // Total pelanggan
      final customersResponse = await _supabase.from('pelanggan').select('id');
      final totalCustomers = customersResponse.length;

      // Transaksi terbaru
      final transactionsResponse = await _supabase
          .from('penjualan')
          .select('id');
      final recentTransactions = transactionsResponse.length;

      return {
        'totalProducts': totalProducts,
        'totalCustomers': totalCustomers,
        'recentTransactions': recentTransactions,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {'totalProducts': 0, 'totalCustomers': 0, 'recentTransactions': 0};
    }
  }

  // 🔹 PROFIL USER
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // 🔹 GET TRANSAKSI BERDASARKAN PELANGGAN (SESUAI STRUKTUR DB MU)
  Future<List<Map<String, dynamic>>> getTransactionsByCustomer(
    String customerId,
  ) async {
    final response = await _supabase
        .from('penjualan')
        .select()
        .eq(
          'pelanggan_kasir_id',
          customerId,
        ) // ⚠️ GANTI DENGAN NAMA KOLOM YANG BENAR!
        .order('created_at', ascending: false);
    return response.cast<Map<String, dynamic>>();
  }
}
