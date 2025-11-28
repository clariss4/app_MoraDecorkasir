import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// ✅ USE EXISTING METHOD: getDashboardStats()
final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final databaseService = ref.read(databaseServiceProvider);
  return await databaseService.getDashboardStats();
});

// ✅ USE EXISTING STRUCTURE: Custom provider for revenue data
final revenueDataProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, period) async {
    // Since we don't have getRevenueData method, we'll create the data here
    List<double> revenueData = [];
    List<String> labels = [];

    switch (period) {
      case 'weekly':
        revenueData = [20, 40, 60, 80, 100, 60, 40];
        labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        break;
      case 'monthly':
        revenueData = [30, 50, 70, 90, 80, 60, 40, 70, 85, 95, 75, 65];
        labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
        break;
      case 'today':
        revenueData = [10, 25, 45, 65, 85, 70, 50, 35, 60, 80, 90, 75];
        labels = [
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
        break;
      default:
        revenueData = [20, 40, 60, 80, 100, 60, 40];
        labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    }

    return {'data': revenueData, 'labels': labels, 'period': period};
  },
);
