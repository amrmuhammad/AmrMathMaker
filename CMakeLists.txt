cmake_minimum_required(VERSION 3.10)
project(AmrMathMaker)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set the correct path to your Tcl/Tk build
set(TCLTK_ROOT "/home/amrmuhammad/dev/AmrMathMaker/tcltk/build")
message(STATUS "Tcl/Tk path: ${TCLTK_ROOT}")

# Verify the directory exists
if(NOT EXISTS "${TCLTK_ROOT}")
    message(FATAL_ERROR "Tcl/Tk directory not found: ${TCLTK_ROOT}")
endif()

# Set the correct library paths (based on your ls output)
set(TCL_LIBRARY "${TCLTK_ROOT}/lib/libtcl9.0.a")
set(TK_LIBRARY "${TCLTK_ROOT}/lib/libtcl9tk9.0.a")  # Note: libtcl9tk9.0.a, not libtk9.0.a

# Verify libraries exist
if(NOT EXISTS "${TCL_LIBRARY}")
    message(FATAL_ERROR "Tcl library not found: ${TCL_LIBRARY}")
endif()

if(NOT EXISTS "${TK_LIBRARY}")
    message(FATAL_ERROR "Tk library not found: ${TK_LIBRARY}")
endif()

message(STATUS "Using Tcl library: ${TCL_LIBRARY}")
message(STATUS "Using Tk library: ${TK_LIBRARY}")

# Include directories
include_directories(
    ${TCLTK_ROOT}/include
    ${CMAKE_SOURCE_DIR}/src
)

# Find X11
find_package(X11 REQUIRED)
if(X11_FOUND)
    message(STATUS "Found X11 libraries")
else()
    message(FATAL_ERROR "X11 not found - install libx11-dev")
endif()

# Create executable
add_executable(AmrMathMaker src/main.cpp)

# Link libraries - IMPORTANT: Tk must come AFTER Tcl
target_link_libraries(AmrMathMaker
    ${TCL_LIBRARY}
    ${TK_LIBRARY}
    ${X11_LIBRARIES}
    -lX11 -lXss -lXext -lXft -lfontconfig -lXrender
    -lfreetype -lexpat -lpng -lz -ljpeg
    -ldl -lm -lpthread
)

# Copy GUI files
file(COPY ${CMAKE_SOURCE_DIR}/gui DESTINATION ${CMAKE_BINARY_DIR})
