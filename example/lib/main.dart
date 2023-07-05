import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/src/appearance.dart';
import 'package:sleek_circular_slider/src/circular_slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final tween = ColorTween(begin: Colors.black, end: Colors.transparent);
    return MaterialApp(
        title: 'Sleek Circular Slider',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  startAngle: 250,
                  angleRange: 40,
                  customWidths: CustomSliderWidths(
                    progressBarWidth: 6,
                    handlerSize: scale * 9,
                    shadowWidth: 20,
                    trackWidth: 2,
                    strokeWidth: 1.5,
                  ),
                  customColors: CustomSliderColors(
                    gradientStartAngle: 245,
                    gradientEndAngle: 285,
                    shadowColor: Colors.purpleAccent,
                    progressBarColors: [Colors.pinkAccent, Colors.purple],
                    trackColor: tween.transform(Curves.easeOutQuad.transform(scale)),
                    hideShadow: true,
                    dotFillColor: Color.lerp(Colors.blueAccent, Colors.blueAccent, scale),
                    dotStrokeColor: tween.transform(Curves.easeOutQuad.transform(scale)),
                  ),
                ),
                min: 0.03,
                max: 1,
                value: scale,
                onChange: (double value) {
                  setState(() {
                    scale = value;
                  });
                  // callback providing a value while its being changed (with a pan gesture)
                },
                innerWidget: (double value) {
                  return IgnorePointer(
                    child: Container(),
                  );
                  // use your custom widget inside the slider (gets a slider value from the callback)
                },
              ),
            ),
          ),
        ));
  }
}
