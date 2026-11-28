import 'package:flutter/material.dart';
import '../../../../core/theme/afos_colors.dart';

/// Touch signature capture pad for digital agreements
class SignaturePadWidget extends StatefulWidget {
  final String label;
  final ValueChanged<String> onSignatureChanged;

  const SignaturePadWidget({
    super.key,
    required this.label,
    required this.onSignatureChanged,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _strokes = [];
  bool _hasSignature = false;

  void _clear() {
    setState(() {
      _strokes.clear();
      _hasSignature = false;
    });
    widget.onSignatureChanged('');
  }

  void _notifyChanged() {
    if (_strokes.isNotEmpty && !_hasSignature) {
      _hasSignature = true;
      // In web/desktop, simulate SVG/data URL format for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      widget.onSignatureChanged('data:image/svg+xml;afos_signature_$timestamp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AfosColors.primaryNavy,
              ),
            ),
            if (_hasSignature)
              TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.refresh, size: 14, color: AfosColors.crimsonAlert),
                label: const Text('Hapus', style: TextStyle(fontSize: 12, color: AfosColors.crimsonAlert)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hasSignature ? AfosColors.jogjaTeal : AfosColors.borderSlate,
              width: _hasSignature ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _strokes.add([details.localPosition]);
                });
                _notifyChanged();
              },
              onPanUpdate: (details) {
                setState(() {
                  if (_strokes.isNotEmpty) {
                    _strokes.last.add(details.localPosition);
                  }
                });
                _notifyChanged();
              },
              child: CustomPaint(
                painter: _SignaturePainter(_strokes),
                child: _strokes.isEmpty
                    ? Center(
                        child: Text(
                          'Tanda tangan di sini dengan jari atau stylus',
                          style: TextStyle(
                            fontSize: 12,
                            color: AfosColors.mutedSlate.withOpacity(0.7),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AfosColors.primaryNavy
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
