import 'package:flutter/material.dart';
import 'package:manymanager/domain/entities/transaction.dart';
import 'package:manymanager/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const BudgetApp(),
    ),
  );
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}
