import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:reaxios/api/utils/ColorSerializer.dart';
import 'package:reaxios/components/LowLevel/GradientCircleAvatar.dart';
import 'package:reaxios/components/Utilities/AlertBottomSheet.dart';
import 'package:reaxios/timetable/structures/Settings.dart';
import 'package:reaxios/utils/utils.dart';
import 'package:reaxios/utils/values.dart';

import '../../timetable/showModalBottomSheetSuper.dart';
import '../../../../utils/showDialogSuper.dart';

typedef OnChange<T> = void Function(T value);

abstract class BaseSettings extends StatelessWidget {
  const BaseSettings({Key? key}) : super(key: key);

  List<SettingsTile> getTiles(
      BuildContext context, Settings settings, Function setState);

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) =>
          StatefulBuilder(builder: (context, setState) {
        return ListView(
          children: [
            ...getTiles(context, settings, setState),
            SizedBox(height: 16)
          ],
        );
      }),
    );
  }

  String getDescription(BuildContext context) {
    Settings settings = Provider.of<Settings>(context, listen: false);
    return getTiles(context, settings, () {})
        .where((element) => element.shouldShowInDescription)
        .map((e) {
          if (e is SettingsTileGroup) {
            return e.getDescription(context);
          }
          return (e.title as Text).data;
        })
        .where((element) => element?.trim().isNotEmpty ?? false)
        .join(', ');
  }
}

abstract class SettingsTile extends StatefulWidget {
  Widget get title;

  bool get shouldShowInDescription => true;
  bool get build => true;

  const SettingsTile({Key? key}) : super(key: key);
}

class _EmptySentinel extends StatelessWidget {
  const _EmptySentinel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 0, height: 0);
  }
}

class SettingsTileGroup extends SettingsTile {
  @override
  final Widget title;
  final List<SettingsTile> children;

  const SettingsTileGroup({
    this.title = const _EmptySentinel(),
    required this.children,
    super.key,
  });

  @override
  State<SettingsTileGroup> createState() => _SettingsTileGroupState();

  String getDescription(BuildContext context) {
    return children
        .where((element) => element.shouldShowInDescription)
        .map((e) => (e.title as Text).data)
        .join(', ');
  }
}

class _SettingsTileGroupState extends State<SettingsTileGroup> {
  @override
  Widget build(BuildContext context) {
    List<Widget> mappedWidgets = [];

    for (int i = 0; i < widget.children.length; i++) {
      mappedWidgets.add(
        AnimatedCrossFade(
          crossFadeState: widget.children[i].build.crossFadeState,
          firstChild: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: RegistroValues.interCardPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: RegistroValues.getRadius(
                  i == 0,
                  i == widget.children.length - 1,
                  largeRadius: 30,
                  smallRadius: 4,
                ),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                alignment: Alignment.center,
                child: Material(
                  type: MaterialType.transparency,
                  child: widget.children[i],
                ),
              ),
            ),
          ),
          secondChild: Container(),
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeOut,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title is! _EmptySentinel)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: widget.title,
          ),
        ...mappedWidgets,
      ],
    );
  }
}

class _SettingsTileGroupTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTap;
  final bool isThreeLine;

  const _SettingsTileGroupTile({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
      minVerticalPadding: 16,
      title: title,
      subtitle: subtitle,
      leading: leading == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [leading!],
            ),
      trailing: trailing == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [trailing!],
            ),
      onTap: onTap,
      isThreeLine: isThreeLine,
    );
  }
}

class SwitchSettingsTile extends SettingsTile {
  @override
  final Widget title;
  final Widget? subtitle;
  final OnChange<bool> onChange;
  final bool value;

  const SwitchSettingsTile({
    required this.title,
    this.subtitle,
    required this.onChange,
    required this.value,
    super.key,
  });

  @override
  State<SwitchSettingsTile> createState() => _SwitchSettingsTileState();
}

