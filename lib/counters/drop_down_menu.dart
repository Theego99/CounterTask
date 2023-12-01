import 'package:flutter/material.dart';

class DropdownMenuWidget extends StatelessWidget {
  final String label;
  final int initialValue;
  final ValueChanged<int?> onSelected;
  final List<int> items;

  DropdownMenuWidget({
    required this.label,
    required this.initialValue,
    required this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      label: Text(label, style: TextStyle(fontSize: 20),),
      initialSelection: initialValue,
      onSelected: onSelected,
      enabled: true,
      dropdownMenuEntries: items.map((value) {
        return DropdownMenuEntry<int>(
          value: value,
          label: '$value',
        );
      }).toList(),
    );
  }
}
