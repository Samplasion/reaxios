#!/usr/bin/env bash

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
    echo "Builds the macOS app"
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
echo "##                     Build macOS app                     ##"
echo "##                                                         ##"
echo "#############################################################"
echo 
echo App version: $VER
echo Build number: $NOW
echo 

build() {
    echo "📦 Building the macOS app..."
    flutter build macos --$flavor 1> /dev/null
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/macos

    echo "🗑  Removing previous releases..."
    rm -rf $CUR/out/macos/*
    rm -rf $CUR/out/macos/**/*
}

copy() {
    echo "📑 Copying output files from their directory to our organized directory..."
    Flavor=${flavor^}
    cp -r "$CUR/build/macos/Build/Products/$Flavor/$name.app" $CUR/out/macos/$name.app
    cd $CUR/out/macos
    zip -9 -y -r -q $name-mac-$VER+$NOW-$flavor.zip $name.app
    rm -rf $name.app
    cd -
}

eval $run