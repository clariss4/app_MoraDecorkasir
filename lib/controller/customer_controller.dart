import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerController {
  final SupabaseClient supabase;

  CustomerController({required this.supabase});

  // Ambil semua pelanggan
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final response = await supabase.from('pelanggan').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Tambah pelanggan
  Future<void> addCustomer({
    required String nama,
    required String kontak,
    required String alamat,
  }) async {
    await supabase.from('pelanggan').insert({
      'nama': nama,
      'kontak': kontak,
      'alamat': alamat,
    });
  }

  // Edit pelanggan
  Future<void> updateCustomer({
    required String id,
    required String nama,
    required String kontak,
    required String alamat,
  }) async {
    await supabase.from('pelanggan').update({
      'nama': nama,
      'kontak': kontak,
      'alamat': alamat,
    }).eq('id', id);
  }

  // Hapus pelanggan
  Future<void> deleteCustomer(String id) async {
    await supabase.from('pelanggan').delete().eq('id', id);
  }
}
