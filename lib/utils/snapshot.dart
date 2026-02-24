import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../i18n/delegate.dart';

Future<Uint8List?> captureWidget(
    BuildContext context, GlobalKey globalKey, Widget widget) async {
  final RenderRepaintBoundary repaintBoundary =
      globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  final RenderView renderView = RenderView(
    view: View.of(context),
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(const Size(1000, 1000)),
      devicePixelRatio: 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final body = MediaQuery(
    data: MediaQuery.of(context),
    child: Theme(
      data: Theme.of(context),
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: widget,
        ),
      ),
    ),
  );
  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: WidgetsApp(
      color: Colors.transparent,
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: body,
      builder: (_, __) => body,
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(pixelRatio: 1);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}
