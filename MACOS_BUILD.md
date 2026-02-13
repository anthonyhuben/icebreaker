# macOS Build & Distribution Guide for IceBreaker

A complete guide for building IceBreaker on macOS and creating distributable DMG files.

## Quick Start (< 5 minutes)

### 1. First Time Setup (1-time only)
```bash
chmod +x setup-macos.sh
./setup-macos.sh
```

This installs all required dependencies (Xcode, Homebrew, SDL libraries).

### 2. Build and Create DMG
```bash
chmod +x build-macos.sh
./build-macos.sh
```

This builds the app and creates `icebreaker-VERSION.dmg`.

### 3. Distribute
Share `icebreaker-VERSION.dmg` with users. They can:
1. Download and open the DMG
2. Drag `IceBreaker.app` to their Applications folder
3. Open IceBreaker from Applications

---

## Manual Build Steps

If you prefer to build step-by-step:

```bash
# Clean previous build
make -f Makefile.macos clean

# Build the app bundle
make -f Makefile.macos

# Create DMG installer
make -f Makefile.macos dmg

# Or use the dedicated script
./create-dmg.sh

# To install locally
make -f Makefile.macos install
```

---

## File Overview

### Build Scripts
- **`setup-macos.sh`** - Sets up development environment (one-time)
- **`build-macos.sh`** - Complete build + DMG creation (recommended)
- **`create-dmg.sh`** - Just creates the DMG from existing bundle

### Build System
- **`Makefile.macos`** - Main macOS build configuration
- **`Makefile.osx`** - Legacy macOS Makefile (older alternative)

### Documentation
- **`README.macos`** - Comprehensive macOS build documentation
- **`MACOS_BUILD.md`** - This quick reference

---

## Requirements

### Automatic (via setup-macos.sh)
- Xcode Command Line Tools
- Homebrew package manager
- SDL 1.2 and SDL_mixer libraries

### Manual Installation
```bash
# Install Xcode tools
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install SDL libraries
brew install sdl@1.2 sdl_mixer
```

---

## Build Output

After running `build-macos.sh` or `make -f Makefile.macos`:

```
IceBreaker.app/                    # Application bundle (double-click to run)
├── Contents/
│   ├── MacOS/icebreaker          # Executable
│   ├── Resources/                # Game data
│   │   ├── *.ibt (themes)
│   │   ├── *.bmp (graphics)
│   │   ├── *.png (graphics)
│   │   ├── *.wav (sounds)
│   │   └── README, LICENSE, etc.
│   └── Info.plist                # Bundle configuration

icebreaker-2.2.2.dmg              # Installer for distribution
```

---

## Testing the Build

### Quick Test
```bash
open IceBreaker.app
```

### Test the DMG
```bash
# Open the DMG file
open icebreaker-2.2.2.dmg

# Or test from another user account
sudo su - testuser
open icebreaker-2.2.2.dmg
```

### Verify Resources Loaded
When the game starts, confirm:
- Graphics display correctly (penguins, ice)
- Sound plays (click and game sounds)
- All menu options work
- Themes load properly

---

## Troubleshooting

### Build Fails: "SDL not found"
```bash
brew install sdl@1.2 sdl_mixer
# Then re-run build
```

### Build Fails: "Command not found: make"
```bash
xcode-select --install
```

### App Won't Launch (macOS 10.15+)
```bash
# Remove quarantine flag
xattr -d com.apple.quarantine IceBreaker.app

# Or from DMG after extracting
xattr -rd com.apple.quarantine IceBreaker.app
```

### "Can't be opened because Apple cannot check it for malicious software"
Two options:
1. **Ad-hoc sign the app:**
   ```bash
   codesign --deep --force --verify --verbose --sign - IceBreaker.app
   ```

2. **Or tell Gatekeeper to allow it:**
   - Right-click IceBreaker.app
   - Select "Open"
   - Click "Open" in the dialog

### App Crashes on Startup
Check the console:
```bash
log stream --predicate 'process == "icebreaker"'
```

