#!/bin/bash
# Scale sprite images from 14x14 to 24x24 (and others proportionally)

if ! command -v convert &> /dev/null; then
    echo "ImageMagick (convert) not found. Installing via Homebrew..."
    brew install imagemagick
fi

echo "Scaling sprites from 14x14 to 24x24..."

# Scale 14x14 sprites to 24x24
for img in atom star woodblock; do
    if [ -f "${img}.bmp" ]; then
        echo "  Scaling ${img}.bmp: 14x14 → 24x24"
        convert "${img}.bmp" -resize 24x24 "${img}.bmp"
    fi
done

# Scale 12-14x13-14 sprites to approximately 20-21x24
for img in cow penguin kitty mouse mouse-r turtle; do
    if [ -f "${img}.bmp" ]; then
        orig_size=$(identify "${img}.bmp" | awk '{print $3}')
        echo "  Scaling ${img}.bmp: ${orig_size} → ~24x24"
        convert "${img}.bmp" -resize 24x24 "${img}.bmp"
    fi
done

# Scale 48x48 and 32x32 icons proportionally
if [ -f "icebreaker_48.bmp" ]; then
    echo "  Scaling icebreaker_48.bmp: 48x48 → 82x82 (scaled proportionally)"
    convert "icebreaker_48.bmp" -resize 82x82 "icebreaker_48.bmp"
fi

if [ -f "penguinicon_32.bmp" ]; then
    echo "  Scaling penguinicon_32.bmp: 32x32 → 55x55 (scaled proportionally)"
    convert "penguinicon_32.bmp" -resize 55x55 "penguinicon_32.bmp"
fi

echo "✓ Sprites scaled successfully!"
