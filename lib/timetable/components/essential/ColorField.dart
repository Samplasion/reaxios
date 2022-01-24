import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:reaxios/timetable/extensions.dart';
import 'package:reaxios/timetable/structures/Event.dart';
import 'package:reaxios/timetable/utils.dart';

import 'MaybeOverflowText.dart';

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
            colors: color.toSlightGradient(),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        // duration: Duration(milliseconds: 300),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () async {
              // Wait for the dialog to return color selection result.
              final Color newColor = await showColorPickerDialog(
                // The dialog needs a context, we pass it in.
                context,
                // We use the dialogSelectColor, as its starting color.
                widget.color,
                title: Text('Color Picker',
                    style: Theme.of(context).textTheme.headline6),
                width: 40,
                height: 40,
                spacing: 0,
                runSpacing: 0,
                borderRadius: 0,
                wheelDiameter: 165,
                enableOpacity: true,
                showColorCode: true,
                colorCodeHasColor: true,
                pickersEnabled: <ColorPickerType, bool>{
                  ColorPickerType.wheel: true,
                },
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyButton: true,
                  pasteButton: true,
                  longPressMenu: true,
                ),
                actionButtons: const ColorPickerActionButtons(
                  okButton: true,
                  closeButton: true,
                  dialogActionButtons: false,
                ),
                constraints: const BoxConstraints(
                    minHeight: 480, minWidth: 320, maxWidth: 320),
              );
              // We update the dialogSelectColor, to the returned result
              // color. If the dialog was dismissed it actually returns
              // the color we started with. The extra update for that
              // below does not really matter, but if you want you can
              // check if they are equal and skip the update below.
              setState(() {
                this.newColor = newColor;
              });
              widget.onChange(newColor);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              // duration: Duration(milliseconds: 300),
              child: Text("Select color", style: baseStyle),
            ),
          ),
        ),
      ),
    );
  }
}
