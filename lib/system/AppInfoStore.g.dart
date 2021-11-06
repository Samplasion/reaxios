// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppInfoStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppInfoStore on _AppInfoStoreBase, Store {
  final _$packageInfoAtom = Atom(name: '_AppInfoStoreBase.packageInfo');

  @override
  PackageInfo get packageInfo {
    _$packageInfoAtom.reportRead();
    return super.packageInfo;
  }

  @override
  set packageInfo(PackageInfo value) {
    _$packageInfoAtom.reportWrite(value, super.packageInfo, () {
      super.packageInfo = value;
    });
  }

  final _$getPackageInfoAsyncAction =
      AsyncAction('_AppInfoStoreBase.getPackageInfo');

  @override
  Future<void> getPackageInfo() {
    return _$getPackageInfoAsyncAction.run(() => super.getPackageInfo());
  }

  @override
  String toString() {
    return '''
packageInfo: ${packageInfo}
    ''';
  }
}
