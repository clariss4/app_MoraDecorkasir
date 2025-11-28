class Produk {
  final String id;
  final String? createdBy;
  final String nama;
  final String? deskripsi;
  final int stok;
  final double hargaModal;
  final double hargaJual;
  final DateTime createdAt;
  final String? kategoriProduk;

  Produk({
    required this.id,
    this.createdBy,
    required this.nama,
    this.deskripsi,
    required this.stok,
    required this.hargaModal,
    required this.hargaJual,
    required this.createdAt,
    this.kategoriProduk,
  });

  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] ?? '',
      createdBy: map['created_by'],
      nama: map['nama'] ?? 'No Name',
      deskripsi: map['deskripsi'],
      stok: map['stok'] ?? 0,
      hargaModal: (map['harga_modal'] as num?)?.toDouble() ?? 0.0,
      hargaJual: (map['harga_jual'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      kategoriProduk: map['kategori_produk'],
    );
  }
}
