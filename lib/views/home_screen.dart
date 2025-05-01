import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/prescription_card.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko');
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionStream = ref.watch(prescriptionStreamProvider);

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
                child: prescriptionStream.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text("오류 발생: $error")),
                  data: (prescriptionList) {
                    if (prescriptionList.isEmpty) {
                      return const Center(child: Text("등록된 처방전이 없어요."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(Sizes.size16),
                      itemCount: prescriptionList.length,
                      itemBuilder: (context, index) {
                        final prescription = prescriptionList[index];
                        final start = DateFormat(
                          "yyyy.MM.dd",
                        ).format(prescription.startDate);
                        final end = DateFormat(
                          "yyyy.MM.dd",
                        ).format(prescription.endDate);
                        final dateText = "$start ~ $end";

                        return PrescriptionCard(
                          date: dateText,
                          prescription: prescription,
                        );
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
