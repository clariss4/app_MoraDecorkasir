import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_screen.dart';
// import '../screens/customer_screen.dart'; // nanti buat
// import '../screens/sales_report_screen.dart'; // nanti buat
// import '../screens/stock_screen.dart'; // nanti buat
// import '../screens/cashier_screen.dart'; // nanti buat

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final String currentScreen; // untuk highlight di drawer

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
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
      drawer: _buildDrawer(context, currentScreen),
      body: body,
    );
  }

  Widget _buildDrawer(BuildContext context, String currentScreen) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Profil (dummy — nanti bisa diambil dari auth)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFF6F90B9)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: const Icon(
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
                      const Text(
                        'Hannie Pham',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'hann1pham@gmail.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: 099786435634738',
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
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(
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

          // Menu Items
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            screenName: 'Dashboard',
            currentScreen: currentScreen,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.inventory_2,
            title: 'Products',
            screenName: 'Products',
            currentScreen: currentScreen,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProductScreen()),
            ),
          ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.people,
          //   title: 'Customer',
          //   screenName: 'Customer',
          //   currentScreen: currentScreen,
          //   onTap: () => Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => const CustomerScreen()),
          //   ),
          // ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.bar_chart,
          //   title: 'Sales Report',
          //   screenName: 'Sales Report',
          //   currentScreen: currentScreen,
          //   onTap: () => Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => const SalesReportScreen()),
          //   ),
          // ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.warehouse,
          //   title: 'Stock',
          //   screenName: 'Stock',
          //   currentScreen: currentScreen,
          //   onTap: () => Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => const StockScreen()),
          //   ),
          // ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.point_of_sale,
          //   title: 'Cashier',
          //   screenName: 'Cashier',
          //   currentScreen: currentScreen,
          //   onTap: () => Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => const CashierScreen()),
          //   ),
          // ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            screenName: 'Settings',
            currentScreen: currentScreen,
            onTap: () {
              // TODO: Navigate to Settings Screen
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Settings clicked')));
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            screenName: 'Logout',
            currentScreen: currentScreen,
            isLogout: true,
            onTap: () {
              // TODO: Logout logic
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String screenName,
    required String currentScreen,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    bool isActive = currentScreen == screenName;

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
