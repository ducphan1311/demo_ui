import 'dart:developer';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auto_complete/my_special_text_span_builder.dart';



typedef AutoCompleteOverlayItemBuilder<T> = Widget Function(
    BuildContext context, T suggestion);

typedef Filter<T> = bool Function(T suggestion, String query);

typedef InputEventCallback<T> = Function(T data);

typedef StringCallback = Function(String data);

class AutoCompleteTextField<T extends AutoCompleteItem> extends StatefulWidget {
  final StringCallback? textChanged, textSubmitted;
  final ValueSetter<bool>? onFocusChanged;
  final int suggestionsAmount;
  @override
  final GlobalKey<AutoCompleteTextFieldState<T>>? key;
  final bool submitOnSuggestionTap, clearOnSubmit, unFocusOnItemSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int minLength;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final bool? showCursor;
  final bool autofocus;
  final bool autocorrect;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool showOnTop;
  final List<T> Function(String query) onSearching;

  const AutoCompleteTextField({
    this.key, //GlobalKey used to enable addSuggestion etc
    this.inputFormatters,
    this.style,
    this.decoration,
    this.textChanged, //Callback on input text changed, this is a string
    this.textSubmitted, //Callback on input text submitted, this is also a string
    this.onFocusChanged,
    this.cursorRadius,
    this.cursorWidth,
    this.cursorColor,
    this.showCursor,
    this.keyboardType = TextInputType.text,
    this.suggestionsAmount =
    5, //The amount of suggestions to show, larger values may result in them going off screen
    this.submitOnSuggestionTap =
    true, //Call textSubmitted on suggestion tap, itemSubmitted will be called no matter what
    this.clearOnSubmit = false, //Clear autoCompleteTextfield on submit
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.sentences,
    this.autocorrect =
    false, //set the autoroccection on the internal text input field
    this.minLength = 1,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.unFocusOnItemSubmitted = true,
    this.hintText,
    this.minLines,
    this.maxLines,
    this.showOnTop = false,
    required this.onSearching,
  }) : super(key: key);

  @override
  AutoCompleteTextFieldState<T> createState() => AutoCompleteTextFieldState<T>();
}

class AutoCompleteTextFieldState<T extends AutoCompleteItem> extends State<AutoCompleteTextField<T>> {
  // final postCreateController = Get.find<CommunityPostCreateController>();
  final LayerLink _layerLink = LayerLink();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
  MySpecialTextSpanBuilder()
    ..createSpecialText('', onTap: (p) {
    });

  final key = GlobalKey<ExtendedTextFieldState>();
  OverlayEntry? listSuggestionsEntry;
  List<T>? filteredSuggestions;
  late TextEditingController controller;
  late FocusNode focusNode;
  String currentText = '';

  Widget _buildTextField(BuildContext context) {
    return ExtendedTextField(
      key: key,
      specialTextSpanBuilder: _mySpecialTextSpanBuilder,
      minLines: widget.minLines ?? 2,
      maxLines: widget.maxLines ?? 7,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      decoration: widget.decoration ??
          InputDecoration(
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: widget.hintText,
          ),
      style: widget.style,
      cursorColor: widget.cursorColor ?? Colors.black,
      showCursor: true,
      cursorWidth: widget.cursorWidth ?? 1,
      cursorRadius: widget.cursorRadius ?? const Radius.circular(2.0),
      keyboardType: widget.keyboardType,
      focusNode: focusNode,
      autofocus: widget.autofocus,
      controller: controller,
      textInputAction: widget.textInputAction,
      autocorrect: widget.autocorrect,
      onChanged: (newText) {
        //region handle overlay
        if (listSuggestionsEntry?.mounted == true) {
          listSuggestionsEntry?.remove();
        }
        currentText = newText;
        if (currentText.split(' ').last.contains('#')) {
          updateOverlay(context: context, query: currentText.split('#').last);
        } else if (currentText.split(' ').last.contains('@')) {
          updateOverlay(context: context, query: currentText.split('@').last);
        } else {
          filteredSuggestions = [];
        }
        //endregion

        if (widget.textChanged != null) {
          widget.textChanged!(newText);
        }
      },
      onSubmitted: (submittedText) =>
          triggerSubmitted(submittedText: submittedText),
    );
  }

