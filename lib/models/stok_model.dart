class StockModel {
  final String id;
  final String nama;
  final int stok;
  final int minStok;
  final String? imageUrl;

  StockModel({
    required this.id,
    required this.nama,
    required this.stok,
    required this.minStok,
    this.imageUrl,
  });

  StockModel copyWith({
    String? id,
    String? nama,
    int? stok,
    int? minStok,
    String? imageUrl,
  }) {
    return StockModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      stok: stok ?? this.stok,
      minStok: minStok ?? this.minStok,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'],
      nama: json['nama'],
      stok: json['stok'] ?? 0,
      minStok: json['min_stok'] ?? 25,
      imageUrl: json['image_url'],
    );
  }
}
