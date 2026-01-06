import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchField(),
          const SizedBox(height: 20),
          _buildSectionTitle('Today'),
          const SizedBox(height: 10),
          _buildNotifItem(
            title: 'Succesfull',
            message: 'Successfully changed the data.',
            time: '5 min ago',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildNotifItem(
            title: 'Succesfull',
            message: 'Successfully updated product stock',
            time: '7 min ago',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildNotifItem(
            title: 'Erorr',
            message: 'Product stock has reached the minimum limit.',
            time: '7 min ago',
            icon: Icons.info,
            color: Colors.blue,
          ),
          const SizedBox(height: 25),
          _buildSectionTitle('Yesterday, 18 Apr 2022'),
          const SizedBox(height: 10),
          _buildNotifItem(
            title: 'Succesfull',
            message: 'Transaction successfully carried out.',
            time: 'Yesterday',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildNotifItem(
            title: 'Warning',
            message: 'Product warning is out of stock.',
            time: 'Yesterday',
            icon: Icons.warning,
            color: Colors.red,
          ),
          _buildNotifItem(
            title: 'Succesfull',
            message: 'Transaction successfully carried out.',
            time: 'Yesterday',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildNotifItem(
            title: 'Succesfull',
            message: 'Transaction successfully carried out.',
            time: 'Yesterday',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNotifItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
