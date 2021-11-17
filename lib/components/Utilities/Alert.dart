import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:styled_widget/styled_widget.dart';

class Alert extends StatelessWidget {
  Alert({
    Key? key,
    required this.title,
    this.text,
    this.color = Colors.blue,
    this.selectable = false,
  }) : super(key: key);

  final String title;
  final Widget? text;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color[dark ? 300 : 700],
                      ),
                    ),
                    if (text != null) ...[
                      if (text is RichText)
                        selectable
                            ? SelectableText.rich(
                                TextSpan(
                                  children: [(text as RichText).text],
                                  style:
                                      TextStyle(color: color[dark ? 200 : 900]),
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  children: [(text as RichText).text],
                                  style:
                                      TextStyle(color: color[dark ? 200 : 900]),
                                ),
                              )
                      else if (text is Markdown)
                        Markdown(
                          data: (text as Markdown).data,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: color[dark ? 200 : 900]),
                          ),
                        )
                      else if (text is MarkdownBody)
                        MarkdownBody(
                          data: (text as MarkdownBody).data,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: color[dark ? 200 : 900]),
                          ),
                        )
                      else
                        text!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
