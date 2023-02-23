import 'package:flutter/material.dart';
import 'package:axios_api/entities/School/School.dart';
import 'package:reaxios/utils/utils.dart';

class SchoolListItem extends StatelessWidget {
  const SchoolListItem(
      {Key? key,
      required this.school,
      required this.selected,
      required this.onClick})
      : super(key: key);

  final School school;
  final bool selected;
  final void Function() onClick;

  @override
  Widget build(BuildContext context) {
    final bg =
        selected ? Theme.of(context).colorScheme.secondary : Colors.grey[700]!;
    return ListTile(
      leading: CircleAvatar(
        child: Icon(selected ? Icons.check : Icons.school),
        backgroundColor: bg,
        foregroundColor: bg.contrastText,
      ),
      title: Text("${school.title} ${school.name}"),
      subtitle: Text(
          '${school.zipCode} ${school.city}, ${school.province} (${school.region})'),
      onTap: onClick,
    );
  }
}
