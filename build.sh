#!/bin/bash
set -e

echo "=== Building AmrMathMaker ==="

# Check for dependencies
if ! command -v cmake &> /dev/null; then
    echo "Error: CMake is required. Install with: sudo apt-get install cmake"
    exit 1
fi

if ! command -v g++ &> /dev/null; then
    echo "Error: g++ is required. Install with: sudo apt-get install g++"
    exit 1
fi

# Check for X11 libraries
echo "Checking for X11 development libraries..."
if ! pkg-config --exists x11 xext xft xrender fontconfig; then
    echo "Installing required libraries..."
    sudo apt-get update
    sudo apt-get install -y libx11-dev libxext-dev libxft-dev \
                            libxrender-dev libfontconfig-dev
fi

# Create build directory
mkdir -p build
cd build

# Configure and build
echo "Configuring with CMake..."
cmake ..

echo "Compiling..."
make -j$(nproc)

echo "=== Build Complete ==="
echo "Run with: export TCL_LIBRARY=\$(pwd)/../tcltk/src/tcl9.0.3/library && ./AmrMathMaker"
