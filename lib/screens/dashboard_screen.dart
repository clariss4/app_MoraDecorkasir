import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_kasir/screens/product_screen.dart';
import 'package:pos_kasir/screens/customer_screen.dart';
import 'package:pos_kasir/screens/splash_screen.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/user_helper.dart';

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

  String currentScreen = 'Dashboard'; // default: dashboard

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

  Future<void> _logout(WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Logout error: $e');
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
            onPressed: () {},
          ),
        ],
      ),
      drawer: Consumer(builder: (context, ref, child) => _buildDrawer(ref)),
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
                onTap: () => Navigator.pop(context),
                isActive: currentScreen == 'Dashboard',
              ),
              _buildDrawerItem(
                icon: Icons.inventory_2,
                title: 'Products',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentScreen = 'Products'; // ✅ dikoreksi
                  });
                  Navigator.push(
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerScreen(),
                    ),
                  );
                },
                isActive: currentScreen == 'Customer',
              ),
              _buildDrawerItem(
                icon: Icons.bar_chart,
                title: 'Sales Report',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentScreen = 'Sales Report';
                  });
                  // TODO: Ganti dengan SalesReportScreen()
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
                  setState(() {
                    currentScreen = 'Stock';
                  });
                  // TODO: Ganti dengan StockScreen()
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
                  setState(() {
                    currentScreen = 'Cashier';
                  });
                  // TODO: Ganti dengan CashierScreen()
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
                  setState(() {
                    currentScreen = 'Settings';
                  });
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

  // Method untuk mengambil data profil dari Supabase
  Future<Map<String, dynamic>?> _getUserProfile(String? userId) async {
    if (userId == null) return null;

    try {
      final databaseService = DatabaseService();
      final profile = await databaseService.getUserProfile(userId);
      return profile;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ✅ DIPERBARUI: _buildDrawerItem dengan desain baru
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap, // ✅ langsung lempar ke handler luar
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
  // ========================
  // Bagian BODY tetap sama
  // ========================

  Widget _buildRecentTransactionsTool() {
    return Container(
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
          Container(
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF7092ba),
              size: 60,
            ),
          ),
        ],
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
    return Container(
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.people,
                color: Color(0xFF2e2e2e),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalProductStockTool() {
    return Container(
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.inventory,
                color: Color(0xFF2e2e2e),
                size: 40,
              ),
            ),
          ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

    return Container(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
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
            child: Container(
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
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: const BorderRadius.only(
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
