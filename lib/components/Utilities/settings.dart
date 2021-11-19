import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/utils.dart';

import '../../showDialogSuper.dart';

typedef OnChange<T> = void Function(T value);

abstract class SettingsTile<T> extends StatefulWidget {
  String get prefKey;

  @protected
  Future<void> saveSetting(T value) {
    return Settings.setValue(prefKey, value);
  }

  @protected
  T getSetting(T defaultValue) {
    return Settings.getValue<T>(prefKey, defaultValue);
  }
}

class SettingsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  SettingsHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    var elements = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 22.0),
        child: Text(
          title.toUpperCase(),
          style: groupStyle(context),
        ),
      ),
    ];

    if (subtitle != null && subtitle!.isNotEmpty) {
      elements.add(
        Container(
          padding: const EdgeInsets.only(
            top: 6,
            left: 16,
            bottom: 6,
            right: 16,
          ),
          child: Text(subtitle!),
        ),
      );
    } else {
      elements.add(SizedBox(height: 6));
    }
    return Wrap(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: elements,
        )
      ],
    );
  }

  TextStyle groupStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
    );
  }
}

/// A [SettingsTile] that allows the user to select a color.
///
/// The color is saved to the shared preferences using the provided key.
class ColorTile extends SettingsTile<dynamic> {
  final String prefKey;
  final Widget title;
  final Widget? subtitle;
  final Color defaultValue;
  final void Function(Color)? onChange;

  ColorTile({
    this.subtitle,
    this.onChange,
    required this.title,
    required this.prefKey,
    required this.defaultValue,
  });

  @override
  Future<void> saveSetting(dynamic value) {
    return super.saveSetting(ColorSerializer().toJson(value as Color));
  }

  @override
  _ColorTileState createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = ColorSerializer().fromJson(
      (Settings.getValue(
        widget.prefKey,
        ColorSerializer().toJson(widget.defaultValue),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle ?? Text(ColorSerializer().toJson(_color)),
      trailing: GradientCircleAvatar(color: _color),
      onTap: () {
        Color _oldColor = _color;
        showDialogSuper<bool>(
          context: context,
          barrierDismissible: true,
          onDismissed: (val) {
            if (val == null || !val) {
              setState(() {
                _color = _oldColor;
              });
            }
          },
          builder: (context) {
            return AlertDialog(
              title: widget.title,
              content: SingleChildScrollView(
                child: MaterialColorPicker(
                  selectedColor: _color,
                  onColorChange: (color) {
                    setState(() {
                      _color = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(context.materialLocale.cancelButtonLabel),
                  onPressed: () {
                    setState(() {
                      _color = _oldColor;
                    });
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(context.materialLocale.okButtonLabel),
                  onPressed: () {
                    if (widget.onChange != null) widget.onChange!(_color);
                    widget.saveSetting(_color);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// A [SettingsTile] that allows the user to select a value among many.
///
/// The value is saved to the shared preferences using the provided key.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class RadioModalTile<T> extends SettingsTile<T> {
  final String prefKey;
  final Widget title;
  final Widget? subtitle;
  final Map<T, String> values;
  final T defaultValue;
  final OnChange<T>? onChange;

  RadioModalTile({
    this.onChange,
    this.subtitle,
    required this.title,
    required this.values,
    required this.prefKey,
    required this.defaultValue,
  });

  @override
  Future<void> saveSetting(T value) {
    return super.saveSetting(value);
  }

  @override
  T getSetting(T defaultValue) {
    return super.getSetting(defaultValue);
  }

  @override
  _RadioModalTileState<T> createState() => _RadioModalTileState<T>();
}

class _RadioModalTileState<T> extends State<RadioModalTile<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.getSetting(widget.defaultValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle ??
          Text(widget.values[_value.toString()] ?? _value.toString()),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () {
        T _oldValue = _value;
        showDialogSuper<bool>(
          context: context,
          barrierDismissible: true,
          onDismissed: (val) {
            if (val == null || !val) {
              setState(() {
                _value = _oldValue;
              });
            }
          },
          builder: (context) {
            return StatefulBuilder(
              builder: (context, _innerSetState) {
                final _outerSetState = setState;
                final _setState = (void Function() func) {
                  _outerSetState(func);
                  _innerSetState(func);
                };
                return AlertDialog(
                  title: widget.title,
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: widget.values.entries
                          .map(
                            (entry) => RadioListTile<T>(
                              title: Text(entry.value),
                              value: entry.key,
                              groupValue: _value,
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                              onChanged: (value) {
                                _setState(() {
                                  if (value != null) _value = value;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(context.materialLocale.cancelButtonLabel),
                      onPressed: () {
                        _setState(() {
                          _value = _oldValue;
                        });
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(context.materialLocale.okButtonLabel),
                      onPressed: () {
                        widget.saveSetting(_value);
                        print("${widget.onChange.runtimeType}");
                        if (widget.onChange != null) {
                          print("${widget.onChange!.runtimeType}");
                          widget.onChange!(_value);
                        }
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
