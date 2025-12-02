import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_kasir/models/stok_model.dart';
import '../controller/stock_controller.dart';


final stockProvider =
    StateNotifierProvider<StockController, List<StockModel>>(
  (ref) => StockController(ref),
);
