import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DollarText extends SpecialText {
  DollarText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {this.start,
      required String startFlag,
      required String endFlag,
      required this.color})
      : super(startFlag, endFlag, textStyle, onTap: onTap);
  final int? start;
  final Color color;
  @override
  InlineSpan finishText() {
    final String text = toString().replaceAll(startFlag, '');

    return ExtendedWidgetSpan(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(8)
        ), child: Text(text),),
        actualText: toString(),
        start: start!,
        deleteAll: true,
        style: textStyle?.copyWith(color: color),
        );
  }
}

List<String> dollarList = <String>[
  '\$Dota2\$',
  '\$Dota2 Ti9\$',
  '\$CN dota best dota\$',
  '\$Flutter\$',
  '\$CN dev best dev\$',
  '\$UWP\$',
  '\$Nevermore\$',
  '\$FlutterCandies\$',
  '\$ExtendedImage\$',
  '\$ExtendedText\$',
];
