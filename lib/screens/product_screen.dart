import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_kasir/screens/dashboard_screen.dart';
import 'package:pos_kasir/screens/splash_screen.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/user_helper.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedKategoriId; // null = tampilkan semua
  List<Map<String, dynamic>> _produkList = [];
  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final databaseService = DatabaseService();

      // Ambil kategori dulu
      final kategoriResponse = await databaseService.getKategori();
      // Ambil produk (tanpa JOIN)
      final produkResponse = await databaseService.getProducts();

      setState(() {
        _kategoriList = kategoriResponse;
        _produkList = produkResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProduk {
    return _produkList.where((produk) {
      final nama = produk['nama'] as String? ?? '';
      final matchesSearch = nama.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final matchesKategori =
          _selectedKategoriId == null ||
          produk['kategori_produk'] == _selectedKategoriId;

      return matchesSearch && matchesKategori;
    }).toList();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Popup Form Tambah/Edit Produk
  Future<void> _showProdukForm([Map<String, dynamic>? existingProduk]) async {
    final TextEditingController namaController = TextEditingController(
      text: existingProduk?['nama'] ?? '',
    );
    final TextEditingController deskripsiController = TextEditingController(
      text: existingProduk?['deskripsi'] ?? '',
    );
    final TextEditingController stokController = TextEditingController(
      text: existingProduk?['stok']?.toString() ?? '0',
    );
    final TextEditingController hargaModalController = TextEditingController(
      text: existingProduk?['harga_modal']?.toString() ?? '0',
    );
    final TextEditingController hargaJualController = TextEditingController(
      text: existingProduk?['harga_jual']?.toString() ?? '0',
    );

    String? selectedKategoriId = existingProduk?['kategori_produk'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingProduk == null ? 'Tambah Produk' : 'Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Produk *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stok *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hargaModalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Modal (Rp) *',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hargaJualController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual (Rp) *',
                  ),
                ),
                const SizedBox(height: 12),
                // Dropdown Kategori
                DropdownButtonFormField<String>(
                  value: selectedKategoriId,
                  hint: const Text('Pilih Kategori'),
                  items: _kategoriList.map((kat) {
                    return DropdownMenuItem(
                      value: kat['id'] as String,
                      child: Text(kat['nama'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedKategoriId = value);
                  },
                  decoration: const InputDecoration(labelText: 'Kategori *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validasi
                if (namaController.text.trim().isEmpty ||
                    stokController.text.isEmpty ||
                    hargaModalController.text.isEmpty ||
                    hargaJualController.text.isEmpty ||
                    selectedKategoriId == null) {
                  _showSnackbar(
                    'Harap isi semua field yang wajib!',
                    isError: true,
                  );
                  return;
                }

                final data = {
                  'nama': namaController.text.trim(),
                  'deskripsi': deskripsiController.text.trim(),
                  'stok': int.tryParse(stokController.text) ?? 0,
                  'harga_modal':
                      double.tryParse(hargaModalController.text) ?? 0.0,
                  'harga_jual':
                      double.tryParse(hargaJualController.text) ?? 0.0,
                  'kategori_produk': selectedKategoriId,
                };

                try {
                  final databaseService = DatabaseService();
                  if (existingProduk == null) {
                    await databaseService.addProduct(data);
                    _showSnackbar('Produk berhasil ditambahkan!');
                  } else {
                    await databaseService.updateProduct(
                      existingProduk['id'] as String,
                      data,
                    );
                    _showSnackbar('Produk berhasil diperbarui!');
                  }
                  await _loadData(); // Refresh
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackbar('Gagal menyimpan: $e', isError: true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Hapus Produk
  Future<void> _deleteProduk(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final databaseService = DatabaseService();
        await databaseService.deleteProduct(id);
        _showSnackbar('Produk berhasil dihapus!');
        await _loadData();
      } catch (e) {
        _showSnackbar('Gagal menghapus: $e', isError: true);
      }
    }
  }

  // ===== Drawer dan Navbar =====

  Future<Map<String, dynamic>?> _getUserProfile(String? userId) async {
    if (userId == null) return null;
    try {
      final databaseService = DatabaseService();
      return await databaseService.getUserProfile(userId);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> _logout(WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authService = ref.read(authServiceProvider);
        final currentUser = authService.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Product',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: Color(0xFF2E2E2E)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          drawer: Drawer(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _getUserProfile(currentUser?.id),
              builder: (context, snapshot) {
                final userProfile = snapshot.data;
                final userRole =
                    userProfile?['role'] ??
                    getUserRoleFromEmail(currentUser?.email);

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Header Profil
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Color(0xFF6F90B9)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: userProfile?['image_url'] != null
                                ? ClipOval(
                                    child: Image.network(
                                      userProfile!['image_url'],
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              color: const Color(0xFF6F90B9),
                                              size: 30,
                                            );
                                          },
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Color(0xFF6F90B9),
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProfile?['nama'] ??
                                      currentUser?.email?.split('@').first ??
                                      'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile?['email'] ??
                                      currentUser?.email ??
                                      'user@email.com',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${currentUser?.id?.substring(0, 8) ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    userRole.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    _buildDrawerItem(
                      context,
                      Icons.dashboard,
                      'Dashboard',
                      false,
                      () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.inventory_2,
                      'Products',
                      true,
                      () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.people,
                      'Customer',
                      false,
                      () {
                        Navigator.pop(context);
                        _showSnackbar('Halaman Customer belum tersedia');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.bar_chart,
                      'Sales Report',
                      false,
                      () {
                        Navigator.pop(context);
                        _showSnackbar('Halaman Sales Report belum tersedia');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.warehouse,
                      'Stock',
                      false,
                      () {
                        Navigator.pop(context);
                        _showSnackbar('Halaman Stock belum tersedia');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.point_of_sale,
                      'Cashier',
                      false,
                      () {
                        Navigator.pop(context);
                        _showSnackbar('Halaman Cashier belum tersedia');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDrawerItem(
                      context,
                      Icons.settings,
                      'Settings',
                      false,
                      () {
                        Navigator.pop(context);
                        _showSnackbar('Pengaturan');
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      Icons.logout,
                      'Logout',
                      false,
                      () => _logout(ref),
                      isLogout: true,
                    ),
                  ],
                );
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 20),

                // Kategori
                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _kategoriList.map((kat) {
                      return _buildKategoriButton(
                        kat['nama'] as String,
                        kat['id'] as String,
                        _selectedKategoriId == kat['id'],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Daftar Produk
                const Text(
                  'Changes today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 12),

                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Expanded(
                    child: Center(
                      child: Text(_error!, style: TextStyle(color: Colors.red)),
                    ),
                  )
                else if (_filteredProduk.isEmpty)
                  const Expanded(child: Center(child: Text('Tidak ada produk')))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredProduk.length,
                      itemBuilder: (context, index) {
                        final produk = _filteredProduk[index];
                        // Ambil nama kategori secara manual
                        final kategoriNama =
                            _kategoriList.firstWhere(
                                  (kat) =>
                                      kat['id'] == produk['kategori_produk'],
                                  orElse: () => {'nama': 'Tanpa Kategori'},
                                )['nama']
                                as String;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Placeholder gambar
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produk['nama'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Kategori: $kategoriNama',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stok: ${produk['stok']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Modal: Rp${_formatRupiah(produk['harga_modal'] as double)}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        'Jual: Rp${_formatRupiah(produk['harga_jual'] as double)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    TextButton(
                                      onPressed: () => _showProdukForm(produk),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Color(0xFF6F90B9),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _deleteProduk(produk['id'] as String),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showProdukForm(),
            label: const Text('Product'),
            icon: const Icon(Icons.add),
            backgroundColor: const Color(0xFF6F90B9),
          ),
        );
      },
    );
  }

  // ✅ DIPERBAIKI: Tampilan kategori sesuai permintaan
  Widget _buildKategoriButton(String label, String? id, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 90, // lebar tetap
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFF6F90B9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF6F90B9) : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedKategoriId = id;
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF6F90B9) : Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return formatted;
  }

  // Helper drawer item
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isLogout
              ? const Color(0xFF6F90B9)
              : isActive
              ? const Color(0xFFE3F2FD)
              : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isLogout ? Colors.transparent : Colors.grey.shade200,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout
                  ? Colors.white
                  : isActive
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF6F90B9),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isLogout
                    ? Colors.white
                    : isActive
                    ? const Color(0xFF1976D2)
                    : const Color(0xFF2E2E2E),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (isLogout) const Spacer(),
            if (isLogout) Icon(Icons.logout, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
