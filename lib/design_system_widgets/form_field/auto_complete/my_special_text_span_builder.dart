import 'dart:developer';

import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/material.dart';

import 'at_text.dart';
import 'dollar_text.dart';
import 'emoji_text.dart';
import 'image_text.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.showAtBackground = true});

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    log('createSpecialText: $flag -- $index');
    if (flag == '') {
      return null;
    }

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle,
          start: index! - (ImageText.flag.length - 1), onTap: onTap);
    }
    // else if (isStart(flag, '#')) {
    //   return AtText(
    //     textStyle,
    //     onTap,
    //     start: index!,
    //     showAtBackground: showAtBackground,
    //     flag: '#',
    //   );
    // }
    else if (isStart(flag, '@')) {
      return AtText(
        textStyle,
        onTap,
        start: index!,
        showAtBackground: showAtBackground,
        flag: '@',
      );
    }
    else if (isStart(flag, r'$')) {
      return DollarText(textStyle, onTap,
          start: index, startFlag: r'$', endFlag:  r'$', color: const Color(
              0xff108ccf));
    }
    // else if (isStart(flag, '%%%')) {
    //   return DollarText(textStyle, onTap,
    //       start: index, startFlag: '%%%', endFlag: '', color: const Color(
    //           0xff0da79f));
    // }
    return null;
  }
}
