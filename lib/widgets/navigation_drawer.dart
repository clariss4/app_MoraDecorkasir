import 'package:flutter/material.dart';
import 'package:pos_kasir/screens/cashier_screen.dart';
import 'package:pos_kasir/screens/sales_report_screen.dart';
import 'package:pos_kasir/screens/stock_sceen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/dashboard_screen.dart';
import '../screens/product_screen.dart';
import '../screens/customer_screen.dart';
import '../screens/splash_screen.dart';

class NavigationDrawer extends StatelessWidget {
  final String currentScreen;

  const NavigationDrawer({
    super.key,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          final currentUser = Supabase.instance.client.auth.currentUser;

          final displayName =
              profile?['nama'] ??
              currentUser?.email?.split('@').first ??
              'User';
          final email =
              profile?['email'] ?? currentUser?.email ?? 'user@email.com';
          final userId = currentUser?.id.substring(0, 8) ?? 'Unknown';
          final role = profile?['role']?.toString().toUpperCase() ?? 'USER';
          final isKasir = role == 'KASIR';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFF6F90B9)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6F90B9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $userId',
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
                              role,
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

              // MENU ADMIN
              if (!isKasir) ...[
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  screenName: 'Dashboard',
                  isActive: currentScreen == 'Dashboard',
                  onTap: () => _navigateTo(context, const DashboardScreen()),
                ),
                _buildMenuItem(
                  icon: Icons.inventory_2,
                  title: 'Products',
                  screenName: 'Products',
                  isActive: currentScreen == 'Products',
                  onTap: () => _navigateTo(context, const ProductScreen()),
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'Customer',
                  screenName: 'Customer',
                  isActive: currentScreen == 'Customer',
                  onTap: () => _navigateTo(context, const CustomerScreen()),
                ),
                _buildMenuItem(
                  icon: Icons.bar_chart,
                  title: 'Sales Report',
                  screenName: 'Sales Report',
                  isActive: currentScreen == 'Sales Report',
                  onTap: () =>
                      _navigateTo(context, const SalesReportPage()),
                ),
                _buildMenuItem(
                  icon: Icons.warehouse,
                  title: 'Stock',
                  screenName: 'Stock',
                  isActive: currentScreen == 'Stock',
                  onTap: () => _navigateTo(context, const StockScreen()),
                ),
              ],

              // MENU KASIR
              _buildMenuItem(
                icon: Icons.point_of_sale,
                title: 'Cashier',
                screenName: 'Cashier',
                isActive: currentScreen == 'Cashier',
                onTap: () => _navigateTo(context, const CashierScreen()),
              ),

              const Divider(height: 16, thickness: 1, color: Colors.grey),

              // SETTINGS
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                screenName: 'Settings',
                isActive: currentScreen == 'Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings clicked')),
                  );
                },
              ),

              // LOGOUT
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                screenName: 'Logout',
                isLogout: true,
                isActive: false,
                onTap: () {
                  Supabase.instance.client.auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // FETCH PROFILE
  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return null;

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // MENU ITEM FIXED VERSION
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String screenName,
    required bool isActive,
    required VoidCallback onTap,
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
            if (isLogout)
              const Icon(Icons.logout, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // NAVIGATE
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
