import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reaxios/utils/utils.dart';

class AlertColor {
  Color foreground;
  Color background;

  AlertColor(this.background, this.foreground);

  factory AlertColor.fromMaterialColor(
    BuildContext context,
    MaterialColor color,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fgShade = dark ? 200 : 900;

    return AlertColor(
      dark ? color[400]!.withOpacity(25 / 255) : color[100]!,
      color[fgShade]!,
    );
  }

  factory AlertColor.secondary(context) => AlertColor(
        Theme.of(context).colorScheme.secondaryContainer,
        Theme.of(context).colorScheme.onSecondaryContainer,
      );

  factory AlertColor.tertiary(context) => AlertColor(
        Theme.of(context).colorScheme.tertiaryContainer,
        Theme.of(context).colorScheme.onTertiaryContainer,
      );
}

class Alert extends StatelessWidget {
  Alert({
    Key? key,
    required this.title,
    this.text,
    dynamic color,
    this.selectable = false,
    this.textBuilder,
  })  : assert((text == null) != (textBuilder == null),
            "Either text or textBuilder must be null, but not both"),
        assert(
          color == null || (color is AlertColor || color is MaterialColor),
          "color must be either a MaterialColor or an AlertColor. You provided: " +
              color.runtimeType.toString(),
        ),
        this._color = color,
        super(key: key);

  final String title;
  final Widget? text;
  final Widget? Function(BuildContext context)? textBuilder;
  final dynamic _color;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final color = this._color == null
        ? AlertColor.fromMaterialColor(
            context, Colors.blue.harmonizeWith(context))
        : this._color is MaterialColor
            ? AlertColor.fromMaterialColor(
                context, (_color as MaterialColor).harmonizeWith(context))
            : _color as AlertColor;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: color.background,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Builder(
            builder: (context) {
              final txt = text ?? textBuilder!(context);
              double textOpacity = 0.86;
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: txt == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 8),
                    child: Icon(
                      Icons.info_outline,
                      color: color.foreground,
                    ),
                  ),
                  Expanded(
                    child: Theme(
                      data: ThemeData(
                        textTheme: Theme.of(context).textTheme.copyWith(
                              bodyText2: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: color.foreground,
                                  ),
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color.foreground,
                            ),
                          ),
                          if (txt != null) ...[
                            if (txt is RichText)
                              selectable
                                  ? SelectableText.rich(
                                      TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                          color: color.foreground
                                              .withOpacity(textOpacity),
                                        ),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                          color: color.foreground
                                              .withOpacity(textOpacity),
                                        ),
                                      ),
                                    )
                            else if (txt is Markdown)
                              Markdown(
                                data: txt.data,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                      color: color.foreground
                                          .withOpacity(textOpacity)),
                                ),
                              )
                            else if (txt is MarkdownBody)
                              MarkdownBody(
                                data: txt.data,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                      color: color.foreground
                                          .withOpacity(textOpacity)),
                                ),
                              )
                            else
                              txt,
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
