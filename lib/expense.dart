import 'package:flutter/material.dart';

class Expense extends StatelessWidget {
  final String title;
  final double value;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const Expense({
    Key? key,
    required this.title,
    required this.value,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text("Amount: $value"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              onEdit(title);
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              onDelete(title);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
