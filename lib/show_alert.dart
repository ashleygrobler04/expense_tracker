import 'package:flutter/material.dart';

void showAlert(BuildContext context, String title, String text) async {
  showDialog(context: context, builder: (BuildContext context) {
    return AlertDialog(title: Text(title),content: Text(text),actions: [TextButton(onPressed: () {
      Navigator.of(context).pop();
    }, child: const Text("OK"))],);
  });
}