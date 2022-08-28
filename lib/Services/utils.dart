import 'package:flutter/material.dart';

class Utils {
  static void showScaffoldMessage({
    required BuildContext context,
    required String msg,
    required bool error,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? Colors.red[300] : Colors.green,
      content: Row(
        children: [
          error ? const Icon(Icons.error) : const Icon(Icons.done),
          const SizedBox(
            width: 6,
          ),
          Flexible(child: Text(msg))
        ],
      ),
    ));
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmString,
  }) async {
    bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancle'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmString),
                ),
              ],
            ));

    return confirm;
  }
}
