#!/bin/bash

SOURCE=`dirname "$0"`
PRETTIFIER="mint run xcbeautify"
PROJECT_PATH="$SOURCE/../ComradeDVR.xcodeproj"
DESTINATION="platform=iOS Simulator,name=iPhone 12,OS=15.0"

function run_tests {
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$1" \
    -destination "$DESTINATION" \
    test | $PRETTIFIER
}

function generate_project {
  pushd "$SOURCE/../src/$1"
  swift package generate-xcodeproj
  popd
}

function run_spm_tests {
  xcodebuild \
    -project "$SOURCE/../src/$1/$1.xcodeproj" \
    -scheme "$1-Package" \
    -destination "$DESTINATION" \
    test | $PRETTIFIER
}

set -xo pipefail

xcodebuild -version

generate_project "CameraKit"
generate_project "AutocontainerKit"

run_tests "ComradeDVR"
run_spm_tests "CameraKit"
run_spm_tests "AutocontainerKit"