class _SwitchSettingsTileState extends State<SwitchSettingsTile> {
  final key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: Switch(
        key: key,
        value: widget.value,
        onChanged: widget.onChange,
        activeColor: Theme.of(context).colorScheme.tertiary,
        thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
          if (states.contains(MaterialState.selected)) {
            return Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.onTertiary,
            );
          }
          return const Icon(Icons.close);
        }),
      ),
      onTap: () => widget.onChange(!widget.value),
    );
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

/// A [SettingsTile] that allows the user to select a value among many.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class RadioModalTile<T> extends SettingsTile {
  @override
  final Text title;
  final Widget? subtitle;
  final Map<T, String> values;
  final T selectedValue;
  final OnChange<T>? onChange;

  const RadioModalTile({
    this.onChange,
    this.subtitle,
    required this.title,
    required this.values,
    required this.selectedValue,
  });

  @override
  _RadioModalTileState<T> createState() => _RadioModalTileState<T>();
}

class _RadioModalTileState<T> extends State<RadioModalTile<T>>
    with SingleTickerProviderStateMixin {
  late T _value = widget.selectedValue;
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 500));

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get subtitle {
    final entries = widget.values.entries;
    if (entries.any((element) => element.key == widget.selectedValue)) {
      return entries
          .firstWhere((element) => element.key == widget.selectedValue)
          .value;
    } else {
      return widget.selectedValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle ?? Text(subtitle),
      trailing: Icon(Icons.arrow_right_rounded),
      onTap: () {
        T _oldValue = widget.selectedValue;
        showModalBottomSheetSuper<bool>(
          context: context,
          closeOnScroll: true,
          scrollController: _scrollController,
          onDismissed: (result) {
            if (result == null || !result) {
              widget.onChange?.call(_oldValue);
              setState(() {
                _value = _oldValue;
              });
            }
          },
          // height: ,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, _innerSetState) {
                final _outerSetState = setState;
                void _setState(void Function() func) {
                  _innerSetState(func);
                  _outerSetState(func);
                }

                return AlertBottomSheet(
                  enableDrag: true,
                  animationController: _animationController,
                  scrollable: true,
                  title: widget.title,
                  content: Column(
                    children: [
                      for (final entry in widget.values.entries)
                        RadioListTile<T>(
                          title: Text(entry.value),
                          value: entry.key,
                          groupValue: _value,
                          activeColor: Theme.of(context).colorScheme.secondary,
                          onChanged: (value) {
                            _setState(() {
                              if (value != null) {
                                _value = value;
                                widget.onChange?.call(value);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text("CANCEL"),
                      onPressed: () {
                        // _setState(() {
                        //   widget.selectedValue = _oldValue;
                        // });
                        widget.onChange?.call(_oldValue);
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        if (widget.onChange != null) {
                          widget.onChange!(widget.selectedValue);
                        }
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                  onClosing: () {
                    setState(() {});
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// A [ListTile] that is also a [SettingsTile].
///
/// This is used to add a [ListTile] to [BaseSettings.getTiles].
/// Each argument is passed to the [ListTile] constructor.
class ListSettingsTile extends SettingsTile {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTap;

  const ListSettingsTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  State<ListSettingsTile> createState() => _ListSettingsTileState();
}

class _ListSettingsTileState extends State<ListSettingsTile> {
  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}

/// A [SettingsTile] that allows the user to select one or more values among many.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class CheckboxModalTile<T> extends SettingsTile {
  @override
  final Text title;
  final Widget? subtitle;
  final Map<T, String> values;
  final List<T> selectedValues;
  final OnChange<List<T>>? onChange;
  final bool allowNone;

  CheckboxModalTile({
    this.onChange,
    this.subtitle,
    required this.title,
    required this.values,
    required this.selectedValues,
    this.allowNone = false,
  });

  @override
  _CheckboxModalTileState<T> createState() => _CheckboxModalTileState<T>();
}

class _CheckboxModalTileState<T> extends State<CheckboxModalTile<T>> {
  late List<T> _value = widget.selectedValues;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<T, bool> get _selectedValues {
    return widget.values.map((key, value) {
      return MapEntry(key, _value.contains(key));
    });
  }

  List<T> _mapToList(Map<T, bool> value) {
    return value.entries
        .where((element) => element.value)
        .map((element) => element.key)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle ??
          Text(
            _value.map((element) => widget.values[element]).join(", "),
          ),
      trailing: Icon(Icons.arrow_right_rounded),
      onTap: () {
        List<T> _oldValue = widget.selectedValues;
        showModalBottomSheetSuper<bool>(
          context: context,
          closeOnScroll: true,
          scrollController: _scrollController,
          onDismissed: (result) {
            if (result == null || !result) {
              widget.onChange?.call(_oldValue);
              setState(() {
                _value = _oldValue;
              });
            }
          },
          builder: (context) {
            return StatefulBuilder(
              builder: (context, _innerSetState) {
                final _outerSetState = setState;
                void _setState(void Function() func) {
                  _innerSetState(func);
                  _outerSetState(func);
                }

                return BottomSheet(
                  onClosing: () {},
                  builder: (context) => StatefulBuilder(
                    builder: (context, setState) => Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              widget.title.data!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 900,
                            child: SingleChildScrollView(
                              child: ListBody(
                                children: widget.values.entries
                                    .map(
                                      (entry) => CheckboxListTile(
                                        title: Text(entry.value),
                                        value: _selectedValues[entry.key],
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        onChanged: (value) {
                                          final shouldSet =
                                              (_value.length >= 2 ||
                                                  widget.allowNone);
                                          if (value != null &&
                                              (value || shouldSet)) {
                                            _setState(() {
                                              final newValue = _mapToList({
                                                ..._selectedValues,
                                                entry.key: value,
                                              });
                                              _value = newValue;
                                              widget.onChange?.call(newValue);
                                            });
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text("CANCEL"),
                                  onPressed: () {
                                    // _setState(() {
                                    //   widget.selectedValues = _oldValue;
                                    // });
                                    widget.onChange?.call(_oldValue);
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    print("${widget.onChange.runtimeType}");
                                    if (widget.onChange != null) {
                                      print("${widget.onChange!.runtimeType}");
                                      widget.onChange!(widget.selectedValues);
                                    }
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// A [SettingsTile] that allows the user to select one or more values among many.
///
/// The values are displayed using the labels provided. If no label is provided
/// for a value, the value is displayed instead.
class TextFormFieldModalTile extends SettingsTile {
  @override
  final Widget title;
  final Widget? subtitle;
  final String value;
  final OnChange<String> onChange;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;

  const TextFormFieldModalTile({
    Key? key,
    required this.onChange,
    this.subtitle,
    this.validator,
    this.decoration = const InputDecoration(),
    this.textCapitalization = TextCapitalization.none,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  _TextFormFieldModalTileState createState() => _TextFormFieldModalTileState();
}

class _TextFormFieldModalTileState extends State<TextFormFieldModalTile> {
  late String _value = widget.value;
  late TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _value);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle ?? Text(_value),
      trailing: Icon(Icons.arrow_right_rounded),
      onTap: () {
        String _oldValue = widget.value;
        showDialogSuper<bool>(
          context: context,
          barrierDismissible: true,
          onDismissed: (result) {
            if (result == null || !result) {
              widget.onChange(_oldValue);
              setState(() {
                _value = _oldValue;
                _controller.text = _value;
              });
            }
          },
          builder: (context) {
            return StatefulBuilder(
              builder: (context, _innerSetState) {
                final _outerSetState = setState;
                void _setState(void Function() func) {
                  _innerSetState(func);
                  _outerSetState(func);
                }

                return AlertDialog(
                  title: widget.title,
                  content: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: TextFormField(
                      controller: _controller,
                      validator: widget.validator ?? (_) => null,
                      decoration: widget.decoration,
                      textCapitalization: widget.textCapitalization,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (value) {
                        _setState(() {
                          _value = value;
                          // _controller.text = _value;
                        });
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text("CANCEL"),
                      onPressed: () {
                        widget.onChange(_oldValue);
                        _setState(() {
                          _value = _oldValue;
                          _controller.text = _value;
                        });
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text("OK"),
                      onPressed: _formKey.currentState?.validate() ?? false
                          ? () {
                              widget.onChange(_value);
                              Navigator.of(context).pop(true);
                            }
                          : null,
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

/// A [SettingsTile] that allows the user to select a color.
///
/// The color is saved to the shared preferences using the provided key.
class ColorTile extends SettingsTile {
  @override
  final Widget title;
  final Widget? subtitle;
  final Color value;
  final OnChange<Color> onChange;

  const ColorTile({
    Key? key,
    required this.onChange,
    this.subtitle,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  _ColorTileState createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
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
                    widget.onChange(_color);
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

class SettingsHeaderTile extends SettingsTile {
  @override
  final Text title;
  final String? subtitle;

  @override
  bool get shouldShowInDescription => false;

  const SettingsHeaderTile({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  _SettingsHeaderTileState createState() => _SettingsHeaderTileState();
}

class _SettingsHeaderTileState extends State<SettingsHeaderTile> {
  @override
  Widget build(BuildContext context) {
    return SettingsHeader(title: widget.title.data!, subtitle: widget.subtitle);
  }
}

class SettingsListTile extends SettingsTile {
  @override
  final Widget title;
  final VoidCallback onTap;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isThreeLine;

  @override
  final bool shouldShowInDescription;

  const SettingsListTile({
    Key? key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.shouldShowInDescription = false,
    this.isThreeLine = false,
  }) : super(key: key);

  @override
  _SettingsListTileState createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> {
  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      onTap: widget.onTap,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing,
      isThreeLine: widget.isThreeLine,
    );
  }
}

class SubscreenListTile extends SettingsTile {
  @override
  final Widget title;
  final Widget Function(BuildContext) builder;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  final bool shouldShowInDescription;

  const SubscreenListTile({
    Key? key,
    required this.title,
    required this.builder,
    this.subtitle,
    this.leading,
    this.trailing,
    this.shouldShowInDescription = true,
  }) : super(key: key);

  @override
  _SubscreenListTileState createState() => _SubscreenListTileState();
}

class _SubscreenListTileState extends State<SubscreenListTile> {
  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing ?? Icon(Icons.arrow_right_rounded),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: widget.builder,
          ),
        );
      },
    );
  }
}

class SliderListTile extends SettingsTile {
  @override
  final Widget title;
  final Widget? leading;
  final double min;
  final double max;
  final double value;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const SliderListTile({
    super.key,
    required this.title,
    this.leading,
    required this.min,
    required this.max,
    required this.value,
    this.divisions,
    required this.onChanged,
  });

  @override
  State<SliderListTile> createState() => _SliderListTileState();
}

class _SliderListTileState extends State<SliderListTile> {
  @override
  Widget build(BuildContext context) {
    return _SettingsTileGroupTile(
      title: widget.title,
      subtitle: Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        onChanged: widget.onChanged,
        inactiveColor: Theme.of(context).colorScheme.background,
        label: widget.value.toString(),
        divisions: widget.divisions,
      ),
      leading: widget.leading,
    );
  }
}

class ConditionalListTile extends SettingsTile {
  final SettingsTile child;
  final bool show;

  @override
  Widget get title => child.title;

  @override
  bool get build => show;

  @override
  bool get shouldShowInDescription => child.shouldShowInDescription && show;

  const ConditionalListTile({
    super.key,
    required this.show,
    required this.child,
  });

  @override
  State<ConditionalListTile> createState() => _ConditionalListTileState();
}

class _ConditionalListTileState extends State<ConditionalListTile> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
