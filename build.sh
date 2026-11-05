#!/usr/bin/env bash
# MiniClock.app 빌드 스크립트
set -euo pipefail
cd "$(dirname "$0")"

APP=MiniClock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

[ -f AppIcon.icns ] || swift make_icon.swift
cp AppIcon.icns "$APP/Contents/Resources/"

# 유니버설 바이너리(arm64 + x86_64)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
for ARCH in arm64 x86_64; do
  swiftc -O -parse-as-library -target "$ARCH-apple-macos14" MiniClock.swift -o "$TMP/MiniClock-$ARCH"
done
lipo -create "$TMP/MiniClock-arm64" "$TMP/MiniClock-x86_64" -o "$APP/Contents/MacOS/MiniClock"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>MiniClock</string>
  <key>CFBundleIdentifier</key><string>local.miniclock</string>
  <key>CFBundleExecutable</key><string>MiniClock</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>CFBundleIconFile</key><string>AppIcon</string>
</dict>
</plist>
EOF

codesign --force --sign - "$APP" >/dev/null 2>&1 || true
echo "빌드 완료: $(pwd)/$APP"
