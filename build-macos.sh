#!/bin/bash
# IceBreaker macOS Build Script
# This script builds IceBreaker for macOS and creates a distributable .dmg file
# Automatically detects and uses available SDL version (1.2 or 2.0)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="IceBreaker"
VERSION=$(awk '/^#define VERSION/ { print $3 }' icebreaker.h)
DMG_NAME="icebreaker-${VERSION}.dmg"
BUNDLE_NAME="IceBreaker.app"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}IceBreaker macOS Build System${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Version: $VERSION"
echo "Target: $BUNDLE_NAME"
echo ""

# Check for required tools
echo -e "${YELLOW}Checking dependencies...${NC}"
for tool in clang pkg-config; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}✗ $tool is not installed${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Check for SDL libraries and choose version
echo -e "${YELLOW}Checking SDL libraries...${NC}"

SDL_VERSION=""
MAKEFILE_TARGET="Makefile.macos"

# Try SDL12-compat first (modern SDL 1.2 compat on SDL 2.0)
if pkg-config --exists sdl 2>/dev/null; then
    SDL_VERSION="1.2 (SDL12-compat)"
    MAKEFILE_TARGET="Makefile.macos"
    echo -e "${GREEN}✓ SDL12-compat found (recommended!)${NC}"
    SDL_VERSION_STR=$(pkg-config --modversion sdl)
    echo "  SDL12-compat: $SDL_VERSION_STR"
    if pkg-config --exists SDL2_mixer 2>/dev/null; then
        MIXER_VERSION=$(pkg-config --modversion SDL2_mixer)
        echo "  SDL2_mixer: $MIXER_VERSION"
    fi
# Fall back to SDL 2.0
elif pkg-config --exists sdl2 SDL2_mixer 2>/dev/null; then
    SDL_VERSION="2.0"
    MAKEFILE_TARGET="Makefile.macos.sdl2"
    echo -e "${YELLOW}SDL12-compat not found, using SDL 2.0${NC}"
    SDL2_VERSION=$(pkg-config --modversion sdl2)
    SDL2_MIXER_VERSION=$(pkg-config --modversion SDL2_mixer)
    echo "  SDL2: $SDL2_VERSION"
    echo "  SDL2_mixer: $SDL2_MIXER_VERSION"
else
    echo -e "${RED}✗ SDL not found${NC}"
    echo ""
    echo -e "${YELLOW}SDL is not installed. Please install SDL12-compat:${NC}"
    echo "  ${BLUE}brew install sdl12-compat sdl2_mixer${NC}"
    echo ""
    echo "For alternative installation methods, see INSTALL_SDL_MACOS.md"
    exit 1
fi
echo ""

# Build
echo -e "${YELLOW}Building IceBreaker with SDL $SDL_VERSION...${NC}"
if make -f $MAKEFILE_TARGET clean &>/dev/null; then
    echo -e "${GREEN}✓ Clean complete${NC}"
fi

if make -f $MAKEFILE_TARGET; then
    echo -e "${GREEN}✓ Build successful (SDL $SDL_VERSION)${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  • Make sure SDL headers are installed: brew install sdl2 sdl2_mixer"
    echo "  • Check INSTALL_SDL_MACOS.md for alternative installation methods"
    exit 1
fi
echo ""

# Create DMG
echo -e "${YELLOW}Creating DMG installer...${NC}"
if [ -f "$DMG_NAME" ]; then
    echo -e "${YELLOW}Removing existing $DMG_NAME...${NC}"
    rm "$DMG_NAME"
fi

if make -f $MAKEFILE_TARGET dmg; then
    echo -e "${GREEN}✓ DMG created: $DMG_NAME${NC}"
else
    echo -e "${RED}✗ DMG creation failed${NC}"
    exit 1
fi
echo ""

# Display results
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Build Configuration:"
echo "  SDL Version:        ${BLUE}$SDL_VERSION${NC}"
echo "  Makefile:           ${BLUE}$MAKEFILE_TARGET${NC}"
echo ""
echo "Build artifacts:"
echo "  Application Bundle: ${GREEN}$BUNDLE_NAME${NC}"
echo "  DMG Installer:      ${GREEN}$DMG_NAME${NC}"
echo ""
echo "Next steps:"
echo "  1. Test the app: ${YELLOW}open $BUNDLE_NAME${NC}"
echo "  2. Distribute:   ${YELLOW}$DMG_NAME${NC}"
echo "  3. Install:      ${YELLOW}make -f $MAKEFILE_TARGET install${NC} (requires sudo)"
echo ""
echo "To sign the app for distribution:"
echo "  ${YELLOW}codesign --deep --force --verify --verbose --sign - $BUNDLE_NAME${NC}"
echo ""
