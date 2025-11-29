class Produk {
  final String id;
  final String? createdBy;
  final String nama;
  final String? deskripsi;
  final int stok;
  final double hargaModal;
  final double hargaJual;
  final DateTime createdAt;
  final String? kategoriProdukId; // 👈 ini UUID ke tabel kategori
  final String? kategoriNama; // 👈 tambahan: untuk tampilan (opsional)

  Produk({
    required this.id,
    this.createdBy,
    required this.nama,
    this.deskripsi,
    required this.stok,
    required this.hargaModal,
    required this.hargaJual,
    required this.createdAt,
    this.kategoriProdukId, // UUID
    this.kategoriNama, // Nama kategori (untuk UI)
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
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      kategoriProdukId: map['kategori_produk'], // UUID
      kategoriNama: map['kategori_nama'], // Jika pakai JOIN
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'stok': stok,
      'harga_modal': hargaModal,
      'harga_jual': hargaJual,
      'kategori_produk': kategoriProdukId, // UUID
    };
  }
}
