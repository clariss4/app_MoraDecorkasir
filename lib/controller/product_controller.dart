import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../utils/user_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProductController {
  final BuildContext context;
  final void Function(VoidCallback fn) setState;

  ProductController(this.context, this.setState);

  // State
  final TextEditingController searchController = TextEditingController();
  String? selectedKategoriId;
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> kategoriList = [];
  bool isLoading = true;
  String? error;
  
  final ImagePicker _picker = ImagePicker();
  Uint8List? selectedImageBytes;
  String? selectedImageName;
  String? currentImageUrl;

  // Validation error messages
  String? imageError;
  String? namaError;
  String? stokError;
  String? hargaModalError;
  String? hargaJualError;
  String? kategoriError;

  // ====================== LOAD DATA ======================
  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final databaseService = DatabaseService();

      final kategoriResponse = await databaseService.getKategori();
      final produkResponse = await databaseService.getProducts();

      setState(() {
        kategoriList = kategoriResponse;
        produkList = produkResponse;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat data: $e';
        isLoading = false;
      });
    }
  }

  // ================== FILTER PRODUK ===================
  List<Map<String, dynamic>> get filteredProduk {
    return produkList.where((produk) {
      final nama = produk['nama'] as String? ?? '';
      final matchesSearch =
          nama.toLowerCase().contains(searchController.text.toLowerCase());

      final matchesKategori =
          selectedKategoriId == null ||
          produk['kategori_produk'] == selectedKategoriId;

      return matchesSearch && matchesKategori;
    }).toList();
  }

  // ================== GROUP PRODUK BY DATE ===================
  Map<String, List<Map<String, dynamic>>> groupProdukByDate() {
    final filtered = filteredProduk;
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var produk in filtered) {
      final updatedAt = produk['updated_at'] != null 
          ? DateTime.tryParse(produk['updated_at']) 
          : produk['created_at'] != null
              ? DateTime.tryParse(produk['created_at'])
              : null;

      if (updatedAt != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(updatedAt);
        
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(produk);
      }
    }

    // Sort by date descending (newest first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final sortedMap = <String, List<Map<String, dynamic>>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  // ================== FORMAT DATE LABEL ===================
  String formatDateLabel(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else {
        // Format: Senin, 2 Desember 2024
        final dayName = _getDayName(date.weekday);
        final monthName = _getMonthName(date.month);
        return '$dayName, ${date.day} $monthName ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  // ================== SNACKBAR ===================
  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ================== PICK IMAGE ===================
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImageBytes = bytes;
          selectedImageName = image.name;
          imageError = null;
        });
      }
    } catch (e) {
      showSnackbar('Gagal memilih gambar: $e', isError: true);
    }
  }

  // ================== VALIDATION METHODS ===================
  void validateNama(String value, Function(void Function()) setDialogState) {
    setDialogState(() {
      if (value.trim().isEmpty) {
        namaError = 'Nama produk harus diisi';
      } else {
        namaError = null;
      }
    });
  }

  void validateStok(String value, Function(void Function()) setDialogState) {
    setDialogState(() {
      if (value.isEmpty) {
        stokError = 'Stok harus diisi';
      } else if (int.tryParse(value) == null) {
        stokError = 'Stok harus berupa angka';
      } else if (int.parse(value) < 0) {
        stokError = 'Stok tidak boleh negatif';
      } else {
        stokError = null;
      }
    });
  }

  void validateHargaModal(String value, Function(void Function()) setDialogState) {
    setDialogState(() {
      if (value.isEmpty) {
        hargaModalError = 'Harga modal harus diisi';
      } else if (double.tryParse(value) == null) {
        hargaModalError = 'Harga modal harus berupa angka';
      } else if (double.parse(value) < 0) {
        hargaModalError = 'Harga modal tidak boleh negatif';
      } else {
        hargaModalError = null;
      }
    });
  }

  void validateHargaJual(String value, String hargaModalValue, Function(void Function()) setDialogState) {
    setDialogState(() {
      if (value.isEmpty) {
        hargaJualError = 'Harga jual harus diisi';
      } else if (double.tryParse(value) == null) {
        hargaJualError = 'Harga jual harus berupa angka';
      } else if (double.parse(value) < 0) {
        hargaJualError = 'Harga jual tidak boleh negatif';
      } else if (hargaModalValue.isNotEmpty && 
                 double.tryParse(hargaModalValue) != null &&
                 double.parse(value) < double.parse(hargaModalValue)) {
        hargaJualError = 'Harga jual tidak boleh lebih kecil dari harga modal';
      } else {
        hargaJualError = null;
      }
    });
  }

  void validateKategori(String? value, Function(void Function()) setDialogState) {
    setDialogState(() {
      if (value == null) {
        kategoriError = 'Kategori harus dipilih';
      } else {
        kategoriError = null;
      }
    });
  }

  void validateImage(Function(void Function()) setDialogState) {
    setDialogState(() {
      if (selectedImageBytes == null && (currentImageUrl == null || currentImageUrl!.isEmpty)) {
        imageError = 'Gambar produk harus dicantumkan';
      } else {
        imageError = null;
      }
    });
  }

  void resetValidationErrors() {
    imageError = null;
    namaError = null;
    stokError = null;
    hargaModalError = null;
    hargaJualError = null;
    kategoriError = null;
  }

  // =============================================================
  // ==================== FORM PRODUK ============================
  // =============================================================
  Future<void> showProdukForm([Map<String, dynamic>? existingProduk]) async {
    selectedImageBytes = null;
    selectedImageName = null;
    currentImageUrl = existingProduk?['image_url'];
    
    resetValidationErrors();

    final TextEditingController namaController =
        TextEditingController(text: existingProduk?['nama'] ?? '');

    final TextEditingController deskripsiController =
        TextEditingController(text: existingProduk?['deskripsi'] ?? '');

    final TextEditingController stokController = TextEditingController(
      text: existingProduk?['stok']?.toString() ?? '',
    );

    final TextEditingController hargaModalController = TextEditingController(
      text: existingProduk?['harga_modal']?.toString() ?? '',
    );

    final TextEditingController hargaJualController = TextEditingController(
      text: existingProduk?['harga_jual']?.toString() ?? '',
    );

    String? localSelectedKategori = existingProduk?['kategori_produk'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingProduk == null ? 'Tambah Produk' : 'Edit Produk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                        setDialogState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: imageError != null ? Colors.red : Colors.grey[400]!,
                            width: imageError != null ? 2 : 1,
                          ),
                        ),
                        child: selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : currentImageUrl != null && currentImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Klik untuk pilih gambar', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                      ),
                    ),
                    
                    if (imageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          imageError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    if (selectedImageBytes != null || currentImageUrl != null)
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            selectedImageBytes = null;
                            selectedImageName = null;
                            currentImageUrl = null;
                            imageError = 'Gambar produk harus dicantumkan';
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Produk *',
                        errorText: namaError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => validateNama(value, setDialogState),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: deskripsiController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: stokController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok *',
                        errorText: stokError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => validateStok(value, setDialogState),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: hargaModalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Modal (Rp) *',
                        errorText: hargaModalError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        validateHargaModal(value, setDialogState);
                        if (hargaJualController.text.isNotEmpty) {
                          validateHargaJual(hargaJualController.text, value, setDialogState);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: hargaJualController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Jual (Rp) *',
                        errorText: hargaJualError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => validateHargaJual(value, hargaModalController.text, setDialogState),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: localSelectedKategori,
                      hint: const Text('Pilih Kategori'),
                      items: kategoriList.map((kat) {
                        return DropdownMenuItem(
                          value: kat['id'] as String,
                          child: Text(kat['nama'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        localSelectedKategori = value;
                        validateKategori(value, setDialogState);
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategori *',
                        errorText: kategoriError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    resetValidationErrors();
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    bool hasError = false;

                    if (selectedImageBytes == null && (currentImageUrl == null || currentImageUrl!.isEmpty)) {
                      validateImage(setDialogState);
                      hasError = true;
                    }

                    if (namaController.text.trim().isEmpty) {
                      validateNama(namaController.text, setDialogState);
                      hasError = true;
                    }

                    if (stokController.text.isEmpty || int.tryParse(stokController.text) == null) {
                      validateStok(stokController.text, setDialogState);
                      hasError = true;
                    }

                    if (hargaModalController.text.isEmpty || double.tryParse(hargaModalController.text) == null) {
                      validateHargaModal(hargaModalController.text, setDialogState);
                      hasError = true;
                    }

                    if (hargaJualController.text.isEmpty || double.tryParse(hargaJualController.text) == null) {
                      validateHargaJual(hargaJualController.text, hargaModalController.text, setDialogState);
                      hasError = true;
                    } else if (hargaModalController.text.isNotEmpty && 
                               double.tryParse(hargaModalController.text) != null &&
                               double.parse(hargaJualController.text) < double.parse(hargaModalController.text)) {
                      validateHargaJual(hargaJualController.text, hargaModalController.text, setDialogState);
                      hasError = true;
                    }

                    if (localSelectedKategori == null) {
                      validateKategori(localSelectedKategori, setDialogState);
                      hasError = true;
                    }

                    if (hasError || namaError != null || stokError != null || 
                        hargaModalError != null || hargaJualError != null || 
                        kategoriError != null || imageError != null) {
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final db = DatabaseService();
                      String? imageUrl = currentImageUrl;

                      if (selectedImageBytes != null) {
                        if (existingProduk != null && existingProduk['image_url'] != null) {
                          await db.deleteProductImage(existingProduk['image_url']);
                        }

                        final productId = existingProduk?['id'] ??
                            DateTime.now().millisecondsSinceEpoch.toString();

                        imageUrl = await db.uploadProductImageBytes(
                          selectedImageBytes!,
                          productId,
                          selectedImageName ?? 'image.jpg',
                        );
                      }

                      final data = {
                        'nama': namaController.text.trim(),
                        'deskripsi': deskripsiController.text.trim(),
                        'stok': int.parse(stokController.text),
                        'harga_modal': double.parse(hargaModalController.text),
                        'harga_jual': double.parse(hargaJualController.text),
                        'kategori_produk': localSelectedKategori,
                        'image_url': imageUrl,
                        'updated_at': DateTime.now().toIso8601String(),
                      };

                      if (existingProduk == null) {
                        await db.addProduct(data);
                        showSnackbar('Produk berhasil ditambahkan!');
                      } else {
                        await db.updateProduct(existingProduk['id'], data);
                        showSnackbar('Produk berhasil diperbarui!');
                      }

                      await loadData();

                      Navigator.pop(context);
                      Navigator.pop(context);

                    } catch (e) {
                      Navigator.pop(context);
                      showSnackbar('Gagal menyimpan: $e', isError: true);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================== HAPUS PRODUK ===================
  Future<void> deleteProduk(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final db = DatabaseService();
        final product = produkList.firstWhere((p) => p['id'] == id, orElse: () => {});

        if (product['image_url'] != null) {
          await db.deleteProductImage(product['image_url']);
        }

        await db.deleteProduct(id);
        showSnackbar('Produk berhasil dihapus!');
        await loadData();
      } catch (e) {
        showSnackbar('Gagal menghapus: $e', isError: true);
      }
    }
  }

  // ================== PROFILE ===================
  Future<Map<String, dynamic>?> getUserProfile(String? userId) async {
    if (userId == null) return null;
    try {
      return await DatabaseService().getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  // ================== LOGOUT ===================
  Future<void> logout(WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // ================== FORMAT RUPIAH ===================
  String formatRupiah(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return formatted;
  }
}