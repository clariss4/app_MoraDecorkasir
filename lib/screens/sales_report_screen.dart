import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_kasir/screens/sales_report_detail.dart';
import 'package:pos_kasir/widgets/app_drawer.dart';
import '../controller/sales_report_controller.dart';
import '../models/sales_report_model.dart';
import '../services/database_service.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final SalesReportController _controller = SalesReportController();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = true;
  SalesReportModel? _reportData;
  
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _products = [];
  
  String? _selectedCustomerId;
  String? _selectedProductId;
  String _selectedPeriod = 'daily';
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      final transactions = await _controller.fetchTransactions();
      final customers = await _db.getCustomers();
      final products = await _db.getProducts();
      
      // Load detail untuk setiap transaksi
      for (var trx in transactions) {
        final details = await _controller.fetchDetail(trx['id']);
        trx['detail'] = details;
      }
      
      setState(() {
        _allTransactions = transactions;
        _customers = customers;
        _products = products;
      });
      
      await _applyFilters();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyFilters() async {
    final filtered = _controller.filterTransactions(
      trx: _allTransactions,
      startDate: _startDate,
      endDate: _endDate,
      produkId: _selectedProductId,
      pelangganId: _selectedCustomerId,
      periode: _selectedPeriod,
    );
    
    final report = await _controller.hitungLaporan(filtered);
    
    setState(() {
      _filteredTransactions = filtered;
      _reportData = report;
    });
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Report',
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


      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3 Summary Cards
                  _buildSummaryCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Filter Section
                  _buildFilterSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Period Filter
                  _buildPeriodFilter(),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range Display
                  _buildDateRangeDisplay(),
                  
                  const SizedBox(height: 16),
                  
                  // View Report Button
                  _buildViewReportButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Summary
                  _buildQuickSummary(),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Pendapatan',
                _formatCurrency(_reportData?.totalPendapatan ?? 0),
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Profit',
                _formatCurrency(_reportData?.totalProfit ?? 0),
                Icons.trending_up,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Item Terjual',
          '${_reportData?.totalItemTerjual ?? 0} items',
          Icons.shopping_cart,
          Colors.orange,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (isFullWidth) const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isFullWidth ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            
            // Customer Filter
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              decoration: InputDecoration(
                labelText: 'Pelanggan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Pelanggan')),
                ..._customers.map((c) => DropdownMenuItem(
                      value: c['id'],
                      child: Text(c['nama'] ?? 'Unknown'),
                    )),
              ],
              onChanged: (value) async {
                setState(() => _selectedCustomerId = value);
                await _applyFilters();
              },
            ),
            
            const SizedBox(height: 12),
            
            // Product Filter
            DropdownButtonFormField<String>(
              value: _selectedProductId,
              decoration: InputDecoration(
                labelText: 'Produk',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Produk')),
                ..._products.map((p) => DropdownMenuItem(
                      value: p['id'],
                      child: Text(p['nama'] ?? 'Unknown'),
                    )),
              ],
              onChanged: (value) async {
                setState(() => _selectedProductId = value);
                await _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Periode Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPeriodChip('Harian', 'daily'),
                const SizedBox(width: 8),
                _buildPeriodChip('Mingguan', 'weekly'),
                const SizedBox(width: 8),
                _buildPeriodChip('Bulanan', 'monthly'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: isSelected,
        onSelected: (selected) async {
          if (selected) {
            setState(() => _selectedPeriod = value);
            await _applyFilters();
          }
        },
        selectedColor: Colors.blue[700],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateRangeDisplay() {
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _startDate != null && _endDate != null
                    ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                    : 'Pilih Rentang Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildViewReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewReportPage(
                allTransactions: _allTransactions,
                customers: _customers,
                products: _products,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Lihat Detail Laporan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuickSummary() {
    // Get top customer
    Map<String, int> customerCount = {};
    for (var trx in _filteredTransactions) {
      final custId = trx['id_pelanggan'];
      if (custId != null) {
        customerCount[custId] = (customerCount[custId] ?? 0) + 1;
      }
    }
    
    String topCustomer = 'N/A';
    if (customerCount.isNotEmpty) {
      final topId = customerCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final cust = _customers.firstWhere((c) => c['id'] == topId, orElse: () => {'nama': 'Unknown'});
      topCustomer = cust['nama'] ?? 'Unknown';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Transaksi', '${_filteredTransactions.length}'),
            _buildSummaryRow('Pelanggan Terbanyak', topCustomer),
            _buildSummaryRow('Total Diskon', _formatCurrency(_reportData?.totalDiskon ?? 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement PDF export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Export PDF segera hadir')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement print
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Print segera hadir')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Share segera hadir')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}