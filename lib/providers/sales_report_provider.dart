import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/sales_report_controller.dart';
import '../models/sales_report_model.dart';

/// ===============================
///  STATE
/// ===============================
class SalesReportState {
  final bool isLoading;
  final String? error;
  final SalesReportModel? report;
  final List<Map<String, dynamic>> items;

  SalesReportState({
    this.isLoading = false,
    this.error,
    this.report,
    this.items = const [],
  });

  SalesReportState copyWith({
    bool? isLoading,
    String? error,
    SalesReportModel? report,
    List<Map<String, dynamic>>? items,
  }) {
    return SalesReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      report: report ?? this.report,
      items: items ?? this.items,
    );
  }
}

/// ===============================
///  CONTROLLER (NOTIFIER)
/// ===============================
class SalesReportNotifier extends Notifier<SalesReportState> {
  late SalesReportController service;

  @override
  SalesReportState build() {
    service = SalesReportController();
    return SalesReportState();
  }

  DateTimeRange? dateRange;

  Future<void> loadReport() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final trx = await service.fetchTransactions();

      /// Ambil detail item juga
      List<Map<String, dynamic>> allDetails = [];
      for (var t in trx) {
        final detail = await service.fetchDetail(t['id']);
        allDetails.addAll(detail);
      }

      final laporan = await service.hitungLaporan(trx);

      state = state.copyWith(
        isLoading: false,
        report: laporan,
        items: allDetails,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setDateRange(DateTimeRange range) {
    dateRange = range;
    loadReport();
  }

  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }
}

/// ===============================
///  PROVIDER RESMI UNTUK UI
/// ===============================
final salesReportProvider =
    NotifierProvider<SalesReportNotifier, SalesReportState>(
  SalesReportNotifier.new,
);


