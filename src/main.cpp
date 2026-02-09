// src/main.cpp - Complete embedding example for Tcl/Tk 9.0
#include <tcl.h>
#include <tk.h>

#include <fstream>
#include <cstdlib>
#include <array>
#include <memory>
#include <vector>
#include <iostream>
#include <string>

#include "Equation.hpp"



// Global storage for equations
std::vector<MathEquation> equations;


// Add this struct for render options
struct RenderOptions {
    std::string quality = "-ql";  // -ql (low), -qm (medium), -qh (high)
    std::string filename = "render_output";
    bool open_after_render = false;
};
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// The main render function that Tcl calls
int RenderScene_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    std::cout << "[C++] RenderScene_CPP called with " << objc << " arguments" << std::endl;
    
    // Parse optional arguments
    RenderOptions options;
    if (objc > 1) {
        options.quality = Tcl_GetString(objv[1]);
        if (objc > 2) {
            options.filename = Tcl_GetString(objv[2]);
        }
    }
    
    try {
        // 1. Generate the Manim Python script
        std::string script_path = options.filename + ".py";
        std::cout << "[C++] Generating script: " << script_path << std::endl;
        
        std::ofstream manim_script(script_path);
        if (!manim_script.is_open()) {
            throw std::runtime_error("Could not open script file for writing");
        }
        
        // Write the Manim script header
        manim_script << "from manim import *\n\n";
        manim_script << "class GeneratedScene(Scene):\n";
        manim_script << "    def construct(self):\n";
        
        // Check if we have equations to render
        if (equations.empty()) {
            manim_script << "        # No equations to render\n";
            manim_script << "        text = Text(\"No equations in scene\", font_size=24)\n";
            manim_script << "        self.play(Write(text))\n";
            manim_script << "        self.wait(1)\n";
        } else {
            // Add each equation to the script
            std::cout << "[C++] Adding " << equations.size() << " equations to script" << std::endl;
            
            for (size_t i = 0; i < equations.size(); i++) {
                const auto& eq = equations[i];
                
                manim_script << "        # Equation " << i << "\n";
                manim_script << "        eq" << i << " = MathTex(r\"" 
                            << eq.latex << "\")\n";
                manim_script << "        eq" << i << ".move_to([" 
                            << eq.x << ", " << eq.y << ", 0])\n";
                manim_script << "        eq" << i << ".set_color(\"" 
                            << eq.color << "\")\n";
                manim_script << "        eq" << i << ".scale(" 
                            << eq.scale << ")\n";
                
                // Different animation based on position
                if (i == 0) {
                    manim_script << "        self.play(Write(eq" << i << "))\n";
                } else {
                    manim_script << "        self.play(TransformFromCopy(eq" << (i-1) << ", eq" << i << "))\n";
                }
                manim_script << "        self.wait(0.5)\n\n";
            }
        }
        
        manim_script.close();
        std::cout << "[C++] Script generated successfully" << std::endl;
        
        // 2. Execute Manim
        std::string command = "python -m manim " + script_path + " " + options.quality + " 2>&1";
        std::cout << "[C++] Executing: " << command << std::endl;
        
        // Execute and capture output
        std::array<char, 128> buffer;
        std::string result;
        std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(command.c_str(), "r"), pclose);
        
        if (!pipe) {
            throw std::runtime_error("Failed to execute manim command");
        }
        
        while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
            result += buffer.data();
        }
        
        // Check if render was successful
        if (result.find("File ready at") != std::string::npos) {
            std::cout << "[C++] Render successful!" << std::endl;
            
            // Extract video path from output
            size_t pos = result.find("File ready at");
            if (pos != std::string::npos) {
                std::string video_path = result.substr(pos + 13);
                // Trim newlines
                video_path.erase(video_path.find_last_not_of("\n\r") + 1);
                std::cout << "[C++] Video: " << video_path << std::endl;
            }
            
            Tcl_SetObjResult(interp, Tcl_NewStringObj("✓ Video rendered successfully!", -1));
            return TCL_OK;
        } else {
            std::cerr << "[C++] Render failed. Output:\n" << result << std::endl;
            Tcl_SetObjResult(interp, Tcl_NewStringObj(("✗ Render failed: " + result.substr(0, 100)).c_str(), -1));
            return TCL_ERROR;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "[C++] Exception during render: " << e.what() << std::endl;
        Tcl_SetObjResult(interp, Tcl_NewStringObj(("✗ Error: " + std::string(e.what())).c_str(), -1));
        return TCL_ERROR;
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Helper function to get render status
int GetRenderStatus_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    std::string status = "Ready";
    if (!equations.empty()) {
        status += " (" + std::to_string(equations.size()) + " equations)";
    }
    Tcl_SetObjResult(interp, Tcl_NewStringObj(status.c_str(), -1));
    return TCL_OK;
}

