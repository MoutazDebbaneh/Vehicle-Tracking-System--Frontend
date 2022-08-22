import 'package:flutter/material.dart';

class IconedTextField extends StatelessWidget {
  final String text;
  final String label;
  final Icon icon;

  const IconedTextField({
    required this.text,
    required this.icon,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        border: const UnderlineInputBorder(),
        labelText: label,
        icon: icon,
        isDense: false,
      ),
      readOnly: true,
      enabled: false,
      initialValue: text,
    );
  }
}
