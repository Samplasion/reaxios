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
    echo "Builds the Web page"
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
echo "##                     Build Web page                      ##"
echo "##                                                         ##"
echo "#############################################################"
echo 
echo App version: $VER
echo Build number: $NOW
echo 

build() {
    echo "📦 Building the webpage..."
    flutter build web --$flavor 1> /dev/null
}

cleanup() {
    echo "📁 Creating the output directory if it doesn't exist..."
    mkdir -p $CUR/out/web

    echo "🗑  Removing previous releases..."
    rm -rf $CUR/out/web/*
    rm -rf $CUR/out/web/**/*
}

copy() {
    echo "📑 Copying output files from their directory to our organized directory..."
    cp -r $CUR/build/web $CUR/out/web/
    cd $CUR/out/web
    zip -r $CUR/out/web/$name-web-$VER+$NOW-$flavor.zip .
    # zip -r -X $CUR/out/web/$name-$VER+$NOW-$flavor.zip $CUR/out/web/
    cd -
    rm -rf $CUR/out/web/web
}

eval $run