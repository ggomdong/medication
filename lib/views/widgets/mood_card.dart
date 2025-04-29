import '../../constants/gaps.dart';
import '../../constants/sizes.dart';
import '../../models/mood_model.dart';
import '../../utils.dart';
import '../../view_models/mood_view_model.dart';
import '../../views/post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoodCard extends ConsumerStatefulWidget {
  const MoodCard({super.key, required this.date, required this.mood});

  final String date;
  final MoodModel mood;

  @override
  ConsumerState<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends ConsumerState<MoodCard> {
  void _showUpdateBottomSheet(BuildContext context, MoodModel mood) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom, // 키보드 올라올 때 패딩 조정
              ),
              child: PostScreen(mood: mood),
            ),
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, String moodId) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text("삭제 확인"),
            message: const Text("정말로 삭제하시겠습니까?"),
            actions: [
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => context.pop(),
                child: const Text("취소"),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  // MoodCard가 dispose된 후에도 Provider에 접근
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );

                  await container
                      .read(moodProvider.notifier)
                      .deleteMood(moodId);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("삭제되었습니다.")));
                },
                child: const Text("삭제"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, widget.mood.moodId),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF3A3A3A) : Color(0xFFD9CBA3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.white : Colors.black,
              spreadRadius: -1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: Sizes.size16),
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size12,
          horizontal: Sizes.size16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _showUpdateBottomSheet(context, widget.mood);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Gaps.h6, // 아이콘 간격 조정
                    InkWell(
                      onTap: () {
                        _showDeleteDialog(context, widget.mood.moodId);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.date,
                  style: TextStyle(
                    fontSize: Sizes.size12,
                    color: isDark ? Color(0xFFD3C6B8) : Color(0xFF8C7B6B),
                  ),
                ),
                Gaps.h8,
                // AnimatedEmoji(
                //   emoji: mood.mood,
                // ),
                Text(
                  widget.mood.mood,
                  style: TextStyle(fontSize: Sizes.size36),
                ),
                Gaps.h4,
              ],
            ),
            Gaps.v12,
            Text(
              widget.mood.story,
              style: TextStyle(
                fontSize: Sizes.size14,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
