#!/bin/bash

SOURCE=`dirname "$0"`
PLIST_BUDDY="/usr/libexec/PlistBuddy"

$PLIST_BUDDY -c "Set CFBundleVersion $1" "$SOURCE/../src/App/Info.plist"

