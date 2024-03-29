import 'package:flutter/material.dart';

void showMessageDialog({required BuildContext context, required String? message}) {
  showDialog(
      context: context,
      builder: (context) {
        return Center(
            child: AlertDialog(
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('Close')),
          ],
          title: Text('$message'),
        ));
      });
}

void showProgressionDialog({required BuildContext context}) {
  showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      });
}
