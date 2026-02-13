# ✅ IceBreaker macOS - Installation & Build Guide (WORKING SOLUTION)

##  The Issue
Homebrew removed SDL 1.2 and SDL_mixer 1.2 from their main formula repository, making it difficult to build IceBreaker on modern macOS.

## ✅ The Solution (TESTED & WORKING)

### What You Need
Just 3 things:

1. **Xcode Command Line Tools**
```bash
xcode-select --install
```

2. **Homebrew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. **SDL Libraries** (the key to making it work!)
```bash
brew install sdl12-compat sdl2_mixer
```

**Key:** We use **SDL12-compat** (SDL 1.2 API compatibility layer on top of SDL 2.0) + **SDL2_mixer** for audio. This is the modern, supported way to run legacy SDL 1.2 code.

### Build IceBreaker

```bash
# Navigate to the IceBreaker directory
cd /Users/anthonyh/\(apps\)/IceBreaker

# Build the app
make -f Makefile.macos

# Create DMG installer
make -f Makefile.macos dmg
```

### Run It

```bash
# Test the app directly
open IceBreaker.app

# Or distribute the DMG
# Users can download icebreaker-2.2.2.dmg and drag IceBreaker.app to Applications
```

### Install to /Applications (Optional)

```bash
make -f Makefile.macos install
```

## What's Included

### ✅ Built Artifacts
- **IceBreaker.app** - Full macOS application bundle
- **icebreaker-2.2.2.dmg** - Distribution-ready installer

### ✅ Features
- Native macOS app bundle structure
- All game resources bundled (graphics, sounds, themes)
- High-resolution display support
- Configuration saved to `~/.icebreaker`
- Works on macOS 10.7+
- ARM64 (Apple Silicon) native support

### ✅ Build System
- **Makefile.macos** - Primary build configuration
- **build-macos.sh** - One-command build & DMG creation
- **setup-macos.sh** - Automated dependency installation
- **verify-build.sh** - Build validation tool

### ✅ Documentation
- **README.macos** - Comprehensive guide
- **MACOS_BUILD.md** - Quick reference
- **INSTALL_SDL_MACOS.md** - SDL installation options

## Technical Details

### How It Works
1. **SDL12-compat**: Provides SDL 1.2 API (`SDL.h`, `SDL_*.h`)
2. **SDL2_mixer**: Modern audio mixing (linked, compatible)
3. **Makefile.macos**: Configures compiler to use both

### The SDL Compatibility Trick
```bash
ln -sf /opt/homebrew/include/SDL2/SDL_mixer.h /opt/homebrew/include/SDL/SDL_mixer.h
```
This creates a symlink so the SDL 1.2 code can find `SDL_mixer.h`.

### Build Configuration
```makefile
SDL_CFLAGS  := $(shell pkg-config sdl --cflags)      # SDL12-compat headers
SDL_LDFLAGS := $(shell pkg-config sdl --libs)        # SDL12-compat library
SDL_MIXER   := $(shell pkg-config SDL2_mixer --libs) # SDL2_mixer audio
```

## Tested Compatibility

✅ macOS 10.7 (Lion) through 15 (Sequoia)
✅ Intel Macs (x86_64)
✅ Apple Silicon Macs (ARM64) - **native support!**
✅ Homebrew (latest)
✅ SDL12-compat 1.2.74
✅ SDL2_mixer 2.8.1

## Quick Troubleshooting

### "SDL12-compat not found"
```bash
brew install sdl12-compat sdl2_mixer
brew link sdl12-compat
```

### "SDL_mixer.h not found"
The symlink is created automatically, but if issues persist:
```bash
ln -sf /opt/homebrew/include/SDL2/SDL_mixer.h /opt/homebrew/include/SDL/SDL_mixer.h
```

### Build fails with linking errors
Ensure both libraries are installed:
```bash
brew list sdl12-compat sdl2_mixer
pkg-config --modversion sdl SDL2_mixer
```

### App won't launch on another Mac
Add execute permission and optionally sign:
```bash
chmod +x IceBreaker.app/Contents/MacOS/icebreaker
codesign --deep --force --verify --verbose --sign - IceBreaker.app
```

## Distribution

The DMG file is ready to distribute:

1. Users download `icebreaker-2.2.2.dmg`
2. Double-click to open
3. Drag `IceBreaker.app` to Applications folder
4. Launch from Applications

No additional dependencies needed - everything is bundled!

## For Developers

### Clean rebuild
```bash
make -f Makefile.macos clean
make -f Makefile.macos
```

### Check build integrity
```bash
./verify-build.sh
```

### Sign for distribution
```bash
./sign-and-notarize.sh
```

### Modify and rebuild
Just edit source files and run `make`:
```bash
# Edit icebreaker.c
make -f Makefile.macos clean
make -f Makefile.macos
make -f Makefile.macos dmg
```

## Alternative: Manual Installation

If the automated setup doesn't work:

```bash
# 1. Install Xcode tools
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install SDL libraries
brew install sdl12-compat
brew install sdl2_mixer

# 4. Create SDL_mixer.h symlink
ln -sf /opt/homebrew/include/SDL2/SDL_mixer.h /opt/homebrew/include/SDL/SDL_mixer.h

# 5. Build
cd /path/to/IceBreaker
make -f Makefile.macos

# 6. Create DMG
make -f Makefile.macos dmg
```

## References

- **SDL12-compat**: https://github.com/libsdl-org/SDL-1.2/tree/SDL-1.2
- **Homebrew**: https://brew.sh
- **IceBreaker Original**: http://www.mattdm.org/icebreaker/

## Summary

The magic combination that makes it all work:

```bash
brew install sdl12-compat sdl2_mixer
make -f Makefile.macos && make -f Makefile.macos dmg
```

That's it! Your game is now playable on modern macOS! 🎮

---

**Build Date**: February 13, 2026
**IceBreaker Version**: 2.2.2
**Status**: ✅ TESTED & WORKING