// Clear all equations
int ClearEquations_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    std::cout << "[C++] Clearing " << equations.size() << " equations" << std::endl;
    equations.clear();
    Tcl_SetObjResult(interp, Tcl_NewStringObj("All equations cleared", -1));
    return TCL_OK;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


int AddEquation_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    if (objc != 4) {
        Tcl_WrongNumArgs(interp, 1, objv, "latex_text x y");
        return TCL_ERROR;
    }
    
    const char* latex = Tcl_GetString(objv[1]);
    double x, y;
    
    if (Tcl_GetDoubleFromObj(interp, objv[2], &x) != TCL_OK ||
        Tcl_GetDoubleFromObj(interp, objv[3], &y) != TCL_OK) {
        return TCL_ERROR;
    }
    
    // Add to equations vector
    equations.emplace_back(latex, x, y);
    
    std::cout << "[C++] Added equation: " << latex << " at (" << x << ", " << y << ")" << std::endl;
    
    // Return success with equation ID
    int eq_id = equations.size() - 1;
    Tcl_SetObjResult(interp, Tcl_NewStringObj(("Equation #" + std::to_string(eq_id) + " added").c_str(), -1));
    return TCL_OK;
}

int ListEquations_CPP(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[]) {
    // Return list of equations as Tcl list
    Tcl_Obj* result = Tcl_NewListObj(0, NULL);
    
    for (size_t i = 0; i < equations.size(); i++) {
        const auto& eq = equations[i];
        Tcl_Obj* eq_obj = Tcl_NewStringObj(("Eq#" + std::to_string(i) + ": " + eq.latex).c_str(), -1);
        Tcl_ListObjAppendElement(interp, result, eq_obj);
    }
    
    Tcl_SetObjResult(interp, result);
    return TCL_OK;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // 7. Register our C++ functions as Tcl commands
    Tcl_CreateObjCommand(interp, "say_hello", SayHello_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "add_numbers", AddNumbers_CPP, nullptr, nullptr);
    
    // Register equation commands
    Tcl_CreateObjCommand(interp, "add_equation", AddEquation_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "list_equations", ListEquations_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "render_scene", RenderScene_CPP, nullptr, nullptr);  // ADD THIS
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    Tcl_CreateObjCommand(interp, "render_scene", RenderScene_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "get_render_status", GetRenderStatus_CPP, nullptr, nullptr);
    Tcl_CreateObjCommand(interp, "clear_all_equations", ClearEquations_CPP, nullptr, nullptr);

    // Also add a test command
    Tcl_CreateObjCommand(interp, "test_render_setup", [](ClientData, Tcl_Interp* interp, int, Tcl_Obj* const[]) -> int {
        // Test if Manim is available
        int result = system("python -c \"import manim; print('Manim found:', manim.__version__)\" 2>&1");
        Tcl_SetObjResult(interp, Tcl_NewStringObj((result == 0) ? "Manim is ready" : "Manim not found", -1));
        return TCL_OK;
    }, nullptr, nullptr);
    ///////////////////////////////////////////////////////////////////////////////////////////////////
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
    ///////////////////////////////////////////////////////////////////////////////////////////////////
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
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    std::cout << "Starting Tk main loop..." << std::endl;
    
    // 10. Start the Tk event loop (this blocks until window closes)
    Tk_MainLoop();
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    std::cout << "Application shutdown." << std::endl;
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // 11. Cleanup
    Tcl_DeleteInterp(interp);
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    return 0;
}
