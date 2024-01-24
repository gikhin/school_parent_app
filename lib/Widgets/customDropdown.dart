import 'package:flutter/material.dart';
class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final ValueChanged<String> onChanged;

  CustomDropdown({
    required this.options,
    this.hintText = 'Select an option',
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            border: InputBorder.none
        ),
        value: _selectedOption,
        onChanged: (value) {
          setState(() {
            _selectedOption = value;
          });
          widget.onChanged(value!);
        },
        hint: Text(widget.hintText),
        items: widget.options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
}