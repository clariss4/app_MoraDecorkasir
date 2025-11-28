class Penjualan {
  final String id;
  final String? kasirId;
  final String? idPelanggan;
  final double total;
  final String? catatan;
  final DateTime createdAt;
  final String? idDiskon;
  final double subtotalSebelumDiskon;
  final double nilaiDiskon;

  Penjualan({
    required this.id,
    this.kasirId,
    this.idPelanggan,
    required this.total,
    this.catatan,
    required this.createdAt,
    this.idDiskon,
    required this.subtotalSebelumDiskon,
    required this.nilaiDiskon,
  });

  factory Penjualan.fromMap(Map<String, dynamic> map) {
    return Penjualan(
      id: map['id'] ?? '',
      kasirId: map['kasir_id'],
      idPelanggan: map['id_pelanggan'],
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      catatan: map['catatan'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      idDiskon: map['id_diskon'],
      subtotalSebelumDiskon:
          (map['subtotal_sebelum_diskon'] as num?)?.toDouble() ?? 0.0,
      nilaiDiskon: (map['nilai_diskon'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DetailPenjualan {
  final String id;
  final String? idPenjualan;
  final String? idProduk;
  final int qty;
  final double hargaModal;
  final double hargaJual;
  final double subtotal;
  final DateTime createdAt;

  DetailPenjualan({
    required this.id,
    this.idPenjualan,
    this.idProduk,
    required this.qty,
    required this.hargaModal,
    required this.hargaJual,
    required this.subtotal,
    required this.createdAt,
  });

  factory DetailPenjualan.fromMap(Map<String, dynamic> map) {
    return DetailPenjualan(
      id: map['id'] ?? '',
      idPenjualan: map['id_penjualan'],
      idProduk: map['id_produk'],
      qty: map['qty'] ?? 0,
      hargaModal: (map['harga_modal'] as num?)?.toDouble() ?? 0.0,
      hargaJual: (map['harga_jual'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
