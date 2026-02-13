#!/bin/bash
# Create macOS app icon from PNG

PNG_SOURCE="icebreaker_128.png"
ICON_NAME="icebreaker"
ICONSET="$ICON_NAME.iconset"
ICNS="$ICON_NAME.icns"

if [ ! -f "$PNG_SOURCE" ]; then
    echo "Error: $PNG_SOURCE not found"
    exit 1
fi

echo "Creating icon set from $PNG_SOURCE..."

# Create iconset directory
mkdir -p "$ICONSET"

# Create all required sizes
# macOS icon sizes: 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024
# Also need 2x versions for retina displays

echo "  → Creating 16x16..."
sips -z 16 16 "$PNG_SOURCE" --out "$ICONSET/icon_16x16.png" > /dev/null 2>&1

echo "  → Creating 32x32..."
sips -z 32 32 "$PNG_SOURCE" --out "$ICONSET/icon_32x32.png" > /dev/null 2>&1

echo "  → Creating 64x64..."
sips -z 64 64 "$PNG_SOURCE" --out "$ICONSET/icon_64x64.png" > /dev/null 2>&1

echo "  → Creating 128x128..."
cp "$PNG_SOURCE" "$ICONSET/icon_128x128.png"

echo "  → Creating 256x256..."
sips -z 256 256 "$PNG_SOURCE" --out "$ICONSET/icon_256x256.png" > /dev/null 2>&1

echo "  → Creating 512x512..."
sips -z 512 512 "$PNG_SOURCE" --out "$ICONSET/icon_512x512.png" > /dev/null 2>&1

# Create retina versions (2x)
echo "  → Creating retina versions..."
cp "$ICONSET/icon_16x16.png" "$ICONSET/icon_16x16@2x.png"
cp "$ICONSET/icon_32x32.png" "$ICONSET/icon_32x32@2x.png"
cp "$ICONSET/icon_64x64.png" "$ICONSET/icon_64x64@2x.png"
cp "$ICONSET/icon_128x128.png" "$ICONSET/icon_128x128@2x.png"
cp "$ICONSET/icon_256x256.png" "$ICONSET/icon_256x256@2x.png"
cp "$ICONSET/icon_512x512.png" "$ICONSET/icon_512x512@2x.png"

# Create the icns file
if command -v iconutil &> /dev/null; then
    echo "  → Creating .icns from iconset..."
    iconutil -c icns "$ICONSET" -o "$ICNS"
    echo "✓ Icon created: $ICNS"
    rm -rf "$ICONSET"
else
    echo "Warning: iconutil not found, keeping .iconset directory"
    echo "To create .icns later, run: iconutil -c icns $ICONSET -o $ICNS"
fi
