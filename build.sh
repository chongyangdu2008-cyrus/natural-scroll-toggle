#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
build_dir="$PWD/work/build"
app_path="$build_dir/自然捲動切換.app"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
swiftc -swift-version 5 -O src/ScrollToggle.swift -o "$app_path/Contents/MacOS/scroll-toggle" -framework AppKit
swift src/MakeIcon.swift "$build_dir/ScrollToggle.iconset"
iconutil -c icns "$build_dir/ScrollToggle.iconset" -o "$app_path/Contents/Resources/ScrollToggle.icns"
xcrun actool assets/ScrollToggle.icon --compile "$app_path/Contents/Resources" \
  --platform macosx --minimum-deployment-target 13.0 --target-device mac \
  --app-icon ScrollToggle --output-partial-info-plist "$build_dir/icon-info.plist" \
  --output-format human-readable-text
python3 - "$app_path" <<'PY'
import pathlib,plistlib,sys
app=pathlib.Path(sys.argv[1])
info={
    'CFBundleIdentifier':'local.natural-scroll-toggle',
    'CFBundleName':'自然捲動切換',
    'CFBundleDisplayName':'自然捲動切換',
    'CFBundleExecutable':'scroll-toggle',
    'CFBundlePackageType':'APPL',
    'CFBundleVersion':'4',
    'CFBundleShortVersionString':'1.3',
    'CFBundleIconFile':'ScrollToggle.icns',
    'CFBundleIconName':'ScrollToggle',
    'LSMinimumSystemVersion':'13.0',
    'LSUIElement':True,
    'NSHighResolutionCapable':True,
}
with (app/'Contents/Info.plist').open('wb') as file:plistlib.dump(info,file)
PY
codesign --force --sign - "$app_path"
print -r -- "$app_path"
