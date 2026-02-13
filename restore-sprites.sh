#!/bin/bash
# Scale sprites back from 24x24 to 14x14 (approximately)

echo "Restoring original sprite sizes..."

# Scale back 24x24 to 14x14
for img in atom star woodblock; do
    if [ -f "${img}.bmp" ]; then
        echo "  Restoring ${img}.bmp: 24x24 → 14x14"
        convert "${img}.bmp" -resize 14x14 "${img}.bmp"
    fi
done

# Scale back 21-24x22-24 to approximately 12-14x13-14
for img in cow penguin kitty mouse mouse-r turtle; do
    if [ -f "${img}.bmp" ]; then
        echo "  Restoring ${img}.bmp to original size"
        convert "${img}.bmp" -resize 14x13 "${img}.bmp"
    fi
done

# Scale back 82x82 and 55x55 to original sizes
if [ -f "icebreaker_48.bmp" ]; then
    echo "  Restoring icebreaker_48.bmp: 82x82 → 48x48"
    convert "icebreaker_48.bmp" -resize 48x48 "icebreaker_48.bmp"
fi

if [ -f "penguinicon_32.bmp" ]; then
    echo "  Restoring penguinicon_32.bmp: 55x55 → 32x32"
    convert "penguinicon_32.bmp" -resize 32x32 "penguinicon_32.bmp"
fi

echo "✓ Sprites restored!"
