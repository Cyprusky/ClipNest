#!/bin/bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"
mode="${1:-build}"
case "$mode" in
  build|test|test-all|release) ;;
  *) echo "Usage: $0 [build|test|test-all|release]" >&2; exit 2 ;;
esac
build_root="${CLIPNEST_BUILD_DIR:-$repo_root/.build}"
mkdir -p "$build_root"
configuration=Debug
action=build
args=(-project ClipNest.xcodeproj -scheme ClipNest)
if [[ "$mode" == release ]]; then configuration=Release; fi
if [[ "$mode" == test || "$mode" == test-all ]]; then
  action=test
  if [[ "$mode" == test ]]; then
    # Avoid tests that overwrite the user's system clipboard during local development.
    for suite in HistoryItemTests HistoryTests HistoryDecoratorTests SearchTests SorterTests ShortenedTests ColorImageTests UnsafeForTitleLayoutTests CollectionSurroundingTests; do
      args+=("-only-testing:ClipNestTests/$suite")
    done
  else
    args+=("-only-testing:ClipNestTests")
  fi
fi
xcodebuild "${args[@]}" \
  -configuration "$configuration" -destination 'platform=macOS' \
  -derivedDataPath "$build_root/DerivedData" "$action"
if [[ "$mode" == release ]]; then
  product="$build_root/DerivedData/Build/Products/Release/ClipNest.app"
  mkdir -p "$build_root/releases"
  ditto -c -k --sequesterRsrc --keepParent "$product" "$build_root/releases/ClipNest.app.zip"
  echo "Local ad-hoc build (not notarized): $build_root/releases/ClipNest.app.zip"
fi
