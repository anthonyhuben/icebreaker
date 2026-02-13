#!/bin/bash
# Advanced DMG Creation Script for IceBreaker
# Creates a professional-looking macOS installer DMG

set -e

# Configuration
BUNDLE_NAME="IceBreaker.app"
VERSION=$(awk '/^#define VERSION/ { print $3 }' icebreaker.h)
DMG_NAME="icebreaker-${VERSION}.dmg"
VOLUME_NAME="IceBreaker ${VERSION}"
DMG_SIZE="250m"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}IceBreaker DMG Creator${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verify the bundle exists
if [ ! -d "$BUNDLE_NAME" ]; then
    echo -e "${RED}✗ Error: $BUNDLE_NAME not found${NC}"
    echo "Build the app first: make -f Makefile.macos"
    exit 1
fi

echo -e "${YELLOW}Creating DMG: $DMG_NAME${NC}"
echo ""

# Remove existing DMG if it exists
if [ -f "$DMG_NAME" ]; then
    echo -e "${YELLOW}Removing existing $DMG_NAME...${NC}"
    rm -f "$DMG_NAME"
fi

# Create a temporary directory for DMG contents
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${YELLOW}Preparing DMG contents...${NC}"
cp -r "$BUNDLE_NAME" "$TEMP_DIR/"

# Create symbolic link to Applications folder
ln -s /Applications "$TEMP_DIR/Applications"

# Create a background image (optional - currently commented out)
# If you want a custom background, create a PNG and uncomment:
# cp background.png "$TEMP_DIR/.background.png"

# Create the DMG using hdiutil
echo -e "${YELLOW}Building DMG image...${NC}"
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$TEMP_DIR" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_NAME"

# Verify the DMG was created
if [ -f "$DMG_NAME" ]; then
    SIZE=$(du -h "$DMG_NAME" | cut -f1)
    echo -e "${GREEN}✓ DMG created successfully: $DMG_NAME (${SIZE})${NC}"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}DMG Creation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "DMG file: ${GREEN}$DMG_NAME${NC}"
    echo ""
    echo "Testing the DMG:"
    echo "  ${YELLOW}open $DMG_NAME${NC}"
    echo ""
    echo "To distribute:"
    echo "  1. Test on another machine if possible"
    echo "  2. Upload to your download server"
    echo "  3. Users can drag IceBreaker.app to Applications"
    echo ""
else
    echo -e "${RED}✗ DMG creation failed${NC}"
    exit 1
fi