  void triggerSubmitted({submittedText}) {
    if (widget.textSubmitted != null) {
      submittedText == null
          ? widget.textSubmitted!(currentText)
          : widget.textSubmitted!(submittedText);
    }

    if (widget.clearOnSubmit) {
      clear();
    }
  }

  void clear() {
    controller.clear();
    currentText = '';
    // updateOverlay();
  }

  Future updateOverlay({String? query, required BuildContext context}) async {
    filteredSuggestions = await getUserSuggestions();
    if (filteredSuggestions != null) {
      final Size textFieldSize = (context.findRenderObject() as RenderBox).size;
      final width = textFieldSize.width;
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      Offset position =
      box.localToGlobal(Offset.zero); //this is global position
      double y = position.dy;
      listSuggestionsEntry = OverlayEntry(builder: (context) {
        return Positioned(
            width: width,
            child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, y - 60),
                child: SizedBox(
                    width: width,
                    child: Card(
                        child: Column(
                          children: filteredSuggestions!.map((suggestion) {
                            return Row(children: [
                              Expanded(
                                  child: InkWell(
                                      child: Container(
                                        color: const Color(0XFF000512),
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        'https://images.unsplash.com/photo-1506765515384-028b60a970df?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8YmFubmVyfGVufDB8fDB8fA%3D%3D&w=1000&q=80'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children:
                                                      highlightOccurrences(
                                                          suggestion.name,
                                                          query ?? '',
                                                          color: const Color(
                                                              0xff0da79f)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (!mounted) return;
                                        final texts =
                                        suggestion.name.split(' ');
                                        String newText = '';
                                        for (final e in texts ?? <String>[]) {
                                          newText += '\$$e\$ ';
                                        }
                                        controller.text = controller.text
                                            .replaceFirst(
                                            '@${controller.text.split(' ').last.split('@').last}',
                                            newText,
                                            controller.text
                                                .lastIndexOf('@'));
                                        controller.selection =
                                            TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: controller
                                                        .text.length));
                                        filteredSuggestions = [];
                                        listSuggestionsEntry?.remove();
                                      }))
                            ]);
                          }).toList(),
                        )))));
      });
      Overlay.of(context).insert(listSuggestionsEntry!);
    }

    listSuggestionsEntry?.markNeedsBuild();
  }

  List<TextSpan> highlightOccurrences(String source, String query,
      {Color? color}) {
    if (query.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }

    final List<Match> matches = <Match>[];
    for (final String token in query.trim().toLowerCase().split(' ')) {
      matches.addAll(token.allMatches(source.toLowerCase()));
    }

    if (matches.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }
    matches.sort((Match a, Match b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    final List<TextSpan> children = <TextSpan>[];
    const Color matchColor = Color(0xFF285385);
    for (final Match match in matches) {
      if (match.end <= lastMatchEnd) {
        // already matched -> ignore
      } else if (match.start <= lastMatchEnd) {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.end),
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color ?? matchColor,
              fontSize: 14),
        ));
      } else {
        children.add(TextSpan(
          text: source.substring(lastMatchEnd, match.start),
        ));

        children.add(TextSpan(
          text: source.substring(match.start, match.end),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: color ?? matchColor),
        ));
      }

      if (lastMatchEnd < match.end) {
        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < source.length) {
      children.add(TextSpan(
        text: source.substring(lastMatchEnd, source.length),
      ));
    }

    return children;
  }

  Future<List<T>> getUserSuggestions() async {
    final keyword =
    controller.text.split(' ').last.replaceAll('@', '');
    return widget.onSearching(keyword);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      if (widget.onFocusChanged != null) {
        widget.onFocusChanged!(focusNode.hasFocus);
      }

      if (focusNode.hasFocus) {
        filteredSuggestions = [];
        // userFilteredSuggestions = [];
        // updateOverlay();
      } else if (currentText != '') {
        // updateOverlay(query: currentText);
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: _layerLink, child: _buildTextField(context));
  }
}

abstract class AutoCompleteItem {
  String get name;
}
