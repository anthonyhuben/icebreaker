#!/bin/bash
# Build IceBreaker with a specific window scale
# Usage: ./build-with-scale.sh 2   # builds 2x version (default)
#        ./build-with-scale.sh 3   # builds 3x version

SCALE="${1:-2}"

if [ "$SCALE" != "2" ] && [ "$SCALE" != "3" ]; then
    echo "Error: Scale must be 2 or 3"
    echo "Usage: $0 [2|3]"
    exit 1
fi

echo "Building IceBreaker with ${SCALE}x window scaling..."

# Scale sprite files based on requested scale
SPRITE_SIZE=$((14 * SCALE))
echo "Scaling sprites to ${SPRITE_SIZE}x${SPRITE_SIZE} pixels..."

for sprite in penguin.bmp mouse.bmp mouse-r.bmp kitty.bmp cow.bmp turtle.bmp atom.bmp star.bmp woodblock.bmp; do
    sips -z "$SPRITE_SIZE" "$SPRITE_SIZE" "$sprite" --out "$sprite.tmp" 2>/dev/null
    mv "$sprite.tmp" "$sprite"
done

# Update the SCALE macro in icebreaker.h
sed -i.bak "s/#define SCALE [0-9]/#define SCALE $SCALE/" icebreaker.h

# Clean and build
echo "Building application..."
make -f Makefile.macos clean > /dev/null
make -f Makefile.macos 2>&1 | tail -5

# Create DMG
echo "Creating DMG installer..."
make -f Makefile.macos dmg 2>&1 | tail -3

echo ""
if [ $SCALE -eq 2 ]; then
    echo "✓ Built ${SCALE}x version (1000×714 pixels)"
else
    echo "✓ Built ${SCALE}x version (1500×1071 pixels)"
fi
echo "  App: IceBreaker.app/Contents/MacOS/icebreaker"
echo "  DMG: icebreaker-2.2.2.dmg"
