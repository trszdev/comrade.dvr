#!/bin/bash

SOURCE=`dirname "$0"`
PRETTIFIER="mint run xcbeautify"
ARCHIEVE_PATH="$SOURCE/../.build/archieve"
PROJECT_PATH="$SOURCE/../ComradeDVR.xcodeproj"
EXPORT_PATH="$SOURCE/../.build"
EXPORT_PLIST="$SOURCE/../src/App/ExportOptions.plist"

set -xo pipefail

mkdir -p `dirname "$ARCHIEVE_PATH"`

xcodebuild -version

xcodebuild \
  -scheme ComradeDVR \
  -project "$PROJECT_PATH" \
  -configuration Production \
  -sdk 'iphoneos15.0' \
  -destination 'generic/platform=iOS'\
  -archivePath "$ARCHIEVE_PATH" \
  clean archive | $PRETTIFIER

xcodebuild \
  -exportArchive \
  -archivePath "${ARCHIEVE_PATH}.xcarchive" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" | $PRETTIFIER

