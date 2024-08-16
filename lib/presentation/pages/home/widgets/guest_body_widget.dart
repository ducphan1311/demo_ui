import 'package:flutter/material.dart';
import 'package:flutter_all_platform_template/design_system_widgets/form_field/auto_complete_text_field.dart';

class GuestBodyWidget extends StatefulWidget {
  const GuestBodyWidget({Key? key, required this.defaultData})
      : super(key: key);
  final String defaultData;

  @override
  GuestBodyWidgetState createState() => GuestBodyWidgetState();
}

class GuestBodyWidgetState extends State<GuestBodyWidget> {
  final key = GlobalKey<AutoCompleteTextFieldState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: AutoCompleteTextField(key: key, onSearching: (String query) {
            return ['a', 'b', 'c', 'd'].map((e) => Item(e)).toList();
          },),),
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
