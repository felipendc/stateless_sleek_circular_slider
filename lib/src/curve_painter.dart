part of circular_slider;

class _CurvePainter extends CustomPainter {
  final double angle;
  final CircularSliderAppearance appearance;
  final double startAngle;
  final double angleRange;

  Offset? handler;
  Offset? center;
  late double radius;

  _CurvePainter({required this.appearance, this.angle = 30, required this.startAngle, required this.angleRange});

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) - appearance.progressBarWidth * 0.5;
    center = Offset(size.width / 2, size.height / 2);

    final progressBarRect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);

    Paint trackPaint;
    if (appearance.trackColors != null) {
      final trackGradient = SweepGradient(
        startAngle: degreeToRadians(appearance.trackGradientStartAngle),
        endAngle: degreeToRadians(appearance.trackGradientStopAngle),
        tileMode: TileMode.mirror,
        colors: appearance.trackColors!,
      );
      trackPaint = Paint()
        ..shader = trackGradient.createShader(progressBarRect)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth;
    } else {
      trackPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth
        ..color = appearance.trackColor;
    }
    _drawCircularArc(
      canvas: canvas,
      size: size,
      paint: trackPaint,
      ignoreAngle: true,
    );

    if (!appearance.hideShadow) {
      _drawShadow(canvas: canvas, size: size);
    }

    final currentAngle = appearance.counterClockwise ? -angle : angle;
    final dynamicGradient = appearance.dynamicGradient;
    final gradientRotationAngle = dynamicGradient
        ? appearance.counterClockwise
            ? startAngle + 10.0
            : startAngle - 10.0
        : 0.0;
    final GradientRotation rotation = GradientRotation(degreeToRadians(gradientRotationAngle));

    final gradientStartAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0 - currentAngle.abs()
            : 0.0
        : appearance.gradientStartAngle;
    final gradientEndAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0
            : currentAngle.abs()
        : appearance.gradientStopAngle;
    final colors = dynamicGradient && appearance.counterClockwise
        ? appearance.progressBarColors.reversed.toList()
        : appearance.progressBarColors;

    final progressBarGradient = kIsWeb
        ? LinearGradient(
            tileMode: TileMode.mirror,
            colors: colors,
          )
        : SweepGradient(
            transform: rotation,
            startAngle: degreeToRadians(gradientStartAngle),
            endAngle: degreeToRadians(gradientEndAngle),
            tileMode: TileMode.mirror,
            colors: colors,
          );

    final progressBarPaint = Paint()
      ..shader = progressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    _drawCircularArc(canvas: canvas, size: size, paint: progressBarPaint);


    // Draw divisions
    if (appearance.customDivisions != null) {
      final bgPaint = Paint()
        ..color = appearance.customColors?.divisionBackgroundColor ?? appearance.trackColor
        ..style = PaintingStyle.fill;
      final fgPaint = Paint()
        ..color = appearance.customColors?.divisionForegroundColor ?? appearance.trackColor
        ..style = PaintingStyle.fill;
      final divisions = appearance.customDivisions!.divisions ?? 5;
      final startSize = appearance.customDivisions!.startSize ?? appearance.trackWidth + 2;
      final endSize = appearance.customDivisions!.endSize ?? appearance.trackWidth + 4;
      final step = angleRange / (divisions - 1);
      for (int i = 0; i < divisions; i++) {
        Offset c = degreesToCoordinates(center!, -math.pi / 2 + startAngle + (step * i) + 1.5, radius);
        canvas.drawCircle(
          c,
          lerpDouble(startSize, endSize, (i / divisions))!,
          (step * i >= currentAngle) ? bgPaint : fgPaint,
        );
      }
    }

    final dotFillPaint = Paint()..color = appearance.dotFillColor;

    Offset handle = degreesToCoordinates(center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius);
    canvas.drawCircle(handle, appearance.handlerSize, dotFillPaint);
    if (appearance.dotStrokeColor != null) {
      final dotStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.strokeWidth
        ..isAntiAlias = true
        ..color = appearance.dotStrokeColor!;
      canvas.drawCircle(handle, appearance.handlerSize + .5, dotStrokePaint);
    }
  }

  void _drawCircularArc(
      {required Canvas canvas,
      required Size size,
      required Paint paint,
      bool ignoreAngle = false,
      bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(Rect.fromCircle(center: center!, radius: radius), degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle), false, paint);
  }

  void _drawShadow({required Canvas canvas, required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep!
        : math.max(1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1, ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor.withOpacity(maxOpacity - (opacityStep * (i - 1)));
      _drawCircularArc(canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
