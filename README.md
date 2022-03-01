# Registro Elettronico Axios

_(Axios Electronic Registry)_

An unofficial client for the Axios Electronic Registry.

[![CI Builds](https://github.com/Samplasion/reaxios/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/Samplasion/reaxios/actions/workflows/build.yml)

<div style="display: flex; flex-wrap: wrap;">
<a title="Not yet" href="https://play.google.com/store/apps/details?id=org.js.samplasion.reaxios"><img src="assets/readme/google-play-badge.png" style="height: 5rem"></a>
<a title="GitHub Releases" href="https://github.com/Samplasion/reaxios/releases/latest"><img src="assets/readme/apk-badge.png" style="height: 5rem"></a>
</div>

## Building from source

### Linux/Mac

```sh
git clone https://github.com/Samplasion/reaxios.git
cd reaxios
flutter pub get
tools/build_android.sh
```

The built APK and AAB are in the `out/android` directory.

### Windows

Install WSL and Flutter, then follow the instructions in the
[Linux/Mac instructions](#linuxmac) (untested).
