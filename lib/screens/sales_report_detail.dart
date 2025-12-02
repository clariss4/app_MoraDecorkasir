import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controller/sales_report_controller.dart';
import '../models/sales_report_model.dart';

class ViewReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> allTransactions;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> products;

  const ViewReportPage({
    Key? key,
    required this.allTransactions,
    required this.customers,
    required this.products,
  }) : super(key: key);

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  final SalesReportController _controller = SalesReportController();

  bool _isLoading = false;
  SalesReportModel? _reportData;
  
  List<Map<String, dynamic>> _filteredTransactions = [];
  
  String? _selectedCustomerId;
  String? _selectedProductId;
  String _selectedPeriod = 'monthly';
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    
    try {
      final filtered = _controller.filterTransactions(
        trx: widget.allTransactions,
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
    } catch (e) {
      print('Error applying filters: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  Map<String, double> _getTopProducts() {
    Map<String, double> productSales = {};
    
    for (var trx in _filteredTransactions) {
      final details = trx['detail'] as List?;
      if (details != null) {
        for (var d in details) {
          final prodId = d['id_produk'];
          final qty = (d['qty'] as num?)?.toInt() ?? 0;
          final harga = double.parse(d['harga_jual'].toString());
          final total = qty * harga;
          
          productSales[prodId] = (productSales[prodId] ?? 0) + total;
        }
      }
    }
    
    var sorted = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sorted.take(5));
  }

  List<FlSpot> _getSalesChartData() {
    if (_filteredTransactions.isEmpty) return [];
    
    Map<int, double> dailySales = {};
    
    for (var trx in _filteredTransactions) {
      final date = DateTime.parse(trx['created_at']);
      final day = date.day;
      final total = double.parse(trx['total'].toString());
      
      dailySales[day] = (dailySales[day] ?? 0) + total;
    }
    
    return dailySales.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('View Report',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E2E2E),
        ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Section
                  _buildFilterSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Period Filter
                  _buildPeriodFilter(),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range
                  _buildDateRangeDisplay(),
                  
                  const SizedBox(height: 24),
                  
                  // Report Overview (hanya muncul jika monthly)
                  if (_selectedPeriod == 'monthly') ...[
                    _buildReportOverview(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Sales Chart
                  _buildSalesChart(),
                  
                  const SizedBox(height: 24),
                  
                  // Detail Penjualan
                  _buildDetailPenjualan(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
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
              'Filter',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Pelanggan')),
                ...widget.customers.map((c) => DropdownMenuItem(
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Produk')),
                ...widget.products.map((p) => DropdownMenuItem(
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
              'Periode',
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
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOverview() {
    final topProducts = _getTopProducts();
    String topProductName = 'N/A';
    
    if (topProducts.isNotEmpty) {
      final topId = topProducts.keys.first;
      final product = widget.products.firstWhere(
        (p) => p['id'] == topId,
        orElse: () => {'nama': 'Unknown'},
      );
      topProductName = product['nama'] ?? 'Unknown';
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
              'Report Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                // Total Sales
                Expanded(
                  child: _buildOverviewCard(
                    'Total Sales',
                    _formatCurrency(_reportData?.totalPendapatan ?? 0),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Transactions
                Expanded(
                  child: _buildOverviewCard(
                    'Transactions',
                    '${_filteredTransactions.length}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Top Product
                Expanded(
                  child: _buildOverviewCard(
                    'Top Product',
                    topProductName,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    final chartData = _getSalesChartData();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Penjualan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 250,
              child: chartData.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatCurrency(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: true,
                            color: Colors.blue[700],
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue[700]!.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPenjualan() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detail Penjualan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          
          // Table Header
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 3, child: Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          
          // Table Body
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredTransactions.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final trx = _filteredTransactions[index];
              final date = DateTime.parse(trx['created_at']);
              final details = trx['detail'] as List?;
              
              String productNames = 'N/A';
              if (details != null && details.isNotEmpty) {
                productNames = details.take(2).map((d) {
                  final prodId = d['id_produk'];
                  final product = widget.products.firstWhere(
                    (p) => p['id'] == prodId,
                    orElse: () => {'nama': 'Unknown'},
                  );
                  return product['nama'] ?? 'Unknown';
                }).join(', ');
                
                if (details.length > 2) {
                  productNames += ', ...';
                }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateFormat('dd MMM yyyy').format(date),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        productNames,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatCurrency(double.parse(trx['total'].toString())),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Print PDF segera hadir')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Sales Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 14),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Export PDF segera hadir')),
              );
            },
            icon: const Icon(Icons.file_download),
            label: const Text('Export Report'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
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