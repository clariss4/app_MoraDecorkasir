import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pos_kasir/controller/customer_controller.dart';
import '../widgets/app_drawer.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final supabase = Supabase.instance.client;
  late final CustomerController _controller;

  List<Map<String, dynamic>> _pelanggan = [];
  List<Map<String, dynamic>> _filteredPelanggan = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = CustomerController(supabase: supabase);
    _fetchPelanggan();

    _searchController.addListener(() {
      _filterSearch();
    });
  }

  Future<void> _fetchPelanggan() async {
    setState(() => _isLoading = true);
    _pelanggan = await _controller.fetchCustomers();
    _filteredPelanggan = _pelanggan;
    setState(() => _isLoading = false);
  }

  void _filterSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPelanggan = _pelanggan.where((item) {
        final nama = item['nama']?.toString().toLowerCase() ?? '';
        return nama.contains(query);
      }).toList();
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? pelanggan}) {
    final bool isEdit = pelanggan != null;

    final TextEditingController namaController = TextEditingController(
      text: pelanggan?['nama'] ?? '',
    );
    final TextEditingController kontakController = TextEditingController(
      text: pelanggan?['kontak'] ?? '',
    );
    final TextEditingController alamatController = TextEditingController(
      text: pelanggan?['alamat'] ?? '',
    );
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: kontakController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Masukkan nomor telepon (12 digit)',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Nomor telepon wajib diisi";
                    if (!RegExp(r'^[0-9]+$').hasMatch(value))
                      return "Nomor telepon harus angka";
                    if (value.length != 12)
                      return "Nomor telepon harus 12 digit";
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Alamat wajib diisi";
                    return null;
                  },
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
                if (_formKey.currentState!.validate()) {
                  final nama = namaController.text.trim();
                  final kontak = kontakController.text.trim();
                  final alamat = alamatController.text.trim();

                  if (isEdit) {
                    await _controller.updateCustomer(
                      id: pelanggan!['id'],
                      nama: nama,
                      kontak: kontak,
                      alamat: alamat,
                    );
                  } else {
                    await _controller.addCustomer(
                      nama: nama,
                      kontak: kontak,
                      alamat: alamat,
                    );
                  }

                  Navigator.pop(context);
                  _fetchPelanggan();
                }
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _onCustomerTapped(Map<String, dynamic> pelanggan) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // Gunakan dialogContext
        title: const Text("Detail Pelanggan"),
        content: Text(
          "Nama: ${pelanggan['nama']}\n"
          "Kontak: ${pelanggan['kontak']}\n"
          "Alamat: ${pelanggan['alamat']}",
        ),
        actions: [
          TextButton(
            child: const Text("Tutup"),
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(), // Gunakan dialogContext.pop()
          ),
        ],
      ),
    );
  }

  // Hapus pelanggan
  Future<void> _deleteCustomer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus pelanggan ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          ElevatedButton(
            child: const Text("Hapus"),
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteCustomer(id);
      _fetchPelanggan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      drawer: AppDrawer(
        currentScreen: 'Customer',
        onScreenSelected: (screen) {},
      ),
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
                      hintText: 'Cari pelanggan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: 'add_customer',
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
                ? const Center(child: Text('Tidak ada pelanggan'))
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _showAddEditDialog(pelanggan: p),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCustomer(p['id']),
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
    );
  }
}
