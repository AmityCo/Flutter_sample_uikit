import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';

class CustomRadioBox<T> extends StatelessWidget {
  const CustomRadioBox({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);
  final String title;
  final String description;
  final Widget icon;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Radio<T>(
        value: value,
        activeColor: context.watch<AmityUIConfiguration>().primaryColor,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}
