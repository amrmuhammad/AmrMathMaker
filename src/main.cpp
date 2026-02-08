// src/main.cpp - Complete embedding example for Tcl/Tk 9.0
#include <tcl.h>
#include <tk.h>
#include <iostream>
#include <string>

// 1. Example C++ function that will become a Tcl command
int SayHello_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    std::cout << "[C++ Engine] Hello from C++!" << std::endl;
    
    // Send a result back to Tcl
    Tcl_SetObjResult(interp, Tcl_NewStringObj("Hello from C++ command!", -1));
    return TCL_OK;
}

// 2. Another example command that adds numbers
int AddNumbers_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    if (objc != 3) {
        Tcl_WrongNumArgs(interp, 1, objv, "number1 number2");
        return TCL_ERROR;
    }
    
    // Get arguments from Tcl
    int a, b;
    Tcl_GetIntFromObj(interp, objv[1], &a);
    Tcl_GetIntFromObj(interp, objv[2], &b);
    
    int result = a + b;
    
    // Send result back to Tcl
    Tcl_SetObjResult(interp, Tcl_NewIntObj(result));
    std::cout << "[C++ Engine] Added " << a << " + " << b << " = " << result << std::endl;
    return TCL_OK;
}

int main(int argc, char* argv[]) {
    std::cout << "Starting Manim GUI Engine..." << std::endl;
    
    // 3. Initialize Tcl library
    Tcl_FindExecutable(argv[0]);
    
    // 4. Create the Tcl interpreter
    Tcl_Interp* interp = Tcl_CreateInterp();
    if (!interp) {
        std::cerr << "Failed to create Tcl interpreter!" << std::endl;
        return 1;
    }
    
    // 5. Initialize Tcl
    if (Tcl_Init(interp) != TCL_OK) {
        std::cerr << "Tcl_Init failed: " << Tcl_GetStringResult(interp) << std::endl;
        return 1;
    }
    
    // 6. Initialize Tk
    if (Tk_Init(interp) != TCL_OK) {
        std::cerr << "Tk_Init failed: " << Tcl_GetStringResult(interp) << std::endl;
        return 1;
    }
    
    std::cout << "Tcl/Tk initialized successfully!" << std::endl;
    
    // 7. Register our C++ functions as Tcl commands
    Tcl_CreateObjCommand(interp, "say_hello", SayHello_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "add_numbers", AddNumbers_CPP, nullptr, nullptr);
    
    std::cout << "C++ commands registered!" << std::endl;
    
    // 8. Test our C++ commands from Tcl
    const char* testCommands = 
        "puts \"Testing C++ integration...\"\n"
        "set result [say_hello]\n"
        "puts \"C++ says: $result\"\n"
        "set sum [add_numbers 25 17]\n"
        "puts \"25 + 17 = $sum\"";
    
    if (Tcl_Eval(interp, testCommands) != TCL_OK) {
        std::cerr << "Test failed: " << Tcl_GetStringResult(interp) << std::endl;
    }
    
    // 9. Load and run the main Tcl/Tk GUI
    std::cout << "Loading GUI from gui/main.tcl..." << std::endl;
    
    // First, let's check if the file exists
    const char* checkFile = "if {[file exists \"gui/main.tcl\"]} { puts \"GUI file found\" } else { puts \"Creating basic GUI...\" }";
    Tcl_Eval(interp, checkFile);
    
    // Create a basic GUI if the file doesn't exist yet
    const char* basicGUI = 
        "proc create_basic_gui {} {\n"
        "    wm title . \"Manim GUI Tool\"\n"
        "    wm geometry . 800x600\n"
        "    \n"
        "    # Create a menu bar\n"
        "    menu .menubar\n"
        "    . configure -menu .menubar\n"
        "    \n"
        "    # File menu\n"
        "    menu .menubar.file -tearoff 0\n"
        "    .menubar add cascade -label \"File\" -menu .menubar.file\n"
        "    .menubar.file add command -label \"New Project\" -command {puts \"New Project\"}\n"
        "    .menubar.file add command -label \"Open\" -command {puts \"Open\"}\n"
        "    .menubar.file add separator\n"
        "    .menubar.file add command -label \"Exit\" -command {exit}\n"
        "    \n"
        "    # Main frame\n"
        "    frame .main -bg white\n"
        "    pack .main -fill both -expand 1\n"
        "    \n"
        "    # Left panel for tools\n"
        "    frame .main.tools -width 200 -bg lightgray\n"
        "    pack .main.tools -side left -fill y\n"
        "    \n"
        "    label .main.tools.title -text \"Tools\" -bg lightgray -font {Arial 12 bold}\n"
        "    pack .main.tools.title -pady 10\n"
        "    \n"
        "    button .main.tools.circle -text \"Add Circle\" -command {puts \"Add Circle\"}\n"
        "    button .main.tools.square -text \"Add Square\" -command {puts \"Add Square\"}\n"
        "    button .main.tools.text -text \"Add Text\" -command {puts \"Add Text\"}\n"
        "    \n"
        "    pack .main.tools.circle .main.tools.square .main.tools.text -pady 5 -padx 10 -fill x\n"
        "    \n"
        "    # Main canvas area\n"
        "    canvas .main.canvas -bg white -relief sunken -bd 2\n"
        "    pack .main.canvas -side left -fill both -expand 1 -padx 10 -pady 10\n"
        "    \n"
        "    # Bottom status bar\n"
        "    frame .status -height 20 -bg lightblue\n"
        "    pack .status -fill x -side bottom\n"
        "    \n"
        "    label .status.text -text \"Ready\" -bg lightblue\n"
        "    pack .status.text -side left -padx 10\n"
        "    \n"
        "    # Test button that calls C++\n"
        "    button .test -text \"Test C++ Command\" -command {\n"
        "        set result [say_hello]\n"
        "        .status.text configure -text $result\n"
        "    }\n"
        "    pack .test -pady 20\n"
        "    \n"
        "    puts \"Basic GUI created successfully!\"\n"
        "}\n"
        "\n"
        "create_basic_gui";
    
    // Try to load external GUI file, fall back to basic GUI
    int loadResult = Tcl_EvalFile(interp, "gui/main.tcl");
    if (loadResult != TCL_OK) {
        std::cout << "No external GUI file found, creating basic interface..." << std::endl;
        Tcl_Eval(interp, basicGUI);
    }
    
    std::cout << "Starting Tk main loop..." << std::endl;
    
    // 10. Start the Tk event loop (this blocks until window closes)
    Tk_MainLoop();
    
    std::cout << "Application shutdown." << std::endl;
    
    // 11. Cleanup
    Tcl_DeleteInterp(interp);
    
    return 0;
}
