#!/bin/bash
set -e

echo "🔨 Building Tracky-Tock for macOS..."

# 1. Compile Swift sources
mkdir -p .build/module-cache
swiftc -sdk $(xcrun --show-sdk-path) \
  -target arm64-apple-macos13.0 \
  -module-cache-path .build/module-cache \
  -parse-as-library \
  Sources/TrackyTock/TrackyTockApp.swift \
  Sources/TrackyTock/Models/*.swift \
  Sources/TrackyTock/Managers/*.swift \
  Sources/TrackyTock/Views/*.swift \
  -o TrackyTock

# 2. Prepare .app bundle
mkdir -p "Tracky-Tock.app/Contents/MacOS"
mkdir -p "Tracky-Tock.app/Contents/Resources"
cp TrackyTock "Tracky-Tock.app/Contents/MacOS/TrackyTock"

if [ -f "AppIcon.icns" ]; then
  cp AppIcon.icns "Tracky-Tock.app/Contents/Resources/AppIcon.icns"
fi

# 3. Fix permissions and ad-hoc sign
rm -f "Tracky-Tock.app/Icon"* "Tracky-Tock.app/.DS_Store" 2>/dev/null || true
chmod -R 755 "Tracky-Tock.app"
xattr -cr "Tracky-Tock.app" 2>/dev/null || true
codesign --force --deep --sign - "Tracky-Tock.app"
xattr -cr "Tracky-Tock.app" 2>/dev/null || true

# 4. Register with LaunchServices
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "Tracky-Tock.app" 2>/dev/null || true

# 5. Create distributable ZIP for Gumroad, Lemon Squeezy, GitHub Releases
mkdir -p dist
rm -f dist/Tracky-Tock-v1.0.0.zip
ditto -c -k --sequesterRsrc --keepParent "Tracky-Tock.app" "dist/Tracky-Tock-v1.0.0.zip"

echo "✅ Build & packaging complete!"
echo "📦 Release archive ready at: dist/Tracky-Tock-v1.0.0.zip"
