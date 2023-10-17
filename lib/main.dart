import 'package:flutter/material.dart';
import 'package:expense_tracker/expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Access Expenses",
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Expense> expenses = [];
  double total = 0.0;
  TextEditingController expenseTitle = TextEditingController();
  TextEditingController expensePrice = TextEditingController();
  String expenseTitleText = "";
  String expensePriceText = "";

  @override
  void dispose() {
    expensePrice.dispose();
    expenseTitle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    total = calculateTotal();
    expenseTitle.addListener(() {
      setState(() {
        expenseTitleText = expenseTitle.text;
      });
    });
    expensePrice.addListener(() {
      setState(() {
        expensePriceText = expensePrice.text;
      });
    });
  }

  double calculateTotal() {
    double t = 0;
    for (int i = 0; i < expenses.length; i++) {
      t += expenses[i].value;
    }
    return t;
  }

  void handleSubmit() {
    setState(() {
      expenses.add(
        Expense(
          title: expenseTitleText,
          value: double.parse(expensePriceText),
          onEdit: (title) {
            _showEditDialog(title);
          },
          onDelete: (title) {
            _showDeleteConfirmationDialog(title);
          },
        ),
      );
    });
    expenseTitle.clear();
    expensePrice.clear();
  }

  void _showDeleteConfirmationDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content:
              Text("Are you sure you want to delete the expense '$title'?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(title);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(String title) {
    setState(() {
      expenses.removeWhere((expense) => expense.title == title);
    });
  }

  void _showEditDialog(String title) {
    TextEditingController updatedTitleController = TextEditingController();
    TextEditingController updatedValueController = TextEditingController();

    // Set the initial values to the current values for editing
    updatedTitleController.text = title;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Updated Title"),
                controller: updatedTitleController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Updated Value"),
                controller: updatedValueController,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _updateExpense(title, updatedTitleController.text,
                    double.parse(updatedValueController.text));
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _updateExpense(String oldTitle, String newTitle, double newValue) {
    setState(() {
      // Find the index of the expense to update
      int index = expenses.indexWhere((expense) => expense.title == oldTitle);
      // Update the expense
      if (index != -1) {
        expenses[index] = Expense(
          title: newTitle,
          value: newValue,
          onEdit: (title) {
            _showEditDialog(title);
          },
          onDelete: (title) {
            _showDeleteConfirmationDialog(title);
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track your expenses")),
      body: Column(
        children: [
          Text("Total: ${calculateTotal()}"),
          expenses.isEmpty
              ? const Center(
                  child: Text("No expenses"),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return expenses[index];
                    },
                  ),
                ),
          TextField(
            decoration: const InputDecoration(labelText: "Enter an expense"),
            controller: expenseTitle,
          ),
          TextField(
            decoration: const InputDecoration(
                labelText: "Enter the price of this expense"),
            controller: expensePrice,
          ),
          TextButton(onPressed: handleSubmit, child: const Text("Add expense"))
        ],
      ),
    );
  }
}
