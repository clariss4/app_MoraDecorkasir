import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =============================================================
  // 🔹 PRODUK 
  // =============================================================

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

Future<void> updateProductStock(String productId, int newStock) async {
  await _supabase
      .from('produk')
      .update({
        'stok': newStock,
        'updated_at': DateTime.now().toIso8601String()
      })
      .eq('id', productId);
}

  // =============================================================
  // 🔹 UPLOAD IMAGE (STORAGE)
  // =============================================================

  Future<String> uploadProductImageBytes(
      Uint8List imageBytes,
      String productId,
      String originalFileName,
      ) async {
    try {
      final extension = originalFileName.split('.').last.toLowerCase();
      final valid = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final ext = valid.contains(extension) ? extension : 'jpg';

      final String fileName =
          '${productId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final String filePath = 'products/$fileName';

      await _supabase.storage
          .from('product-storage')
          .uploadBinary(
        filePath,
        imageBytes,
        fileOptions: FileOptions(
          contentType: 'image/$ext',
          upsert: false,
        ),
      );

      final String url = _supabase.storage
          .from('product-storage')
          .getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final idx = segments.indexOf('products');

      if (idx != -1 && idx + 1 < segments.length) {
        final fileName = segments[idx + 1];
        final path = 'products/$fileName';

        await _supabase.storage
            .from('product-storage')
            .remove([path]);
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  // =============================================================
  // 🔹 KATEGORI (DITAMBAH)
  // =============================================================

  Future<List<Map<String, dynamic>>> getKategori() async {
    final response =
        await _supabase.from('kategori').select('id, nama, deskripsi');
    return response;
  }

  Future<void> addKategori(Map<String, dynamic> data) async {
    await _supabase.from('kategori').insert(data);
  }

  Future<void> updateKategori(String id, Map<String, dynamic> data) async {
    await _supabase.from('kategori').update(data).eq('id', id);
  }

  Future<void> deleteKategori(String id) async {
    await _supabase.from('kategori').delete().eq('id', id);
  }

  // =============================================================
  // 🔹 PELANGGAN
  // =============================================================

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await _supabase.from('pelanggan').select();
    return response;
  }

  Future<void> addCustomer(Map<String, dynamic> data) async {
    await _supabase.from('pelanggan').insert(data);
  }

  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    await _supabase.from('pelanggan').update(data).eq('id', id);
  }

  Future<void> deleteCustomer(String id) async {
    await _supabase.from('pelanggan').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String? query) async {
    var request = _supabase.from('pelanggan').select();

    if (query != null && query.trim().isNotEmpty) {
      request = request.ilike('nama', '%$query%');
    }

    final response = await request;
    return response.cast<Map<String, dynamic>>();
  }

  // =============================================================
  // 🔹 PENJUALAN
  // =============================================================

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _supabase.from('penjualan').select();
    return response;
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _supabase.from('penjualan').insert(data);
  }

  Future<List<Map<String, dynamic>>> getTransactionsByCustomer(
      String customerId) async {
    final response = await _supabase
        .from('penjualan')
        .select()
        .eq('pelanggan_kasir_id', customerId)
        .order('created_at', ascending: false);
    return response.cast<Map<String, dynamic>>();
  }

  // =============================================================
  // 🔹 DETAIL PENJUALAN (DITAMBAH)
  // =============================================================

  Future<void> addDetailPenjualan(Map<String, dynamic> data) async {
    await _supabase.from('detail_penjualan').insert(data);
  }

  Future<List<Map<String, dynamic>>> getDetailByPenjualan(String idPenjualan) async {
    final response = await _supabase
        .from('detail_penjualan')
        .select()
        .eq('id_penjualan', idPenjualan);
    return response;
  }

  // =============================================================
  // 🔹 DISKON (DITAMBAH)
  // =============================================================

  Future<List<Map<String, dynamic>>> getDiskon() async {
    return await _supabase.from('diskon').select();
  }

  Future<void> addDiskon(Map<String, dynamic> data) async {
    await _supabase.from('diskon').insert(data);
  }

  Future<void> updateDiskon(String id, Map<String, dynamic> data) async {
    await _supabase.from('diskon').update(data).eq('id', id);
  }

  Future<void> deleteDiskon(String id) async {
    await _supabase.from('diskon').delete().eq('id', id);
  }

  // =============================================================
  // 🔹 PELANGGAN-KASIR (DITAMBAH)
  // =============================================================

  Future<void> addPelangganKasir(Map<String, dynamic> data) async {
    await _supabase.from('pelanggan_kasir').insert(data);
  }

  Future<List<Map<String, dynamic>>> getPelangganByKasir(String kasirId) async {
    final response = await _supabase
        .from('pelanggan_kasir')
        .select('id, pelanggan:pelanggan(*)')
        .eq('kasir_id', kasirId);
    return response;
  }

  // =============================================================
  // 🔹 LAPORAN (DITAMBAH)
  // =============================================================

  Future<void> addLaporan(Map<String, dynamic> data) async {
    await _supabase.from('laporan').insert(data);
  }

  Future<List<Map<String, dynamic>>> getLaporanByKasir(String kasirId) async {
    final response = await _supabase
        .from('laporan')
        .select()
        .eq('kasir_id', kasirId)
        .order('periode', ascending: false);
    return response;
  }

  // =============================================================
  // 🔹 DASHBOARD STATS (Tetap)
  // =============================================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final productsResponse = await _supabase.from('produk').select('stok');
      final totalProducts = productsResponse.fold<int>(
        0,
            (sum, item) => sum + (item['stok'] as int? ?? 0),
      );

      final customersResponse = await _supabase.from('pelanggan').select('id');
      final totalCustomers = customersResponse.length;

      final transactionsResponse =
      await _supabase.from('penjualan').select('id');
      final recentTransactions = transactionsResponse.length;

      return {
        'totalProducts': totalProducts,
        'totalCustomers': totalCustomers,
        'recentTransactions': recentTransactions,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalProducts': 0,
        'totalCustomers': 0,
        'recentTransactions': 0
      };
    }
  }

  // =============================================================
  // 🔹 PROFILE USER (Tetap)
  // =============================================================

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }
// =============================================================
// 🔹 FORM PRODUK (Tambah / Edit)
// =============================================================
Future<void> showProdukForm(
  BuildContext context, {
  Map<String, dynamic>? editData,
}) async {

  final TextEditingController namaController =
      TextEditingController(text: editData?['nama'] ?? '');
  final TextEditingController hargaController =
      TextEditingController(text: editData?['harga']?.toString() ?? '');

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(editData == null ? "Tambah Produk" : "Edit Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: "Harga Produk"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              final data = {
                "nama": namaController.text,
                "harga": int.tryParse(hargaController.text) ?? 0,
              };

              if (editData == null) {
                /// ADD PRODUCT
                await _supabase.from('produk').insert(data);
              } else {
                /// UPDATE PRODUCT
                await _supabase
                    .from('produk')
                    .update(data)
                    .eq('id', editData['id']);
              }

              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      );
    },
  );
}

  
}
