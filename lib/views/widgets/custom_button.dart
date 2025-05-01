import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/sizes.dart';
import '../../utils.dart';

class CustomButton extends ConsumerWidget {
  const CustomButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.size40 + Sizes.size3,
        vertical: Sizes.size5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: Sizes.size18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.01,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
