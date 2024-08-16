import 'package:flutter/material.dart';

import '../../../../design_system_widgets/form_field/auto_complete_text_field.dart';

class HomeBodyWidget extends StatefulWidget {
  const HomeBodyWidget({Key? key, required this.defaultData}) : super(key: key);
  final String defaultData;

  @override
  HomeBodyWidgetState createState() => HomeBodyWidgetState();
}

class HomeBodyWidgetState extends State<HomeBodyWidget> {
  final key = GlobalKey<AutoCompleteTextFieldState<Item>>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoCompleteTextField<Item>(
            key: key,
            onSearching: (String query) {
              return ['a', 'b', 'c', 'd'].map((e) => Item(e)).toList();
            },
          ),
          Text(widget.defaultData),
        ],
      ),
    );
  }
}

class Item extends AutoCompleteItem {
  @override
  String name;

  Item(this.name);
}
