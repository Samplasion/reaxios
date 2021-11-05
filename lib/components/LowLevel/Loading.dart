import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingUI extends StatelessWidget {
  const LoadingUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SpinKitDualRing(
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
