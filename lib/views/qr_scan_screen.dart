import 'package:flutter/material.dart';
import '../models/medi_model.dart';
import '../views/record_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
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

  Future<void> fetchMedicineData(BuildContext context, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final model = MediModel(
          mId: '', // Firestore 저장 시 새로 생성
          medicine_id: data['medicine_id'],
          name: data['name'],
          type: data['type'],
          times_per_day: data['times_per_day'].toString(),
          timing: data['timing'],
          createdAt: 0, // 저장 시 새로 생성
          creatorUid: '',
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecordScreen(mediModel: model)),
        );
      } else {
        throw Exception('API 호출 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final holeLeft = (size.width - holeSize) / 2;
    final holeTop = (size.height - holeSize) / 2;

    return Scaffold(
      appBar: AppBar(title: const Text("QR 스캔")),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) async {
              final barcode = barcodeCapture.barcodes.first;
              final String? url = barcode.rawValue;
              if (url != null) {
                await fetchMedicineData(context, url);
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
          ..color = Colors.black.withOpacity(0.3) // 더 얇은 어둡기 (0.3 정도)
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
