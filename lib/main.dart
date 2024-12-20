import 'package:flutter/material.dart';
import 'package:expense_tracker/expense.dart';
import 'package:expense_tracker/json_manager.dart';
import 'package:expense_tracker/result.dart';
import 'package:expense_tracker/show_alert.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int selectedIndex = 0;

  @override
  void dispose() {
    expensePrice.dispose();
    expenseTitle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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

  Future<Result<String, String>> handleSubmit() async {
    List<Map<String, dynamic>>? s = await DataManager.loadFromFile();
        if (expenseTitleText == "") {
      return Result.Error("Expense field required.");
    }
    else if (expensePriceText == "" || expensePriceText.isEmpty ||  double.tryParse(expensePriceText)==null){
      return Result.Error("Expense price field required.");
    }

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
    s ??= [];
    s.add({"title": expenseTitleText, "value": expensePriceText});
    expenseTitle.clear();
    expensePrice.clear();
    try {
      await DataManager.saveToFile(s);
      return Result.Success("Saved");
    } catch (e) {
      return Result.Error(e.toString());
    }
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

  Future<void> _deleteExpense(String title) async {
    List<Map<String, dynamic>> d = [];
    setState(() {
      expenses.removeWhere((expense) => expense.title == title);
      selectedIndex = 0;
    });
    d = [];
    expenses.forEach((element) {
      d.add({"title": element.title, "value": element.value});
    });
    await DataManager.saveToFile(d);
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
                decoration: const InputDecoration(
                    labelText: "Updated Title", hintText: "Update title"),
                controller: updatedTitleController,
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: "Updated Value", hintText: "Update value"),
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

  Future<void> _updateExpense(
      String oldTitle, String newTitle, double newValue) async {
    List<Map<String, dynamic>> d1 = [];
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
    expenses.forEach((element) {
      d1.add({"title": element.title, "value": element.value});
    });
    await DataManager.saveToFile(d1);
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>>? loadedData = await DataManager.loadFromFile();

    if (loadedData != null) {
      List<Expense> loadedExpenses = [];

      for (int i = 0; i < loadedData.length; i++) {
        loadedExpenses.add(Expense(
          title: loadedData[i]['title'],
          value: double.parse(loadedData[i]['value'].toString()),
          onEdit: _showEditDialog,
          onDelete: _showDeleteConfirmationDialog,
        ));
      }

      setState(() {
        expenses = loadedExpenses;
      });
    }
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
                      return Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            setState(() {
                              selectedIndex = index;
                            });
                          }
                        },
                        child: Semantics(
                          hint: "Click to edit",
                          label: expenses[index].title,
                          child: ListTile(
                            title: Text(expenses[index].title),
                            subtitle: Text(expenses[index].value.toString()),
                            onTap: () {
                              _showEditDialog(expenses[index].title);
                            },
                            trailing: Semantics(
                              label: "Delete",
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      expenses[index].title);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          TextField(
            decoration: const InputDecoration(
                labelText: "Enter an expense", hintText: "Enter expense"),
            controller: expenseTitle,
          ),
          TextField(
            decoration: const InputDecoration(
                labelText: "Enter the price of this expense",
                hintText: "Enter the price of this expense"),
            controller: expensePrice,
          ),
          TextButton(
              onPressed: () async {
                Result<String, String> res = await handleSubmit();
                if (!res.isSuccess) {
                  showAlert(context, "Error", res.error??"Unknown error");
                }
              },
              child: const Text("Add expense")),
              TextButton(onPressed: onPriv, child: Text("View Privacy Policy"))
        ],
      ),
    );
  }

  Future<void> onPriv() async {
    if (! await launchUrl(Uri.parse("https://ashleygrobler04.github.io/files/priv.html"))) {
      showAlert(context, "Error launching URL", "Could not open url.\nPlease go to https://ashleygrobler04.github.io/files/priv.html to view the privacy policy instead.");
    }
  }
}
