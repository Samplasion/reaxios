enum UpdateNagMode {
  alert,
  banner,
  none,
}

extension Serialization on UpdateNagMode {
  String get serialized {
    switch (this) {
      case UpdateNagMode.alert:
        return 'alert';
      case UpdateNagMode.banner:
        return 'banner';
      case UpdateNagMode.none:
        return 'none';
    }
  }
}

UpdateNagMode deserializeUpdateNagMode(String serialized) {
  switch (serialized) {
    case 'alert':
      return UpdateNagMode.alert;
    case 'banner':
      return UpdateNagMode.banner;
    case 'none':
      return UpdateNagMode.none;
  }
  return UpdateNagMode.alert;
}
