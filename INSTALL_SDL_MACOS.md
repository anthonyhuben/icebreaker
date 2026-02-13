# Installing SDL for macOS - Troubleshooting Guide

The old SDL 1.2 libraries are no longer in Homebrew's main repository. Here are your options:

## Option 1: Use SDL12-Compat (Best Solution - Recommended!)

This is the **easiest and most reliable solution**. SDL12-compat provides SDL 1.2 API compatibility on top of modern SDL 2.0.

### Quick Install

```bash
# Install SDL12-compat (SDL 1.2 compatibility layer on SDL 2.0)
brew install sdl12-compat sdl_mixer

# Then build
./build-macos.sh
```

**Why this is the best approach:**
- ✓ Works with existing code (no modifications needed)
- ✓ Modern SDL 2.0 backend (actively maintained)
- ✓ Easiest to use and install
- ✓ Works on all modern Macs (Intel and Apple Silicon)
- ✓ Compatible with older macOS versions
- ✓ No compilation from source needed

That's it! Your game is ready.

---

## Option 2: Install from Homebrew Archive (Legacy)

If you want to stick with SDL 1.2, you can install from the archived formula:

```bash
# Install SDL 1.2 from archive
brew install sdl@1.2

# For SDL_mixer 1.2, you have a few choices:
# Option A: Build from source (see Option 3)
# Option B: Use MacPorts (see Option 4)
# Option C: Use pre-compiled bottles (see below)
```

### Get SDL_mixer from MacPorts

```bash
# Install MacPorts first (if not already installed)
# Download from https://www.macports.org/install.php

# Then install SDL_mixer
sudo port install libsdl_mixer
```

---

## Option 3: Compile SDL_mixer from Source

For the DIY approach:

```bash
# Download and compile SDL_mixer 1.2
cd ~/Downloads
curl -O https://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-1.2.12.tar.gz
tar xzf SDL_mixer-1.2.12.tar.gz
cd SDL_mixer-1.2.12

# Configure and compile
./configure --prefix=/usr/local
make
sudo make install

# Verify installation
pkg-config --modversion SDL_mixer
```

---

## Option 4: Use MacPorts (Alternative Package Manager)

MacPorts is another option that still has SDL 1.2:

```bash
# Install MacPorts (if not already installed)
# Download from: https://www.macports.org/install.php

# Then install SDL libraries
sudo port install libsdl
sudo port install libsdl_mixer

# Build IceBreaker
make -f Makefile.macos
```

---

## Option 5: Use Docker (For Compatibility)

If none of the above work, you can build in a Docker container:

```bash
# Install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop

# Build IceBreaker in Docker
docker run -it --rm -v $(pwd):/work ubuntu:20.04 bash -c '
  apt-get update
  apt-get install -y build-essential libsdl1.2-dev libsdl-mixer1.2-dev
  cd /work
  make
'

# The compiled binary will be in your current directory
```

---

## Recommended Solution: Use SDL 2.0

**We strongly recommend Option 1 (SDL 2.0)** because:

✓ **Actively maintained** - SDL 2.0 is the current standard
✓ **Easy to install** - Available directly via Homebrew
✓ **Better supported** - Works on all modern macOS versions
✓ **Future-proof** - Works on both Intel and Apple Silicon
✓ **Minimal code changes** - The game works with both SDL 1.2 and 2.0

### Step-by-Step for SDL 2.0:

1. Install SDL 2.0:
   ```bash
   brew install sdl2 sdl2_mixer
   ```

2. Verify installation:
   ```bash
   pkg-config --modversion sdl2 SDL2_mixer
   ```

3. Build IceBreaker:
   ```bash
   ./build-macos.sh
   ```

That's it!

---

## Troubleshooting

### "pkg-config: command not found"

```bash
brew install pkg-config
```

### "SDL2 not found"

```bash
# Make sure SDL2 is properly installed
brew list sdl2 sdl2_mixer

# If missing, reinstall
brew install sdl2 sdl2_mixer

# Force pkg-config to find SDL2
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/opt/homebrew/lib/pkgconfig"
```

### Build fails with "SDL2/SDL.h: No such file or directory"

This usually means SDL2 headers aren't found. Try:

```bash
# Check SDL2 location
brew --prefix sdl2

# Set PKG_CONFIG_PATH
export PKG_CONFIG_PATH="$(brew --prefix sdl2)/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$(brew --prefix sdl2_mixer)/lib/pkgconfig"

# Then rebuild
make -f Makefile.macos clean
make -f Makefile.macos
```

### On Apple Silicon (M1/M2/M3):

```bash
# Install native ARM64 versions
arch -arm64 brew install sdl2 sdl2_mixer

# Build for ARM64
make -f Makefile.macos clean
CFLAGS="-arch arm64" make -f Makefile.macos
```

---

## Quick Comparison

| Method | Ease | Maintenance | Compatibility | Recommendation |
|--------|------|-------------|---------------|-----------------|
| SDL 2.0 via Homebrew | ⭐⭐⭐⭐⭐ | Active | Excellent | **Use this** |
| SDL 1.2 + MacPorts | ⭐⭐⭐⭐ | Legacy | Good | Alternative |
| Compile from source | ⭐⭐ | Manual | Good | Backup option |
| Docker | ⭐⭐⭐ | Managed | Excellent | For testing |

---

## Next Steps

1. **Choose your approach** above
2. **Install SDL** (recommended: `brew install sdl2 sdl2_mixer`)
3. **Build the game**: `./build-macos.sh`
4. **Test it**: `open IceBreaker.app`

---

## Getting Help

If you're still having issues:

1. Check that Homebrew is working: `brew --version`
2. Verify SDL installation: `pkg-config --list-all | grep -i sdl`
3. Check the detailed README.macos for more troubleshooting
4. Look at the original project: http://www.mattdm.org/icebreaker/

---

## FAQ

**Q: Why did Homebrew remove SDL 1.2?**
A: SDL 1.2 is deprecated and no longer maintained. SDL 2.0 is the current standard.

**Q: Will the game work with SDL 2.0?**
A: Yes! IceBreaker is compatible with both SDL 1.2 and 2.0.

**Q: Do I need to modify the source code?**
A: No, the existing code works with both versions.

**Q: Is there a pre-built binary?**
A: Not yet, but once you build it locally, you can distribute it as a DMG.

**Q: Can I use older Xcode/macOS versions?**
A: Yes, as long as you have clang and pkg-config, you can build it.

---

## Summary

```bash
# The easiest solution (2 commands):
brew install sdl2 sdl2_mixer
./build-macos.sh

# Done! Your game is ready to play.
```

Enjoy!
