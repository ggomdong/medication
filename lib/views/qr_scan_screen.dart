import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../view_models/prescription_view_model.dart';
import '../models/prescription_model.dart';
import '../repos/authentication_repo.dart';
import '../router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScanScreen extends ConsumerStatefulWidget {
  const QRScanScreen({super.key});

  @override
  ConsumerState<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends ConsumerState<QRScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final double holeSize = 250.0; // 인식 영역 크기

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: holeSize).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchMedicineData(
    WidgetRef ref,
    BuildContext context,
    String url,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(decodedBody);

        // 필수 필드 확인 (형식 검증)
        if (!(jsonData.containsKey('prescription_id') &&
            jsonData.containsKey('diagnosis') &&
            jsonData.containsKey('medicines'))) {
          throw FormatException("QR 형식 오류");
        }

        // 중복 확인
        final prescriptionId = jsonData['prescription_id'];
        final isExists = await ref
            .read(prescriptionProvider.notifier)
            .checkExistPrescription(prescriptionId);

        print(isExists);

        if (isExists) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("해당 처방전이 이미 등록되어 있습니다.")),
            );
          }
          return;
        }

        final uid = ref.read(authRepo).user?.uid ?? "";
        final createdAt = DateTime.now().millisecondsSinceEpoch;

        final prescription = PrescriptionModel.fromJson(
          jsonData,
        ).copyWith(prescriptionId: null, uid: uid, createdAt: createdAt);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pushReplacement(RouteURL.prescription, extra: prescription);
          }
        });
      } else {
        throw Exception('API 호출 실패');
      }
    } on FormatException {
      // QR 형식 오류에 대한 명확한 안내
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("올바른 처방전 QR코드를 스캔해주세요.")));
    } catch (e) {
      // 일반 예외
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isProcessing = false;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("처방전 QR 스캔")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) async {
              if (isProcessing) return;
              isProcessing = true;

              final barcode = barcodeCapture.barcodes.first;
              final String? url = barcode.rawValue;
              if (url != null) {
                await fetchMedicineData(ref, context, url);
              }
            },
          ),
          CustomPaint(
            size: size,
            painter: ScannerOverlayPainter(holeSize: holeSize),
          ),
          Center(
            child: SizedBox(
              width: holeSize,
              height: holeSize,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value,
                        left: 0,
                        right: 0,
                        child: Container(height: 2, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double holeSize;

  ScannerOverlayPainter({required this.holeSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    final double holeLeft = (size.width - holeSize) / 2;
    final double holeTop = (size.height - holeSize) / 2;
    final Rect holeRect = Rect.fromLTWH(holeLeft, holeTop, holeSize, holeSize);
    final RRect hole = RRect.fromRectAndRadius(
      holeRect,
      const Radius.circular(12),
    );

    // 전체 캔버스를 그린 뒤
    Path overlayPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 가운데 투명 영역을 "빼기" (Difference)
    Path holePath = Path()..addRRect(hole);

    Path finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      holePath,
    );

    canvas.drawPath(finalPath, backgroundPaint);

    // 테두리 추가
    final Paint borderPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    canvas.drawRRect(hole, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScannerLinePainter extends CustomPainter {
  final double position;

  ScannerLinePainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, position),
      Offset(size.width, position),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerLinePainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
