import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../models/mood_model.dart';
import '../utils.dart';
import '../view_models/mood_view_model.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key, this.mood});

  final MoodModel? mood;

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  late TextEditingController _textEditingController;
  String? _mood;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: widget.mood?.story ?? "",
    );
    _mood = widget.mood?.mood;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  void selectMood(String emoji) {
    setState(() {
      _mood = emoji;
    });
  }

  void _onSubmitForm() async {
    if (_mood == null) return;
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      if (widget.mood == null) {
        // 신규 Mood 추가
        await ref
            .read(moodProvider.notifier)
            .postMood(_mood!, _textEditingController.text, context);
      } else {
        // 기존 Mood 수정
        await ref
            .read(moodProvider.notifier)
            .updateMood(
              widget.mood!.moodId,
              _mood!,
              _textEditingController.text,
            );
      }

      if (!mounted) return;

      // 로딩창 닫기
      Navigator.pop(context);

      if (widget.mood == null) {
        // 입력 필드 초기화
        setState(() {
          _mood = null;
          _textEditingController.clear();
        });

        // HomeScreen으로 이동
        context.go("/home");
      } else {
        // 모달 닫기
        Navigator.pop(context);
      }

      // 키보드 내림
      _onScaffoldTap();
      _onScaffoldTap();

      // 성공 스낵바
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.mood == null ? '새 기분이 등록되었어요.' : '기분이 수정되었어요.'),
        ),
      );
    } catch (e) {
      // 로딩창 닫기
      Navigator.pop(context);

      if (widget.mood != null) {
        // 모달 닫기
        Navigator.pop(context);
      }

      showFirebaseErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: widget.mood == null ? CommonAppBar() : null,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizes.size32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v20,
              Text(
                "기분이 어떤가요?",
                style: TextStyle(
                  fontSize: Sizes.size18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Gaps.v10,
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white : Colors.black,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.white : Colors.black,
                      spreadRadius: -1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textEditingController,
                  autocorrect: false,
                  maxLines: 6,
                  keyboardType: TextInputType.text,
                  scrollPhysics: BouncingScrollPhysics(),
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Sizes.size10,
                      vertical: Sizes.size10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintText: "",
                    hintStyle: TextStyle(
                      color:
                          isDark ? Colors.grey.shade50 : Colors.grey.shade600,
                      fontSize: Sizes.size14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    alignLabelWithHint: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(width: 2),
                    ),
                  ),
                ),
              ),
              Gaps.v28,
              Text(
                "내 기분은...",
                style: TextStyle(
                  fontSize: Sizes.size18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Gaps.v10,
              SizedBox(
                height: 48,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: Sizes.size10,
                  runSpacing: Sizes.size12,
                  children:
                      moodEmojiList.map((emoji) {
                        final isSelected = _mood == emoji;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => selectMood(emoji),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.blue.withAlpha(50),
                            child: AnimatedScale(
                              scale: isSelected ? 1.2 : 1.0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              child: AnimatedSlide(
                                offset:
                                    isSelected ? Offset(0, -0.1) : Offset.zero,
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade50
                                            : Colors.white,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            isSelected
                                                ? Colors.blue.shade100
                                                : Colors.black12,
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    emoji,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              Gaps.v48,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
                child: FormButton(
                  disabled: false,
                  text: widget.mood == null ? "Post" : "Update",
                  onTap: _onSubmitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
