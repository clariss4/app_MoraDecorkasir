import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_kasir/controller/product_controller.dart';
import 'package:pos_kasir/providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late ProductController controller;

  DateTime? lastUpdatedDate; // <-- TAMBAHAN

  @override
  void initState() {
    super.initState();
    controller = ProductController(context, setState);
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: Colors.white,
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

          drawer: AppDrawer(
            currentScreen: 'Products',
            onScreenSelected: (screen) {},
          ),

          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchBar(),

                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),
                _kategoriList(),

                const SizedBox(height: 20),

                // ===================== HEADER CHANGES / FILTER =====================
                Text(
                  controller.selectedKategoriId == null
                      ? 'Changes today'
                      : 'Filtered by category - Last changes: ${_formatDate(lastUpdatedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),
                Expanded(child: _produkListArea()),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => controller.showProdukForm(),
            label: const Text('Product', selectionColor: Color(0xFF524a4a)),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }

  // ================== FORMAT TANGGAL ===================
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day}/${date.month}/${date.year}";
  }

  // ================== SEARCH BAR ===================
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xfff7f8fa),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xfff7f8fa)),
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: const InputDecoration(
          hintText: 'Search Product...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ================== KATEGORI ===================
  Widget _kategoriList() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // ======== TOMBOL RESET FILTER ========
          _kategoriButton("All", "all", controller.selectedKategoriId == null),

          // ======== DAFTAR KATEGORI ========
          ...controller.kategoriList.map((kat) {
            bool active = controller.selectedKategoriId == kat['id'];
            return _kategoriButton(kat['nama'], kat['id'], active);
          }).toList(),
        ],
      ),
    );
  }

  Widget _kategoriButton(String label, String id, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: active ? Colors.white : const Color(0xFF6F90B9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF6F90B9) : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextButton(
          onPressed: () {
            setState(() {
              if (id == "all") {
                controller.selectedKategoriId = null; // keluar filter
              } else {
                controller.selectedKategoriId = id; // filter kategori
              }
            });
          },
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF6F90B9) : Colors.white,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ================== PRODUK LIST ===================
  Widget _produkListArea() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Text(
          controller.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final data = controller.filteredProduk;

    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada produk'));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        final produk = data[i];

        // =========== SIMPAN TANGGAL UPDATE TERBARU =============
        if (produk['updated_at'] != null) {
          lastUpdatedDate = DateTime.tryParse(produk['updated_at']);
        }

        final kategoriNama = controller.kategoriList.firstWhere(
          (kat) => kat['id'] == produk['kategori_produk'],
          orElse: () => {'nama': 'Tanpa Kategori'},
        )['nama'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: produk['image_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            produk['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => const Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk['nama'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('Kategori: $kategoriNama'),
                      Text('Stok: ${produk['stok']}'),
                      Text(
                        'Modal: Rp${controller.formatRupiah(produk['harga_modal'])}',
                      ),
                      Text(
                        'Jual: Rp${controller.formatRupiah(produk['harga_jual'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    top: 65,
                  ), // jarak turun ke bawah
                  child: Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.edit,
                          color: Color(0xFF6F90B9),
                          size: 18,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(color: Color(0xFF6F90B9)),
                        ),
                        onPressed: () => controller.showProdukForm(produk),
                      ),
                      const SizedBox(width: 2), // jarak antar tombol
                      TextButton.icon(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => controller.deleteProduk(produk['id']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
