import 'package:flutter/material.dart';
import 'package:manymanager/domain/entities/transaction.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryTotals = transactionProvider.categoryTotals;

    // Для LineChart считаем суммарный баланс по датам
    final List<Transaction> transactions = transactionProvider.transactions;
    transactions.sort((a, b) => a.date.compareTo(b.date));

    Map<DateTime, double> balanceByDate = {};
    double runningBalance = 0;
    for (var tx in transactions) {
      runningBalance += tx.isIncome ? tx.amount : -tx.amount;
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      balanceByDate[date] = runningBalance;
    }

    final spots = balanceByDate.entries
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList();

    // Для оси X конвертируем метки в даты
    String getDateLabel(double value) {
      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return '${date.day}/${date.month}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Expenses by Category', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((entry) {
                      final color = _colorForCategory(entry.key);
                      final value = entry.value.abs();
                      return PieChartSectionData(
                        color: color,
                        value: value,
                        title: '${entry.key}\n${value.toStringAsFixed(0)}',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Balance Over Time', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: (spots.length > 1)
                              ? (spots.last.x - spots.first.x) / (spots.length - 1)
                              : 1,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(getDateLabel(value), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 100),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'salary':
        return Colors.green;
      case 'other':
      default:
        return Colors.grey;
    }
  }
}