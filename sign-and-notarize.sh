#!/bin/bash
# Code Signing and Notarization Script for IceBreaker
# This script handles signing and optional notarization for macOS distribution

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BUNDLE_NAME="IceBreaker.app"
VERSION=$(awk '/^#define VERSION/ { print $3 }' icebreaker.h)
DMG_NAME="icebreaker-${VERSION}.dmg"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}IceBreaker Code Signing & Notarization${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if bundle exists
if [ ! -d "$BUNDLE_NAME" ]; then
    echo -e "${RED}✗ Error: $BUNDLE_NAME not found${NC}"
    echo "Build the app first: make -f Makefile.macos"
    exit 1
fi

# Menu
echo "Choose signing method:"
echo ""
echo "  1) Ad-hoc signing (for local testing, no developer account needed)"
echo "  2) Developer signing (requires Apple Developer Certificate)"
echo "  3) Ad-hoc + Create DMG"
echo "  4) Remove quarantine attribute"
echo "  5) Check current signature"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Ad-hoc Signing...${NC}"
        codesign --deep --force --verify --verbose --sign - "$BUNDLE_NAME"
        echo -e "${GREEN}✓ Signed successfully${NC}"
        echo ""
        echo "You can now:"
        echo "  - Run the app: open $BUNDLE_NAME"
        echo "  - Create DMG: make -f Makefile.macos dmg"
        ;;

    2)
        echo ""
        echo -e "${YELLOW}Developer Certificate Signing...${NC}"
        echo "Available certificates:"
        security find-identity -v -p codesigning | grep "Developer ID Application" | head -10
        echo ""
        read -p "Enter certificate name (or copy from above): " cert_name

        if [ -z "$cert_name" ]; then
            echo -e "${RED}✗ No certificate specified${NC}"
            exit 1
        fi

        echo -e "${YELLOW}Signing with: $cert_name${NC}"
        codesign --deep --force --verify --verbose --sign "$cert_name" "$BUNDLE_NAME"
        echo -e "${GREEN}✓ Signed successfully${NC}"
        echo ""
        echo "Next steps for distribution:"
        echo "  1. Create DMG: make -f Makefile.macos dmg"
        echo "  2. Optionally notarize (see option 6)"
        ;;

    3)
        echo ""
        echo -e "${YELLOW}Ad-hoc Signing + Creating DMG...${NC}"
        codesign --deep --force --verify --verbose --sign - "$BUNDLE_NAME"
        echo -e "${GREEN}✓ Signed successfully${NC}"
        echo ""
        echo -e "${YELLOW}Creating DMG...${NC}"
        make -f Makefile.macos dmg
        echo -e "${GREEN}✓ DMG created: $DMG_NAME${NC}"
        ;;

    4)
        echo ""
        echo -e "${YELLOW}Removing quarantine attribute...${NC}"
        xattr -d com.apple.quarantine "$BUNDLE_NAME" 2>/dev/null || true
        echo -e "${GREEN}✓ Quarantine attribute removed${NC}"
        echo ""
        echo "The app should now open without security warnings"
        ;;

    5)
        echo ""
        echo -e "${YELLOW}Current Signature Information:${NC}"
        echo ""
        if codesign -v "$BUNDLE_NAME" 2>&1; then
            echo ""
            echo -e "${GREEN}✓ Bundle is properly signed${NC}"
            echo ""
            echo "Signature details:"
            codesign -d -r - "$BUNDLE_NAME"
        else
            echo -e "${YELLOW}✗ Bundle is not signed or has signing issues${NC}"
            echo ""
            echo "To sign it, choose option 1 (ad-hoc) or 2 (developer)"
        fi
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Offer additional help
if [ "$choice" != "5" ]; then
    echo "Additional Options:"
    echo ""
    echo "1. To test the signed app:"
    echo "   ${YELLOW}open $BUNDLE_NAME${NC}"
    echo ""
    echo "2. To create a distribution DMG:"
    echo "   ${YELLOW}make -f Makefile.macos dmg${NC}"
    echo ""
    echo "3. For notarization (requires Developer account):"
    echo "   Read README.macos for detailed notarization instructions"
    echo ""
fi
