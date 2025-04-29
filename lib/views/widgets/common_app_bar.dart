import '../../constants/gaps.dart';
import '../../repos/authentication_repo.dart';
import '../../utils.dart';
import '../../view_models/settings_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  void _onShowModal(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text("정말 로그아웃하시겠어요?"),
            content: const Text("가지마~~"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("아니오"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  ref.read(authRepo).signOut();
                  context.go("/");
                },
                isDestructiveAction: true,
                child: const Text("예"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading:
          ref.read(authRepo).isLoggedIn
              ? Row(
                children: [
                  Gaps.h10,
                  GestureDetector(
                    onTap: () => _onShowModal(context, ref),
                    child: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                  ),
                ],
              )
              : null,
      title: Image.asset(logo, width: 300, height: 150),
      actions: [
        GestureDetector(
          onTap: () => ref.read(settingsProvider.notifier).setDarkMode(!isDark),
          child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
        Gaps.h10,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
