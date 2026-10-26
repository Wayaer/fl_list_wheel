#!/bin/sh
dart format lib example/lib
flutter analyze
(cd example && flutter analyze)
