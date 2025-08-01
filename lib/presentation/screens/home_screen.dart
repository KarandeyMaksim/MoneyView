import 'package:flutter/material.dart';
import 'package:manymanager/domain/entities/transaction.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddTransactionSheet(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String category = 'Food';
    bool isIncome = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Add Transaction', style: Theme.of(ctx).textTheme.titleLarge),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount'),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter amount';
                          final num? parsed = num.tryParse(val);
                          if (parsed == null || parsed <= 0) return 'Enter valid amount';
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: category,
                        items: ['Food', 'Transport', 'Entertainment', 'Salary', 'Other']
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            category = val!;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      SwitchListTile(
                        title: const Text('Income?'),
                        value: isIncome,
                        onChanged: (val) {
                          setState(() {
                            isIncome = val;
                          });
                        },
                      ),
                      ListTile(
                        title: Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final tx = Transaction(
                              id: const Uuid().v4(),
                              amount: double.parse(amountController.text),
                              category: category,
                              description: descriptionController.text,
                              date: selectedDate,
                              isIncome: isIncome,
                            );
                            Provider.of<TransactionProvider>(context, listen: false).addTransaction(tx);
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (ctx, i) {
          final tx = transactions[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: tx.isIncome ? Colors.green : Colors.red,
                child: Text(tx.amount.toStringAsFixed(0)),
              ),
              title: Text(tx.category),
              subtitle: Text('${tx.description}\n${tx.date.toLocal().toString().split(' ')[0]}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(tx.id);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}