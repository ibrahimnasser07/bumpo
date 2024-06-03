
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldListTile extends StatelessWidget {
  const TextFieldListTile({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.0, // Border width
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            filled: true,
            fillColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}