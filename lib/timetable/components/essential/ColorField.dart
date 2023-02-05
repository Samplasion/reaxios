import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/utils.dart';
import 'package:reaxios/utils/utils.dart';

import '../../../utils/showDialogSuper.dart';

class ColorField extends StatefulWidget {
  ColorField(
    this.color, {
    Key? key,
    required this.onChange,
  }) : super(key: key);

  final Color color;
  final void Function(Color) onChange;

  @override
  _ColorFieldState createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  late Color newColor;

  @override
  void initState() {
    super.initState();
    newColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return getBase(context);
  }

  Widget getBase(BuildContext context) {
    final color = widget.color;
    final fg = getContrastColor(color);
    final baseStyle = TextStyle(color: fg);

    return Card(
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: color.toSlightGradient(context),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        // duration: Duration(milliseconds: 300),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () async {
              Color _oldColor = newColor;
              showDialogSuper<bool>(
                context: context,
                barrierDismissible: true,
                onDismissed: (val) {
                  if (val == null || !val) {
                    setState(() {
                      newColor = _oldColor;
                      widget.onChange(newColor);
                    });
                  }
                },
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      context.loc.translate("timetable.colorPicker"),
                    ),
                    content: SingleChildScrollView(
                      child: MaterialColorPicker(
                        selectedColor: newColor,
                        onColorChange: (color) {
                          setState(() {
                            newColor = color;
                            widget.onChange(color);
                          });
                        },
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(context.materialLocale.cancelButtonLabel),
                        onPressed: () {
                          setState(() {
                            newColor = _oldColor;
                            widget.onChange(newColor);
                          });
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(context.materialLocale.okButtonLabel),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.all(16),
              // duration: Duration(milliseconds: 300),
              child: Text(
                context.loc.translate("timetable.colorPicker"),
                style: baseStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
