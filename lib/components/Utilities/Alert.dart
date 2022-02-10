import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Alert extends StatelessWidget {
  Alert({
    Key? key,
    required this.title,
    this.text,
    this.color = Colors.blue,
    this.selectable = false,
    this.textBuilder,
  })  : assert((text == null) != (textBuilder == null),
            "Either text or textBuilder must be null, but not both"),
        super(key: key);

  final String title;
  final Widget? text;
  final Widget? Function(BuildContext context)? textBuilder;
  final MaterialColor color;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: dark ? color[400]?.withOpacity(25 / 255) : color[100],
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 8),
                child: Icon(
                  Icons.info_outline,
                  color: color[dark ? 600 : 300],
                ),
              ),
              Expanded(
                child: Theme(
                  data: ThemeData(
                    textTheme: Theme.of(context).textTheme.copyWith(
                          bodyText2:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: color[dark ? 200 : 900],
                                  ),
                        ),
                  ),
                  child: Builder(
                    builder: (context) {
                      final txt = text ?? textBuilder!(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color[dark ? 300 : 700],
                            ),
                          ),
                          if (txt != null) ...[
                            if (txt is RichText)
                              selectable
                                  ? SelectableText.rich(
                                      TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                            color: color[dark ? 200 : 900]),
                                      ),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [txt.text],
                                        style: TextStyle(
                                            color: color[dark ? 200 : 900]),
                                      ),
                                    )
                            else if (txt is Markdown)
                              Markdown(
                                data: txt.data,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: color[dark ? 200 : 900]),
                                ),
                              )
                            else if (txt is MarkdownBody)
                              MarkdownBody(
                                data: txt.data,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: color[dark ? 200 : 900]),
                                ),
                              )
                            else
                              txt,
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
