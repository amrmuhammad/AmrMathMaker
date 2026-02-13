# AmrMathMaker

A desktop tool for creating mathematical educational videos using Manim, built with C++ and Tcl/Tk.

## Features

- GUI interface for creating math animations
- Embedded Tcl/Tk 9.0.3 runtime
- Integration with Manim animation engine
- Cross-platform foundation (Linux first)

## Project Structure

```
AmrMathMaker/
├── CMakeLists.txt          # Build configuration
├── src/                    # C++ source code
│   └── main.cpp            # Main application
├── gui/                    # Tcl/Tk GUI scripts
│   └── main.tcl            # Main interface
├── tcltk/                  # Embedded Tcl/Tk
│   └── src/                # Tcl/Tk source code
└── README.md               # This file
```

## Prerequisites

- CMake 3.10+
- C++17 compiler
- X11 development libraries
- Python 3.x with Manim

## Building

```bash
mkdir build && cd build
cmake ..
make
```

## Running

```bash
export TCL_LIBRARY=$(pwd)/../tcltk/src/tcl9.0.3/library
./AmrMathMaker
```

## License

MIT License

## Author

Amr Muhammad
