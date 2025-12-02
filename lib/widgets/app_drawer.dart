// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_kasir/screens/cashier_screen.dart';
import 'package:pos_kasir/screens/dashboard_screen.dart';
import 'package:pos_kasir/screens/sales_report_screen.dart';
import 'package:pos_kasir/screens/stock_sceen.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import '../utils/user_helper.dart';
import '../screens/product_screen.dart';
import '../screens/customer_screen.dart';
import '../screens/splash_screen.dart';

class AppDrawer extends StatefulWidget {
  final String currentScreen;
  final Function(String) onScreenSelected;

  const AppDrawer({
    super.key,
    required this.currentScreen,
    required this.onScreenSelected,
  });

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Future<Map<String, dynamic>?> _getUserProfile(String? userId) async {
    if (userId == null) return null;
    try {
      final databaseService = DatabaseService();
      return await databaseService.getUserProfile(userId);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
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
    return Consumer(
      builder: (context, ref, child) {
        final authService = ref.read(authServiceProvider);
        final currentUser = authService.currentUser;

        return Drawer(
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
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              color: Color(0xFF6F90B9),
                                              size: 30,
                                            ),
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
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onScreenSelected('Dashboard');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    isActive: widget.currentScreen == 'Dashboard',
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onScreenSelected('Products');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductScreen(),
                        ),
                      );
                    },
                    isActive: widget.currentScreen == 'Products',
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'Customer',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onScreenSelected('Customer');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerScreen(),
                        ),
                      );
                    },
                    isActive: widget.currentScreen == 'Customer',
                  ),

                  _buildDrawerItem(
                  icon: Icons.bar_chart,
                  title: 'Sales Report',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onScreenSelected('Sales Report');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SalesReportPage()),
                    );
                  },
                  isActive: widget.currentScreen == 'Sales Report',
                ),

                _buildDrawerItem(
                  icon: Icons.inventory_rounded,
                  title: 'Stock',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onScreenSelected('Stock ');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const StockScreen()),
                    );
                  },
                  isActive: widget.currentScreen == 'Stock',
                ),
                 _buildDrawerItem(
                  icon: Icons.point_of_sale,
                  title: 'Cashier',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onScreenSelected('Cashier ');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CashierScreen()),
                    );
                  },
                  isActive: widget.currentScreen == 'Cashier',
                ),


                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () => _logout(ref),
                    isLogout: true,
                  ),
                ],
              );
            },
          ),
        );
      },
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
            if (isLogout)
              const Icon(Icons.logout, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
