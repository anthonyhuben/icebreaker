#!/bin/bash
# Bundle all SDL libraries and their dependencies into the app

set -e

APP_PATH="${1:-.}"
BUNDLE="$APP_PATH/IceBreaker.app"
EXEC="$BUNDLE/Contents/MacOS/icebreaker"
LIB_DIR="$BUNDLE/Contents/Frameworks"

if [ ! -f "$EXEC" ]; then
    echo "Error: Executable not found at $EXEC"
    exit 1
fi

echo "Bundling libraries for: $BUNDLE"
mkdir -p "$LIB_DIR"

# Function to copy a library and all its dependencies
copy_library_recursive() {
    local lib="$1"
    local copied_file="$LIB_DIR/$(basename "$lib")"

    if [ -f "$copied_file" ]; then
        echo "  → $(basename "$lib") already copied"
        return
    fi

    echo "  → Copying $(basename "$lib")..."
    cp -v "$lib" "$LIB_DIR/"
    chmod 755 "$copied_file"

    # Find all dependencies and copy them
    local deps=$(otool -L "$lib" | grep /opt/homebrew | awk '{print $1}')
    for dep in $deps; do
        if [ -f "$dep" ] && [ "$(basename "$dep")" != "$(basename "$lib")" ]; then
            local dep_file="$LIB_DIR/$(basename "$dep")"
            if [ ! -f "$dep_file" ]; then
                copy_library_recursive "$dep"
            fi
        fi
    done
}

# Copy main libraries
echo "Step 1: Copying libraries..."
copy_library_recursive "/opt/homebrew/opt/sdl12-compat/lib/libSDL-1.2.0.dylib"
copy_library_recursive "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib"
copy_library_recursive "/opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib"

# Now we need to fix references
echo ""
echo "Step 2: Fixing library references..."

# Fix the main executable
install_name_tool -change /opt/homebrew/opt/sdl12-compat/lib/libSDL-1.2.0.dylib @loader_path/../Frameworks/libSDL-1.2.0.dylib "$EXEC" 2>/dev/null || true
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @loader_path/../Frameworks/libSDL2-2.0.0.dylib "$EXEC" 2>/dev/null || true
install_name_tool -change /opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib @loader_path/../Frameworks/libSDL2_mixer-2.0.0.dylib "$EXEC" 2>/dev/null || true

# Fix library references to each other AND fix library IDs
for lib in "$LIB_DIR"/*.dylib; do
    libname=$(basename "$lib")
    echo "  Fixing references in $libname..."

    # First, check if the library's own ID needs fixing (it should point to itself via @rpath or relative path)
    own_id=$(otool -D "$lib" | tail -1)
    if [[ "$own_id" == /opt/homebrew/* ]]; then
        echo "    → Fixing library ID: $own_id → @loader_path/$libname"
        install_name_tool -id @loader_path/$libname "$lib" 2>/dev/null || true
    fi

    # Get all homebrew dependencies
    deps=$(otool -L "$lib" | grep /opt/homebrew | awk '{print $1}' || true)
    for dep in $deps; do
        depname=$(basename "$dep")
        if [ -f "$LIB_DIR/$depname" ]; then
            echo "    → Fixing dependency: $dep → @loader_path/$depname"
            install_name_tool -change "$dep" @loader_path/$depname "$lib" 2>/dev/null || true
        fi
    done
done

echo "✓ Libraries bundled successfully!"
echo "Bundle location: $LIB_DIR"
ls -lh "$LIB_DIR"
