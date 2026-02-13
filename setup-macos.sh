#!/bin/bash
# IceBreaker macOS Setup Script
# This script sets up the development environment needed to build IceBreaker on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}IceBreaker macOS Development Environment Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗ This script only runs on macOS${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking Xcode Command Line Tools...${NC}"
if ! command -v clang &> /dev/null; then
    echo -e "${YELLOW}Installing Xcode Command Line Tools...${NC}"
    xcode-select --install
    echo -e "${YELLOW}Please wait for installation to complete, then re-run this script${NC}"
    exit 0
else
    echo -e "${GREEN}✓ Xcode Command Line Tools installed${NC}"
fi
echo ""

echo -e "${YELLOW}Step 2: Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo -e "${GREEN}✓ Homebrew installed${NC}"
else
    echo -e "${GREEN}✓ Homebrew installed${NC}"
    echo -e "${YELLOW}Updating Homebrew...${NC}"
    brew update
    echo -e "${GREEN}✓ Homebrew updated${NC}"
fi
echo ""

echo -e "${YELLOW}Step 3: Installing SDL libraries...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"
echo ""
echo -e "${YELLOW}Note: Using SDL 2.0 (current standard)${NC}"
echo -e "${YELLOW}SDL 1.2 is deprecated but can still be used if needed${NC}"
echo ""

SDL_INSTALLED=false

# Check if SDL2 is already installed
if brew list sdl2 &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ SDL2 already installed${NC}"
else
    echo -e "${YELLOW}Installing SDL2...${NC}"
    brew install sdl2
    SDL_INSTALLED=true
fi

if brew list sdl2_mixer &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ SDL2_mixer already installed${NC}"
else
    echo -e "${YELLOW}Installing SDL2_mixer...${NC}"
    brew install sdl2_mixer
    SDL_INSTALLED=true
fi

echo -e "${GREEN}✓ SDL2 libraries configured${NC}"
echo ""

# Verify installation
echo -e "${YELLOW}Step 4: Verifying installation...${NC}"
echo ""
echo -e "${BLUE}Checking installed tools:${NC}"

tools=("clang" "make" "pkg-config")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        version=$($tool --version 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} $tool"
    else
        echo -e "${RED}✗${NC} $tool not found"
    fi
done

echo ""
echo -e "${BLUE}Checking SDL libraries:${NC}"
if pkg-config --exists sdl2; then
    version=$(pkg-config --modversion sdl2)
    echo -e "${GREEN}✓${NC} SDL2 $version"
else
    echo -e "${RED}✗${NC} SDL2 not found via pkg-config"
fi

if pkg-config --exists SDL2_mixer; then
    version=$(pkg-config --modversion SDL2_mixer)
    echo -e "${GREEN}✓${NC} SDL2_mixer $version"
else
    echo -e "${RED}✗${NC} SDL2_mixer not found via pkg-config"
fi
echo ""

# Final instructions
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You can now build IceBreaker!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo -e "${YELLOW}1. Build the app bundle:${NC}"
echo -e "   ${BLUE}cd $(pwd)${NC}"
echo -e "   ${BLUE}./build-macos.sh${NC}"
echo ""
echo -e "${YELLOW}2. Or build manually:${NC}"
echo -e "   ${BLUE}make -f Makefile.macos${NC}"
echo ""
echo -e "${YELLOW}3. Run the app:${NC}"
echo -e "   ${BLUE}open IceBreaker.app${NC}"
echo ""
echo -e "${YELLOW}4. Create a DMG installer:${NC}"
echo -e "   ${BLUE}make -f Makefile.macos dmg${NC}"
echo ""
echo "For more information, see README.macos"
echo ""
