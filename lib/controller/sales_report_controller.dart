import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/sales_report_model.dart';

class SalesReportController {
  final DatabaseService _db = DatabaseService();

  /// Ambil seluruh data transaksi dari Supabase
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    return await _db.getTransactions();
  }

  /// Ambil seluruh detail untuk satu transaksi
  Future<List<Map<String, dynamic>>> fetchDetail(String idPenjualan) async {
    return await _db.getDetailByPenjualan(idPenjualan);
  }

  /// =============================
  /// 🔎 FILTER TRANSAKSI
  /// =============================
  List<Map<String, dynamic>> filterTransactions({
    required List<Map<String, dynamic>> trx,
    DateTime? startDate,
    DateTime? endDate,
    String? produkId,
    String? pelangganId,
    String? kasirId,
    String? periode, // daily, weekly, monthly
  }) {
    List<Map<String, dynamic>> filtered = trx;

    // Filter berdasarkan tanggal
    if (startDate != null && endDate != null) {
      filtered = filtered.where((t) {
        final date = DateTime.parse(t['created_at']);
        return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // filter pelanggan
    if (pelangganId != null) {
      filtered = filtered.where((t) => t['id_pelanggan'] == pelangganId).toList();
    }

    // filter kasir
    if (kasirId != null) {
      filtered = filtered.where((t) => t['kasir_id'] == kasirId).toList();
    }

    // Filter harian / mingguan / bulanan
    if (periode != null) {
      DateTime now = DateTime.now();

      if (periode == "daily") {
        filtered = filtered.where((t) {
          return DateFormat("yyyy-MM-dd")
              .format(DateTime.parse(t['created_at'])) ==
              DateFormat("yyyy-MM-dd").format(now);
        }).toList();
      }

      if (periode == "weekly") {
        final minggu = now.subtract(const Duration(days: 7));
        filtered = filtered.where((t) {
          final d = DateTime.parse(t['created_at']);
          return d.isAfter(minggu);
        }).toList();
      }

      if (periode == "monthly") {
        filtered = filtered.where((t) {
          final d = DateTime.parse(t['created_at']);
          return (d.month == now.month && d.year == now.year);
        }).toList();
      }
    }

    // filter produk (harus cek detail penjualan)
    if (produkId != null) {
      filtered = filtered.where((t) => t['detail'] != null &&
          (t['detail'] as List).any((d) => d['id_produk'] == produkId)).toList();
    }

    return filtered;
  }

  /// ======================================
  /// 🔥 HITUNG LAPORAN LENGKAP SESUAI SCHEMA
  /// ======================================
  Future<SalesReportModel> hitungLaporan(
      List<Map<String, dynamic>> transaksi) async {

    double totalPendapatan = 0;
    double totalModal = 0;
    double totalDiskon = 0;
    double totalDiskonItem = 0;
    int totalItem = 0;

   for (var trx in transaksi) {
  final trxId = trx['id'];

  // total penjualan setelah diskon transaksi
  totalPendapatan += double.parse(trx['total'].toString());

  // ambil detail transaksi
  final details = await fetchDetail(trxId);

  for (var d in details) {
    final qty = (d['qty'] as num?)?.toInt() ?? 0;  
    totalItem += qty;

    final modal = double.parse(d['harga_modal'].toString());
    final hargaJual = double.parse(d['harga_jual'].toString());

    // subtotal modal
    totalModal += modal * qty;

    // diskon item
    totalDiskonItem += double.parse(d['nilai_diskon_item'].toString());
  }

  // diskon transaksi
  totalDiskon += double.parse(trx['nilai_diskon'].toString());
}


    double totalLaba = totalPendapatan - totalModal;

    double margin = (totalPendapatan == 0)
        ? 0
        : (totalLaba / totalPendapatan) * 100;

    return SalesReportModel(
      totalPendapatan: totalPendapatan,
      totalModal: totalModal,
      totalProfit: totalLaba,
      margin: margin,
      totalItemTerjual: totalItem,
      totalDiskon: totalDiskon + totalDiskonItem,
    );
  }
}