Look for SDL-related errors. Ensure SDL libraries are properly installed:
```bash
pkg-config --modversion sdl SDL_mixer
```

---

## Advanced: Code Signing & Distribution

### Ad-hoc Signing (for local testing)
```bash
codesign --deep --force --verify --verbose --sign - IceBreaker.app
make -f Makefile.macos dmg
```

### Developer Certificate Signing (for production)
```bash
# Requires an Apple Developer account
codesign --force --verify --verbose \
  --sign "Developer ID Application: Your Name (ID)" \
  IceBreaker.app

# Recreate DMG with signed app
make -f Makefile.macos dmg
```

### Notarization (macOS 10.15+)
```bash
# Sign with Developer ID
codesign --force --verify --verbose \
  --sign "Developer ID Application: Your Name (ID)" \
  IceBreaker.app

# Create zip for notarization
ditto -c -k --keepParent IceBreaker.app icebreaker-notarize.zip

# Submit for notarization
xcrun altool --notarize-app \
  --file icebreaker-notarize.zip \
  --primary-bundle-id org.mattdm.icebreaker \
  -u your-apple-id@example.com \
  -p your-app-password

# Wait for approval (check status periodically)
# Then staple the ticket
xcrun stapler staple IceBreaker.app

# Create final DMG
make -f Makefile.macos dmg
```

---

## Platform Support

| macOS Version | Support | Notes |
|---------------|---------|-------|
| 10.7 - 10.14  | ✓ Works | Requires SDL 1.2.15+ |
| 10.15         | ✓ Works | May need code signing |
| 11+           | ✓ Works | Native support, notarization recommended |
| 12-15         | ✓ Works | Fully supported |

### Apple Silicon (M1/M2/M3+)
- Works via Intel emulation (Rosetta 2)
- For native ARM64 support, build with:
  ```bash
  CFLAGS="-arch arm64" make -f Makefile.macos
  ```
- Ensure your SDL is compiled for ARM64:
  ```bash
  arch -arm64 brew install sdl@1.2 sdl_mixer
  ```

---

## Directory Structure

```
IceBreaker/                        # Project root
├── build-macos.sh                 # Complete build script
├── setup-macos.sh                 # Environment setup
├── create-dmg.sh                  # DMG creation
├── Makefile.macos                 # Primary macOS Makefile
├── Makefile.osx                   # Legacy Makefile
├── README.macos                    # Detailed documentation
├── MACOS_BUILD.md                 # This file
├── icebreaker.c                   # Main source
├── *.c / *.h                       # Game source code
├── *.bmp / *.png                  # Graphics
├── *.wav                           # Sounds
├── *.ibt                           # Theme files
└── IceBreaker.app                 # Built app (after make)
    └── icebreaker-2.2.2.dmg       # Distribution DMG (after dmg target)
```

---

## Environment Variables

Customize the build with environment variables:

```bash
# Build with debug symbols
DEBUG=1 make -f Makefile.macos

# Custom Clang flags
CFLAGS="-O3 -march=native" make -f Makefile.macos

# Universal binary (Intel + ARM)
CFLAGS="-arch x86_64 -arch arm64" make -f Makefile.macos

# Specify custom resource directory
DATAPREFIX="/custom/path" make -f Makefile.macos install
```

---

## Performance Tips

1. **Optimize build size:** The Makefile uses `-O2` by default
2. **Faster builds:** Use `make -j4` to parallelize compilation
3. **Reduce DMG size:** The Makefile uses UDZO format with zlib-level=9

---

## Getting Help

- **Build Issues:** Check README.macos
- **SDL Problems:** https://www.libsdl.org/
- **Homebrew Help:** `brew doctor` and `brew help`
- **Original Project:** http://www.mattdm.org/icebreaker/
- **GitHub Issues:** https://github.com/mattdm/icebreaker-game

---

## Licensing

IceBreaker is distributed under the GNU General Public License v2 or later.
See LICENSE and README files in the app bundle for details.
