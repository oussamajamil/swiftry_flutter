import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String? text;

  /// disabled the button
  final bool? disabled;
  final Function()? onPressed;
  const MyButton({super.key, this.text, this.onPressed, this.disabled});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF00BABB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 23,
        ),
      ),
    );
  }
}
