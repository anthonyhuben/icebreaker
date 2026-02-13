# IceBreaker Window Scaling Options

IceBreaker now supports multiple window scaling levels. The game defaults to **2x scaling** (1000×714 pixels) but can be built with **3x scaling** (1500×1071 pixels) for users with larger displays.

## Default Build (2x Scaling)

To build the standard 2x scaled version:

```bash
make -f Makefile.macos
```

Or explicitly:

```bash
./build-with-scale.sh 2
```

**Window Size**: 1000×714 pixels
**Block Size**: 28×28 pixels
**Grid**: 32×20 blocks (same gameplay, larger display)

## Building with 3x Scaling

To build the larger 3x scaled version:

```bash
./build-with-scale.sh 3
```

**Window Size**: 1500×1071 pixels
**Block Size**: 42×42 pixels
**Grid**: 32×20 blocks (same gameplay, even larger display)

## The build-with-scale.sh Script

The `build-with-scale.sh` script automates the scaling process:

1. Scales all sprite graphics appropriately
2. Updates the SCALE macro in `icebreaker.h`
3. Cleans the build artifacts
4. Recompiles the application
5. Creates the DMG installer

Usage:

```bash
./build-with-scale.sh [2|3]
```

- `2` - Build 2x scaled version (1000×714) — **default**
- `3` - Build 3x scaled version (1500×1071)

## What Gets Scaled

### Block Dimensions
- **2x**: 28×28 pixels per block
- **3x**: 42×42 pixels per block

### Margins (UI borders)
All margins scale proportionally with the block size.

### Game Sprites
All penguin sprite graphics scale to match the new block dimensions:
- `penguin.bmp`, `mouse.bmp`, `mouse-r.bmp`
- `kitty.bmp`, `cow.bmp`, `turtle.bmp`
- `atom.bmp`, `star.bmp`, `woodblock.bmp`

### Grid
The game grid remains **32 columns × 20 rows** regardless of scaling. Only the visual size changes.

## Command-Line Options

While the `--scale` command-line option is documented, window scaling must be configured at build time by selecting which version to compile.

To use the 3x version, rebuild with:

```bash
./build-with-scale.sh 3
```

## Distribution

- **2x version** (standard): `icebreaker-2.2.2.dmg` (3.4 MB)
  - Recommended for most users
  - Better for older or smaller displays

- **3x version** (large): Build and create DMG with `./build-with-scale.sh 3`
  - For users with high-resolution displays
  - More screen real estate for gameplay

## Technical Details

The scaling is implemented through C preprocessor macros in `icebreaker.h`:

```c
#define SCALE 2              // or 3
#define BLOCKWIDTH (14*SCALE)
#define BLOCKHEIGHT (14*SCALE)
#define PLAYWIDTH (COLS*BLOCKWIDTH)
#define PLAYHEIGHT (ROWS*BLOCKHEIGHT)
```

All game dimensions are calculated from these macros, so changing the SCALE value automatically scales the entire game display uniformly.
