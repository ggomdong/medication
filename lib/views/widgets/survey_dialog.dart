import 'package:flutter/material.dart';
import '../../constants/gaps.dart';

Future<void> showSurveyDialog(BuildContext context) async {
  int? satisfaction;
  int? comparison;
  bool? hadSideEffects;
  String? sideEffectDetail;
  String? memo;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => AlertDialog(
              title: const Text("복약 설문조사"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Text("약 복용 후 건강 상태는 어떤가요?"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              satisfaction = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color:
                                satisfaction != null && satisfaction! > index
                                    ? Colors.amber
                                    : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    Gaps.v12,
                    const Text("부작용이 있었나요?"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("예"),
                          selected: hadSideEffects == true,
                          onSelected:
                              (_) => setState(() => hadSideEffects = true),
                        ),
                        Gaps.h10,
                        ChoiceChip(
                          label: const Text("아니오"),
                          selected: hadSideEffects == false,
                          onSelected:
                              (_) => setState(() => hadSideEffects = false),
                        ),
                      ],
                    ),
                    if (hadSideEffects == true) ...[
                      Gaps.v12,
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "어떤 부작용이 있었나요?",
                          hintText: "예: 메스꺼움, 어지러움 등",
                        ),
                        onChanged: (val) => sideEffectDetail = val,
                      ),
                    ],
                    Gaps.v12,
                    const Text("유사 증상 시 다른 약과 비교해서 효과는 어땠나요?"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              comparison = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color:
                                comparison != null && comparison! > index
                                    ? Colors.amber
                                    : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    Gaps.v12,
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "기타 의견이 있다면 입력해주세요.",
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                      onChanged: (val) => memo = val,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("건너뛰기"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 여기에 저장 로직 추가 가능
                    Navigator.of(context).pop();
                  },
                  child: const Text("제출"),
                ),
              ],
            ),
      );
    },
  );
}
