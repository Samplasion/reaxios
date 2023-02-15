import 'package:flutter/material.dart';

import '../../../utils/values.dart';

class M3ExpansionPanelList extends StatefulWidget {
  const M3ExpansionPanelList({
    this.children = const <ExpansionPanel>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    super.key,
  });

  /// The children of the expansion panel list. They are laid out in a similar
  /// fashion to [ListBody].
  final List<ExpansionPanel> children;

  /// The callback that gets called whenever one of the expand/collapse buttons
  /// is pressed. The arguments passed to the callback are the index of the
  /// pressed panel and whether the panel is currently expanded or not.
  ///
  /// If ExpansionPanelList.radio is used, the callback may be called a
  /// second time if a different panel was previously open. The arguments
  /// passed to the second callback are the index of the panel that will close
  /// and false, marking that it will be closed.
  ///
  /// For ExpansionPanelList, the callback needs to setState when it's notified
  /// about the closing/opening panel. On the other hand, the callback for
  /// ExpansionPanelList.radio is simply meant to inform the parent widget of
  /// changes, as the radio panels' open/close states are managed internally.
  ///
  /// This callback is useful in order to keep track of the expanded/collapsed
  /// panels in a parent widget that may need to react to these changes.
  final ExpansionPanelCallback? expansionCallback;

  /// The duration of the expansion animation.
  final Duration animationDuration;

  @override
  State<M3ExpansionPanelList> createState() => _M3ExpansionPanelListState();
}

class _M3ExpansionPanelListState extends State<M3ExpansionPanelList> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];

    for (int index = 0; index < widget.children.length; index += 1) {
      final ExpansionPanel child = widget.children[index];
      final Widget headerWidget = child.headerBuilder(
        context,
        _isChildExpanded(index),
      );

      Widget expandIconContainer = Container(
        margin: const EdgeInsetsDirectional.only(end: 8.0),
        child: ExpandIcon(
          isExpanded: _isChildExpanded(index),
          padding: const EdgeInsets.all(16.0),
          onPressed: !child.canTapOnHeader
              ? (bool isExpanded) => _handlePressed(isExpanded, index)
              : null,
        ),
      );
      if (!child.canTapOnHeader) {
        final MaterialLocalizations localizations =
            MaterialLocalizations.of(context);
        expandIconContainer = Semantics(
          label: _isChildExpanded(index)
              ? localizations.expandedIconTapHint
              : localizations.collapsedIconTapHint,
          container: true,
          child: expandIconContainer,
        );
      }
      Widget header = Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: Curves.fastOutSlowIn,
              margin: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: kMinInteractiveDimension),
                child: headerWidget,
              ),
            ),
          ),
          expandIconContainer,
        ],
      );

      final isFirst = index == 0;
      final isLast = index == widget.children.length - 1;
      if (child.canTapOnHeader) {
        header = MergeSemantics(
          child: InkWell(
            borderRadius: RegistroValues.getRadius(isFirst, isLast),
            onTap: () => _handlePressed(_isChildExpanded(index), index),
            child: header,
          ),
        );
      }
      items.add(
        Card(
          margin:
              EdgeInsets.symmetric(vertical: RegistroValues.interCardPadding),
          shape: RoundedRectangleBorder(
            borderRadius: RegistroValues.getRadius(isFirst, isLast),
          ),
          key: ValueKey(index),
          color: child.backgroundColor,
          child: Column(
            children: <Widget>[
              header,
              AnimatedCrossFade(
                firstChild: Container(height: 0.0),
                secondChild: child.body,
                firstCurve:
                    const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                secondCurve:
                    const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                sizeCurve: Curves.fastOutSlowIn,
                crossFadeState: _isChildExpanded(index)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: widget.animationDuration,
              ),
            ],
          ),
        ),
      );
    }
    items.add(
      const SizedBox(
          height: RegistroValues.padding - RegistroValues.interCardPadding),
    );

    return Column(
      children: items,
    );
  }

  bool _isChildExpanded(int index) {
    return widget.children[index].isExpanded;
  }

  _handlePressed(bool isExpanded, int index) {
    widget.expansionCallback?.call(index, isExpanded);
  }
}
