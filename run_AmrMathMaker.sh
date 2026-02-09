#!/bin/bash


export CURRENT_DIR=$(pwd)

export TCL_LIBRARY="${CURRENT_DIR}/tcltk/src/tcl9.0.3/library"

export TK_LIBRARY="${CURRENT_DIR}/tcltk/src/tk9.0.3/library"



${CURRENT_DIR}/build/AmrMathMaker
