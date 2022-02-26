#!/bin/bash

set -e

# Set up environment
name="Registro"
flavor="release"
NOW=$(date +"%s")
CUR=$(pwd)
VER=$(grep "version: " $CUR/pubspec.yaml | sed 's/version: //')

run="build && cleanup && copy"

usage() {
    echo 
    echo "Builds the Android APK and App Bundle"
    echo "Usage: $0 [-ch]"
    echo
    echo "  -c       Only run cleanup"
    echo "  -h       Print this help message"
}

while getopts ":ch" opt; do
  case $opt in
    h)
        usage
        exit 0
        ;;
    c)
        run="cleanup"
        ;;
    esac
done

echo 
echo "#############################################################"
echo "##                                                         ##"
echo "##                    Build Android APK                    ##"
echo "##                 and Android App Bundle                  ##"
echo "##                                                         ##"
echo "#############################################################"
echo 
echo App version: $VER
echo Build number: $NOW
echo 

_build_appbundle() {
    echo "📦 Building the bundle..."
    flutter build appbundle --$flavor --build-number $NOW 1> /dev/null
}

_build_apk() {
    echo "📦 Building the APK..."
    flutter build apk --$flavor --build-number $NOW 1> /dev/null
}

build() {
    _build_appbundle & _build_apk
    wait
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/android

    echo "🗑 Removing previous releases..."
    rm -rf $CUR/out/android/*
    rm -rf $CUR/out/android/**/*
}

copy() {
    echo "📑 Copying output files from their directory to our organized directory..."
    cp -r $CUR/build/app/outputs/flutter-apk/app-release.apk $CUR/out/android/$name-$VER+$NOW-$flavor.apk
    cp -r $CUR/build/app/outputs/bundle/release/app-release.aab $CUR/out/android/$name-$VER+$NOW-$flavor.aab
}

eval $run