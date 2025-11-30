import 'package:flutter/material.dart';
import '../services/database_service.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const PurchaseHistoryScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final databaseService = DatabaseService();
      final response = await databaseService.getTransactionsByCustomer(
        widget.customerId,
      );

      setState(() {
        _transactions = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat riwayat pembelian: $e';
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(double? amount) {
    if (amount == null) return 'Rp0';
    final formatted = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E2E2E),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Header Profil Pelanggan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    widget.customerName.isNotEmpty
                        ? widget.customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Status: Aktif',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Judul
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text(
                  'Riwayat Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Daftar Transaksi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _transactions.isEmpty
                ? const Center(child: Text('Belum ada riwayat pembelian'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];

                      // Ambil data secara dinamis
                      final String productName =
                          tx['nama_produk'] ??
                          tx['nama'] ??
                          'Produk tidak dikenal';
                      final int qty = tx['jumlah'] ?? 0;
                      final double total =
                          (tx['total_harga'] as num?)?.toDouble() ?? 0.0;
                      final String? createdAt = tx['created_at'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          title: Text(productName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jumlah: $qty'),
                              Text(_formatRupiah(total)),
                            ],
                          ),
                          trailing: createdAt != null
                              ? Text(
                                  DateTime.parse(
                                    createdAt,
                                  ).toLocal().toIso8601String().split('T')[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Text(
                                  'Tanggal tidak tersedia',
                                  style: TextStyle(fontSize: 12),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
