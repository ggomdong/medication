import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/sizes.dart';
import '../../utils.dart';

class FormButton extends ConsumerWidget {
  const FormButton({
    super.key,
    required this.disabled,
    required this.text,
    required this.onTap,
  });

  final bool disabled;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = isDarkMode(ref);
    return GestureDetector(
      onTap: onTap,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: AnimatedContainer(
          padding: EdgeInsets.symmetric(vertical: Sizes.size8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                disabled
                    ? isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade600
                    : Theme.of(context).primaryColor,
            // border: Border.all(width: 2, color: Colors.black),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black,
            //     spreadRadius: 1, // 그림자 확산 정도
            //     blurRadius: 1, // 그림자 흐림 정도
            //     offset: Offset(2, 2), // X, Y 방향의 그림자 위치 조정
            //   ),
            // ],
          ),
          duration: const Duration(milliseconds: 500),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size18,
              fontWeight: FontWeight.w600,
              color:
                  disabled
                      ? isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
