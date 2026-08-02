import 'package:flutter/material.dart';

class StoreSearchBar extends StatelessWidget {
  const StoreSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
        prefixIcon: Icon(Icons.store_outlined),
      ),
    );
  }
}
