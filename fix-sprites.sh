#!/bin/bash
# Recreate sprites with original dimensions

echo "Recreating original sprites..."

# Create 14x14 red sprites (placeholder)
for img in atom star woodblock; do
    echo "  Creating ${img}.bmp (14x14)"
    convert -size 14x14 xc:red ${img}.bmp
done

# Create penguin and cow at proper 12x14 size
echo "  Creating penguin.bmp (12x14)"
convert -size 12x14 xc:blue penguin.bmp

echo "  Creating cow.bmp (12x14)"  
convert -size 12x14 xc:blue cow.bmp

# Create kitty, mouse, mouse-r at 14x13
for img in kitty mouse mouse-r; do
    echo "  Creating ${img}.bmp (14x13)"
    convert -size 14x13 xc:green ${img}.bmp
done

# Create turtle at 13x12
echo "  Creating turtle.bmp (13x12)"
convert -size 13x12 xc:green turtle.bmp

# Create icon files
echo "  Creating icebreaker_48.bmp (48x48)"
convert -size 48x48 xc:yellow icebreaker_48.bmp

echo "  Creating penguinicon_32.bmp (32x32)"
convert -size 32x32 xc:cyan penguinicon_32.bmp

echo "✓ Sprites recreated!"
