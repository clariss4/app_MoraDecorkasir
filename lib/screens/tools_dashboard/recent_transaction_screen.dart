// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/sales_service.dart';
// import '../models/penjualan.dart';

// class RecentTransactionsScreen extends ConsumerStatefulWidget {
//   const RecentTransactionsScreen({super.key});

//   @override
//   ConsumerState<RecentTransactionsScreen> createState() => _RecentTransactionsScreenState();
// }

// class _RecentTransactionsScreenState extends ConsumerState<RecentTransactionsScreen> {
//   List<Penjualan> _transactions = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTransactions();
//   }

//   Future<void> _loadTransactions() async {
//     try {
//       final salesService = ref.read(salesServiceProvider);
//       final transactions = await salesService.getRiwayatPenjualan();
//       setState(() {
//         _transactions = transactions;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading transactions: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Recent Transactions'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _transactions.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No transactions found',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: _transactions.length,
//                   itemBuilder: (context, index) {
//                     final transaction = _transactions[index];
//                     return _buildTransactionCard(transaction);
//                   },
//                 ),
//     );
//   }

//   Widget _buildTransactionCard(Penjualan transaction) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.green.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.receipt, color: Colors.green),
//         ),
//         title: Text(
//           'Transaction #${transaction.id.substring(0, 8)}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total: Rp ${transaction.total}'),
//             Text(
//               'Date: ${_formatDate(transaction.createdAt)}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: () {
//           // Navigate to transaction detail
//           _showTransactionDetail(transaction);
//         },
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   void _showTransactionDetail(Penjualan transaction) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Transaction Detail'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('ID: ${transaction.id}'),
//             Text('Total: Rp ${transaction.total}'),
//             Text('Subtotal: Rp ${transaction.subtotalSebelumDiskon}'),
//             Text('Discount: Rp ${transaction.nilaiDiskon}'),
//             Text('Date: ${_formatDate(transaction.createdAt)}'),
//             if (transaction.catatan != null) Text('Notes: ${transaction.catatan}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
