import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ TAMBAHKAN INI
import 'package:pos_kasir/screens/dashboard_screen.dart';
import 'package:pos_kasir/screens/product_screen.dart';
import 'package:pos_kasir/screens/purchease_history_screen.dart';
import 'package:pos_kasir/screens/splash_screen.dart';
import '../providers/auth_provider.dart'; // ✅ TAMBAHKAN INI
import '../services/database_service.dart';
import '../utils/user_helper.dart'; // ✅ JIKA ADA

class CustomerScreen extends ConsumerStatefulWidget {
  // ✅ UBAH JADI ConsumerStatefulWidget
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  // ✅ ConsumerState
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kontakController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  List<Map<String, dynamic>> _pelangganList = [];
  List<Map<String, dynamic>> _filteredPelanggan = [];
  bool _isLoading = true;
  String currentScreen = 'Customer'; // ✅ TAMBAHKAN INI

  @override
  void initState() {
    super.initState();
    _loadPelanggan();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadPelanggan() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService().searchCustomers(null);
      if (mounted) {
        setState(() {
          _pelangganList = data;
          _filteredPelanggan = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data pelanggan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _loadSearchedPelanggan(query.isEmpty ? null : query);
  }

  Future<void> _loadSearchedPelanggan(String? query) async {
    try {
      final data = await DatabaseService().searchCustomers(query);
      if (mounted) {
        setState(() {
          _filteredPelanggan = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saat mencari: $e')));
      }
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? pelanggan}) {
    _namaController.text = pelanggan?['nama'] ?? '';
    _kontakController.text = pelanggan?['kontak'] ?? '';
    _alamatController.text = pelanggan?['alamat'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama *'),
              ),
              TextField(
                controller: _kontakController,
                decoration: const InputDecoration(
                  labelText: 'Kontak (Opsional)',
                ),
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat (Opsional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final nama = _namaController.text.trim();
                    if (nama.isEmpty) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama wajib diisi')),
                        );
                      }
                      return;
                    }

                    final data = <String, dynamic>{'nama': nama};
                    if (_kontakController.text.trim().isNotEmpty) {
                      data['kontak'] = _kontakController.text.trim();
                    }
                    if (_alamatController.text.trim().isNotEmpty) {
                      data['alamat'] = _alamatController.text.trim();
                    }

                    try {
                      if (pelanggan == null) {
                        await DatabaseService().addCustomer(data);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pelanggan berhasil ditambahkan'),
                            ),
                          );
                        }
                      } else {
                        await DatabaseService().updateCustomer(
                          pelanggan['id'],
                          data,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data pelanggan diperbarui'),
                            ),
                          );
                        }
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        await _loadPelanggan();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: Text(
                    pelanggan == null ? 'Tambah Pelanggan' : 'Simpan Perubahan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCustomerTapped(Map<String, dynamic> pelanggan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseHistoryScreen(
          customerId: pelanggan['id'],
          customerName: pelanggan['nama'] as String,
        ),
      ),
    );
  }

  // ====== TAMBAHKAN SEMUA METHOD DARI DASHBOARD =======

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

  Widget _buildDrawer(WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserProfile(currentUser?.id),
        builder: (context, snapshot) {
          final userProfile = snapshot.data;
          final userRole =
              userProfile?['role'] ?? getUserRoleFromEmail(currentUser?.email);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Header Profil dengan layout baru
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF6F90B9)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto Profil di kiri
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
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: const Color(0xFF6F90B9),
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: const Color(0xFF6F90B9),
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Info pengguna di kanan (vertikal)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Pengguna
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
                          // Email
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
                          // ID
                          Text(
                            'ID: ${currentUser?.id?.substring(0, 8) ?? 'Unknown'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Status Pengguna
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

              // === Menu Items Baru (DIPERBAIKI) ===
              _buildDrawerItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                isActive: currentScreen == 'Dashboard',
              ),
              _buildDrawerItem(
                icon: Icons.inventory_2,
                title: 'Products',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductScreen(),
                    ),
                  );
                },
                isActive: currentScreen == 'Products',
              ),
              _buildDrawerItem(
                icon: Icons.people,
                title: 'Customer',
                onTap: () {
                  Navigator.pop(context);
                  // Sudah di halaman Customer, tidak perlu navigasi
                },
                isActive: currentScreen == 'Customer',
              ),
              _buildDrawerItem(
                icon: Icons.bar_chart,
                title: 'Sales Report',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Sales Report')),
                        body: const Center(child: Text('Halaman Sales Report')),
                      ),
                    ),
                  );
                },
                isActive: currentScreen == 'Sales Report',
              ),
              _buildDrawerItem(
                icon: Icons.warehouse,
                title: 'Stock',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Stock')),
                        body: const Center(child: Text('Halaman Stock')),
                      ),
                    ),
                  );
                },
                isActive: currentScreen == 'Stock',
              ),
              _buildDrawerItem(
                icon: Icons.point_of_sale,
                title: 'Cashier',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Cashier')),
                        body: const Center(child: Text('Halaman Cashier')),
                      ),
                    ),
                  );
                },
                isActive: currentScreen == 'Cashier',
              ),
              const SizedBox(height: 16),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Settings')),
                        body: const Center(child: Text('Halaman Settings')),
                      ),
                    ),
                  );
                },
                isActive: currentScreen == 'Settings',
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () {
                  _logout(ref);
                  Navigator.pop(context);
                },
                isLogout: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isActive = false,
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _namaController.dispose();
    _kontakController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ GANTI JADI Scaffold biasa (bukan BaseScreen)
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pelanggan',
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
      drawer: _buildDrawer(ref), // ✅ GUNAKAN DRAWER DARI DASHBOARD
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari pelanggan berdasarkan nama...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'add_customer_fab',
                  mini: true,
                  child: const Icon(Icons.add),
                  onPressed: () => _showAddEditDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPelanggan.isEmpty
                ? const Center(child: Text('Tidak ada pelanggan ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPelanggan.length,
                    itemBuilder: (context, index) {
                      final p = _filteredPelanggan[index];
                      final nama = p['nama'] as String;
                      final initial = nama.isNotEmpty
                          ? nama[0].toUpperCase()
                          : '?';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () => _onCustomerTapped(p),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            child: Text(initial),
                          ),
                          title: Text(nama),
                          subtitle: const Text(
                            'Status: Aktif',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showAddEditDialog(pelanggan: p),
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
