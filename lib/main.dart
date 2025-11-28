import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gujmudexxzojovommetq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1am11ZGV4eHpvam92b21tZXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0ODk1MzMsImV4cCI6MjA3NzA2NTUzM30.oMjIG71Sw7I7SdLx4GjFp33JopR_HMmwiOATWqF2kho',
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoraDecor POS',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
