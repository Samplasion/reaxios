import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

part 'AppInfoStore.g.dart';

class AppInfoStore extends _AppInfoStoreBase with _$AppInfoStore {
  static AppInfoStore of(BuildContext context, {bool? listen}) =>
      Provider.of<AppInfoStore>(context, listen: listen ?? true);
}

abstract class _AppInfoStoreBase with Store {
  @observable
  PackageInfo packageInfo = PackageInfo(
    appName: 'Registro',
    packageName: 'com.temp-string.registro',
    version: '0.0.0-temp-string',
    buildNumber: '0',
  );

  @action
  Future<void> getPackageInfo() async {
    Logger.d('getPackageInfo');
    packageInfo = await PackageInfo.fromPlatform();
    Logger.d('PackageInfo: $packageInfo');
  }
}
