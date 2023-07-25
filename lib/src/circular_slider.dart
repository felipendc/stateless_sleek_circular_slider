library circular_slider;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils.dart';
import 'appearance.dart';
import 'slider_label.dart';
import 'dart:math' as math;

part 'curve_painter.dart';

part 'custom_gesture_recognizer.dart';

typedef void OnChange(double value);
typedef Widget InnerWidget(double percentage);

class SleekCircularSlider extends StatelessWidget {
  SleekCircularSlider(
      {Key? key,
      this.value = 50,
      this.min = 0,
      this.max = 100,
      this.appearance = defaultAppearance,
      this.onChange,
      this.innerWidget})
      : assert(min <= max),
        assert(value >= min && value <= max),
        super(key: key) {
    _setupPainter();
  }

  final double value;
  final double min;
  final double max;
  final CircularSliderAppearance appearance;
  final OnChange? onChange;
  final InnerWidget? innerWidget;
  static const defaultAppearance = CircularSliderAppearance();
  late final _CurvePainter _painter;
  late final double? _currentAngle;

  double get angle => valueToAngle(value, min, max, appearance.angleRange);

  double get _startAngle => appearance.startAngle;

  double get _angleRange => appearance.angleRange;

  void _handlePan(Offset position, Offset center, double radius) {
    final double touchWidth = appearance.progressBarWidth >= 25.0 ? appearance.progressBarWidth : 25.0;
    if (isPointAlongCircle(position, center, radius, touchWidth)) {
      var _selectedAngle = coordinatesToRadians(center, position);

      if (appearance.customDivisions != null) {
        _selectedAngle = _selectedAngle - (_startAngle * math.pi / 180);
        print("Selected angle: ${_selectedAngle}");
        final divisions = appearance.customDivisions!.divisions ?? 5;
        final step = (_angleRange * math.pi / 180.0) / (divisions - 1);
        // -math.pi / 2

        // NOTE: Angle range is degrees
        // Round selected angle to nearest ratio of step
        // + 1.5 -math.pi / 2
        _selectedAngle = ((_selectedAngle / step).floor() * step).clamp(0, _angleRange) + (_startAngle * math.pi / 180);
      }

      _updateOnChange(_selectedAngle);
    }
  }

  void _setupPainter({bool counterClockwise = false}) {
    _currentAngle = calculateAngle(
      startAngle: _startAngle,
      angleRange: _angleRange,
      selectedAngle: null,
      defaultAngle: angle,
      counterClockwise: counterClockwise,
    );

    _painter = _CurvePainter(
      startAngle: _startAngle,
      angleRange: _angleRange,
      angle: _currentAngle! < 0.5 ? 0.5 : _currentAngle!,
      appearance: appearance,
    );
  }

  void _updateOnChange(double _selectedAngle) {
    if (onChange != null) {
      final value = angleToValue(
          calculateAngle(
            startAngle: _startAngle,
            angleRange: _angleRange,
            selectedAngle: _selectedAngle,
            defaultAngle: angle,
            counterClockwise: appearance.counterClockwise,
          ),
          min,
          max,
          _angleRange);
      onChange!(value.clamp(min, max));
    }
  }

  Widget? _buildChildWidget() {
    final value = angleToValue(_currentAngle!, min, max, _angleRange);
    final childWidget = innerWidget != null
        ? innerWidget!(value)
        : SliderLabel(
            value: value,
            appearance: appearance,
          );
    return childWidget;
  }

  Widget _wrapGesture({required Widget child}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Listener(
          onPointerDown: (d) {
            _handlePan(d.localPosition, _painter.center!, _painter.radius);
          },
          onPointerMove: (d) {
            _handlePan(d.localPosition, _painter.center!, _painter.radius);
          },
          child: child,
        );
      },
    );
  }

  Widget _buildPainter({required Size size}) {
    return CustomPaint(
      painter: _painter,
      child: Container(
        width: size.width,
        height: size.height,
        child: _buildChildWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _wrapGesture(child: _buildPainter(size: Size(appearance.size, appearance.size)));
  }
}
