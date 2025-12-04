import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_kasir/screens/Product_stock_screen.dart';
import 'package:pos_kasir/screens/Transaction_screen.dart';
import 'package:pos_kasir/screens/notifikasi_screen';
import 'package:pos_kasir/screens/product_screen.dart';
import 'package:pos_kasir/screens/customer_screen.dart';
import 'package:pos_kasir/screens/splash_screen.dart';
import 'package:pos_kasir/screens/total_customer_screen.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/user_helper.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedRevenueFilter = 'Weekly';
  Map<String, dynamic> _dashboardStats = {
    'recentTransactions': 0,
    'totalCustomers': 0,
    'totalProducts': 0,
  };
  bool _isLoading = true;

  String currentScreen = 'Dashboard'; // default screen

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final databaseService = DatabaseService();
      final stats = await databaseService.getDashboardStats();
      setState(() {
        _dashboardStats = {
          'recentTransactions': 90,
          'totalCustomers': 150,
          'totalProducts': 4350,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _dashboardStats = {
          'recentTransactions': 90,
          'totalCustomers': 150,
          'totalProducts': 4350,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            },
          ),
        ],
      ),
      // Kurang lebih nanti prompt e iku :
      // Buat pemanggilan navbar sama seperti DashboardScreen, yaitu memanggil AppDrawer dari app_drawer.dart
      //
      drawer: AppDrawer(
        currentScreen: currentScreen,
        onScreenSelected: (screen) {
          setState(() {
            currentScreen = screen;
          });
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRecentTransactionsTool(),
                  const SizedBox(height: 24),
                  _buildToolsSection(),
                  const SizedBox(height: 24),
                  _buildRevenueSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildRecentTransactionsTool() {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RecentTransactionScreen(),
        ),
      );
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFb2d6f7), Color(0xFFd4eaff)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_dashboardStats['recentTransactions']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7092ba),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'List of recent transactions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7092ba),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF7092ba),
            size: 60,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildToolsSection() {
    return Row(
      children: [
        Expanded(child: _buildTotalCustomerTool()),
        const SizedBox(width: 12),
        Expanded(child: _buildTotalProductStockTool()),
      ],
    );
  }

 Widget _buildTotalCustomerTool() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TotalCustomerScreen(),
        ),
      );
    },
    child: Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_dashboardStats['totalCustomers']}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2e2e2e),
                ),
              ),
              const Text(
                'Total Customer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2e2e2e),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.people, color: Color(0xFF2e2e2e), size: 40),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTotalProductStockTool() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductStockScreen(),
        ),
      );
    },
    child: Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_dashboardStats['totalProducts']}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2e2e2e),
                ),
              ),
              const Text(
                'Total Product Stock',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2e2e2e),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: Icon(Icons.inventory, color: Color(0xFF2e2e2e), size: 40),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildRevenueSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 213, 211, 211),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterButton('Monthly', 0),
                    _buildFilterButton('Weekly', 1),
                    _buildFilterButton('Today', 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildChart(),
          const SizedBox(height: 8),
          _buildChartLabels(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getFooterText(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    bool isActive = _selectedRevenueFilter == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedRevenueFilter = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFF2E2E2E),
          borderRadius: _getBorderRadius(index),
          border: Border.all(color: const Color(0xFFd9d9d9)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF2E2E2E) : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index) {
    switch (index) {
      case 0:
        return const BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
        );
      case 1:
        return BorderRadius.zero;
      case 2:
        return const BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        );
      default:
        return BorderRadius.zero;
    }
  }

  Widget _buildChart() {
    List<double> data = _getChartData();
    final double maxValue = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${maxValue.toInt()}', style: _chartLabelStyle()),
                Text('${(maxValue * 0.8).toInt()}', style: _chartLabelStyle()),
                Text('${(maxValue * 0.6).toInt()}', style: _chartLabelStyle()),
                Text('${(maxValue * 0.4).toInt()}', style: _chartLabelStyle()),
                Text('${(maxValue * 0.2).toInt()}', style: _chartLabelStyle()),
                Text('0', style: _chartLabelStyle()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 180,
              child: _selectedRevenueFilter == 'Today'
                  ? _buildBarChart(data, maxValue)
                  : _buildLineChart(data, maxValue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> data, double maxValue) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        data.length,
        (index) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 16,
              height: (data[index] / maxValue) * 160,
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> data, double maxValue) {
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: LineChartPainter(data: data, maxValue: maxValue),
    );
  }

  Widget _buildChartLabels() {
    List<String> labels = _getChartLabels();
    return Row(
      children: [
        const SizedBox(width: 38),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: labels
                .map(
                  (label) => Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<double> _getChartData() {
    switch (_selectedRevenueFilter) {
      case 'Monthly':
        return [30, 50, 70, 90, 80, 60, 40, 70, 85, 95, 75, 65];
      case 'Today':
        return [10, 25, 45, 65, 85, 70, 50, 35, 60, 80, 90, 75];
      case 'Weekly':
      default:
        return [20, 40, 60, 80, 100, 60, 40];
    }
  }

  List<String> _getChartLabels() {
    switch (_selectedRevenueFilter) {
      case 'Monthly':
        return ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      case 'Today':
        return [
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13',
          '14',
          '15',
          '16',
          '17',
        ];
      case 'Weekly':
      default:
        return ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    }
  }

  String _getFooterText() {
    switch (_selectedRevenueFilter) {
      case 'Monthly':
        return '- 2024';
      case 'Today':
        return '- 15 APR';
      case 'Weekly':
      default:
        return '- APR';
    }
  }

  TextStyle _chartLabelStyle() {
    return TextStyle(
      color: Colors.grey.shade600,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double maxValue;

  LineChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.fill;

    final path = Path();

    double xStep = size.width / (data.length - 1);
    double yScale = size.height / maxValue;

    for (int i = 0; i < data.length; i++) {
      double x = i * xStep;
      double y = size.height - (data[i] * yScale);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
