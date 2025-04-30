import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../models/mood_model.dart';
import '../view_models/mood_view_model.dart';
import '../views/widgets/mood_card.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../utils.dart';
import '../views/widgets/common_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<MoodModel> _moods = [];

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko');
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    final moodStream = ref.watch(moodStreamProvider);

    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CommonAppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizes.size32),
          child: Column(
            children: [
              Gaps.v10,
              Expanded(
                child: moodStream.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text("오류 발생: $error")),
                  data: (moods) {
                    if (moods.isEmpty) {
                      return const Center(child: Text("복약 기록이 없어요."));
                    }

                    return ListView.builder(
                      itemCount: moods.length,
                      itemBuilder: (context, index) {
                        final mood = moods[index];
                        final date = DateFormat(
                          'yyyy-MM-dd (E) HH:mm',
                          'ko',
                        ).format(
                          DateTime.fromMillisecondsSinceEpoch(mood.createdAt),
                        );

                        return MoodCard(date: date, mood: mood);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
