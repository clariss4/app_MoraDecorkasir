import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // PRODUCTS CRUD
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _supabase.from('products').select();
    return response;
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _supabase.from('products').insert(data);
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _supabase.from('products').update(data).eq('product_id', id);
  }

  Future<void> deleteProduct(int id) async {
    await _supabase.from('products').delete().eq('product_id', id);
  }

  // CUSTOMERS CRUD
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await _supabase.from('customers').select();
    return response;
  }

  Future<void> addCustomer(Map<String, dynamic> data) async {
    await _supabase.from('customers').insert(data);
  }

  // TRANSACTIONS CRUD
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final response = await _supabase.from('transactions').select();
    return response;
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _supabase.from('transactions').insert(data);
  }

  // DASHBOARD STATS
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get total products
      final productsResponse = await _supabase.from('products').select('stock');
      final totalProducts = productsResponse.fold<int>(
        0,
        (sum, item) => sum + (item['stock'] as int? ?? 0),
      );

      // Get total customers
      final customersResponse = await _supabase.from('customers').select('id');
      final totalCustomers = customersResponse.length;

      // Get recent transactions count
      final transactionsResponse = await _supabase
          .from('transactions')
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
}
