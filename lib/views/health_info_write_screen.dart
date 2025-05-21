import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/utils.dart';
import '../view_models/user_view_model.dart';
import '../../constants/gaps.dart';

class HealthInfoWriteScreen extends ConsumerStatefulWidget {
  const HealthInfoWriteScreen({super.key});

  @override
  ConsumerState<HealthInfoWriteScreen> createState() =>
      _HealthInfoWriteScreenState();
}

class _HealthInfoWriteScreenState extends ConsumerState<HealthInfoWriteScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bloodPressureCtrl = TextEditingController();
  final _mealTimesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(usersProvider).valueOrNull;
    if (profile != null) {
      _heightCtrl.text = profile.height?.toString() ?? '';
      _weightCtrl.text = profile.weight?.toString() ?? '';
      _ageCtrl.text = profile.age?.toString() ?? '';
      _bloodPressureCtrl.text = profile.bloodPressure ?? '';
      _mealTimesCtrl.text = profile.mealTimes?.join(', ') ?? '';
    }
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    _bloodPressureCtrl.dispose();
    _mealTimesCtrl.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _save() async {
    final height = int.tryParse(_heightCtrl.text);
    final weight = int.tryParse(_weightCtrl.text);
    final age = int.tryParse(_ageCtrl.text);
    final bloodPressure = _bloodPressureCtrl.text.trim();
    final mealTimes =
        _mealTimesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final viewModel = ref.read(usersProvider.notifier);
    await viewModel.updateHealthInfo(
      height: height,
      weight: weight,
      age: age,
      bloodPressure: bloodPressure.isNotEmpty ? bloodPressure : null,
      mealTimes: mealTimes.isNotEmpty ? mealTimes : null,
    );

    if (mounted) {
      Navigator.pop(context);
      showSingleSnackBar(context, "건강정보가 저장되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("건강정보 입력")),
      body:
          userState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTextField("키 (cm)", _heightCtrl),
                  _buildTextField("몸무게 (kg)", _weightCtrl),
                  _buildTextField("나이", _ageCtrl),
                  _buildTextField("혈압", _bloodPressureCtrl),
                  _buildTextField("식사 시간 (쉼표로 구분)", _mealTimesCtrl),
                  Gaps.v24,
                  ElevatedButton(onPressed: _save, child: const Text("저장하기")),
                ],
              ),
    );
  }
}
