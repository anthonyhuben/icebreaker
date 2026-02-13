#!/bin/bash
# IceBreaker Build Verification Script
# Verifies that the build is complete and functional

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BUNDLE_NAME="IceBreaker.app"
MACOS_PATH="$BUNDLE_NAME/Contents/MacOS/icebreaker"
RESOURCES_PATH="$BUNDLE_NAME/Contents/Resources"
PLIST_PATH="$BUNDLE_NAME/Contents/Info.plist"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}IceBreaker Build Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PASSED=0
FAILED=0

# Test 1: Bundle exists
echo -e "${YELLOW}1. Checking app bundle exists...${NC}"
if [ -d "$BUNDLE_NAME" ]; then
    echo -e "${GREEN}   ✓ $BUNDLE_NAME found${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ $BUNDLE_NAME not found${NC}"
    ((FAILED++))
    exit 1
fi

# Test 2: Executable exists
echo -e "${YELLOW}2. Checking executable...${NC}"
if [ -f "$MACOS_PATH" ]; then
    echo -e "${GREEN}   ✓ Executable found at $MACOS_PATH${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ Executable not found${NC}"
    ((FAILED++))
fi

# Test 3: Executable is actually an executable
echo -e "${YELLOW}3. Checking executable permissions...${NC}"
if [ -x "$MACOS_PATH" ]; then
    echo -e "${GREEN}   ✓ Executable has execute permission${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ Executable missing execute permission${NC}"
    echo "   Run: chmod +x $MACOS_PATH"
    ((FAILED++))
fi

# Test 4: Resources directory exists
echo -e "${YELLOW}4. Checking resources directory...${NC}"
if [ -d "$RESOURCES_PATH" ]; then
    echo -e "${GREEN}   ✓ Resources directory found${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ Resources directory not found${NC}"
    ((FAILED++))
fi

# Test 5: Check for graphics files
echo -e "${YELLOW}5. Checking graphics files...${NC}"
graphics_count=$(find "$RESOURCES_PATH" -type f \( -name "*.bmp" -o -name "*.png" \) 2>/dev/null | wc -l)
if [ "$graphics_count" -gt 0 ]; then
    echo -e "${GREEN}   ✓ Found $graphics_count graphics files${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ No graphics files found${NC}"
    ((FAILED++))
fi

# Test 6: Check for sound files
echo -e "${YELLOW}6. Checking sound files...${NC}"
sound_count=$(find "$RESOURCES_PATH" -type f -name "*.wav" 2>/dev/null | wc -l)
if [ "$sound_count" -gt 0 ]; then
    echo -e "${GREEN}   ✓ Found $sound_count sound files${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ No sound files found${NC}"
    ((FAILED++))
fi

# Test 7: Check for theme files
echo -e "${YELLOW}7. Checking theme files...${NC}"
theme_count=$(find "$RESOURCES_PATH" -type f -name "*.ibt" 2>/dev/null | wc -l)
if [ "$theme_count" -gt 0 ]; then
    echo -e "${GREEN}   ✓ Found $theme_count theme files${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ No theme files found${NC}"
    ((FAILED++))
fi

# Test 8: Check Info.plist
echo -e "${YELLOW}8. Checking Info.plist...${NC}"
if [ -f "$PLIST_PATH" ]; then
    if plutil -lint "$PLIST_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✓ Info.plist is valid${NC}"
        ((PASSED++))
    else
        echo -e "${RED}   ✗ Info.plist is invalid${NC}"
        ((FAILED++))
    fi
else
    echo -e "${RED}   ✗ Info.plist not found${NC}"
    ((FAILED++))
fi

# Test 9: Check licensing files
echo -e "${YELLOW}9. Checking documentation files...${NC}"
doc_count=$(find "$RESOURCES_PATH" -type f \( -name "README*" -o -name "LICENSE*" -o -name "ChangeLog" \) 2>/dev/null | wc -l)
if [ "$doc_count" -gt 0 ]; then
    echo -e "${GREEN}   ✓ Found $doc_count documentation files${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠ No documentation files found (optional)${NC}"
fi

# Test 10: File size check
echo -e "${YELLOW}10. Checking executable size...${NC}"
if [ -f "$MACOS_PATH" ]; then
    size=$(du -h "$MACOS_PATH" | cut -f1)
    echo -e "${GREEN}   ✓ Executable size: $size${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ Could not determine executable size${NC}"
    ((FAILED++))
fi

# Test 11: File type verification
echo -e "${YELLOW}11. Verifying executable file type...${NC}"
if file "$MACOS_PATH" | grep -q "Mach-O"; then
    echo -e "${GREEN}   ✓ Executable is a valid Mach-O binary${NC}"
    ((PASSED++))
else
    echo -e "${RED}   ✗ Executable is not a valid Mach-O binary${NC}"
    ((FAILED++))
fi

# Test 12: Signature check (if signed)
echo -e "${YELLOW}12. Checking code signature...${NC}"
if codesign -v "$BUNDLE_NAME" > /dev/null 2>&1; then
    echo -e "${GREEN}   ✓ Bundle is signed${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠ Bundle is not signed (can be signed later)${NC}"
fi

# Test 13: DMG existence
echo -e "${YELLOW}13. Checking for DMG file...${NC}"
dmg_file=$(find . -maxdepth 1 -name "icebreaker-*.dmg" -type f 2>/dev/null | head -1)
if [ -n "$dmg_file" ]; then
    dmg_size=$(du -h "$dmg_file" | cut -f1)
    echo -e "${GREEN}   ✓ Found $dmg_file (${dmg_size})${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}   ⚠ No DMG file found (can be created with: make -f Makefile.macos dmg)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Build Verification Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${FAILED}${NC}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo -e "${YELLOW}You can now:${NC}"
    echo ""
    echo "1. Test the app:"
    echo "   ${BLUE}open $BUNDLE_NAME${NC}"
    echo ""
    echo "2. Create/verify DMG:"
    echo "   ${BLUE}make -f Makefile.macos dmg${NC}"
    echo ""
    echo "3. Sign the app (optional):"
    echo "   ${BLUE}./sign-and-notarize.sh${NC}"
    echo ""
    echo "4. Install to /Applications:"
    echo "   ${BLUE}make -f Makefile.macos install${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the errors above.${NC}"
    echo ""
    echo -e "${YELLOW}Common fixes:${NC}"
    echo "  - Run 'make -f Makefile.macos clean' and rebuild"
    echo "  - Check that SDL libraries are installed: brew install sdl@1.2 sdl_mixer"
    echo "  - See README.macos for detailed troubleshooting"
    echo ""
    exit 1
fi
