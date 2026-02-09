# gui/main.tcl - Main GUI for AmrMathMaker Tool
puts "Loading AmrMathMaker GUI Tool..."

# Set window title and size
wm title . "AmrMathMaker Video Tool v1.0"
wm geometry . 1024x768
#############################################################################################
# Create a menu bar
menu .menubar
. configure -menu .menubar

# File menu
menu .menubar.file -tearoff 0
.menubar add cascade -label "File" -menu .menubar.file
.menubar.file add command -label "New Project" -command {new_project}
.menubar.file add command -label "Open..." -command {open_project}
.menubar.file add command -label "Save" -command {save_project}
.menubar.file add separator
.menubar.file add command -label "Exit" -command {exit}

# Edit menu
menu .menubar.edit -tearoff 0
.menubar add cascade -label "Edit" -menu .menubar.edit
.menubar.edit add command -label "Undo" -command {undo_action}
.menubar.edit add command -label "Redo" -command {redo_action}

# Render menu
menu .menubar.render -tearoff 0
.menubar add cascade -label "Render" -menu .menubar.render
.menubar.render add command -label "Render Animation" -command {render_animation}

# Help menu
menu .menubar.help -tearoff 0
.menubar add cascade -label "Help" -menu .menubar.help
.menubar.help add command -label "About" -command {show_about}
############################################################################################
# Main interface with three panels
frame .main
pack .main -fill both -expand 1 -padx 5 -pady 5
############################################################################################
# Left panel: Toolbox
frame .main.toolbox -width 200 -bg #f0f0f0 -relief raised -bd 1
pack .main.toolbox -side left -fill y -padx 2

label .main.toolbox.title -text "TOOLS" -bg #e0e0e0 -font {Arial 10 bold}
pack .main.toolbox.title -fill x -pady 5

# Tool buttons
button .main.toolbox.select -text "Select Tool" -command {set_tool select}
button .main.toolbox.circle -text "Add Circle" -command {set_tool circle}
button .main.toolbox.rect -text "Add Rectangle" -command {set_tool rectangle}
button .main.toolbox.text -text "Add Text" -command {set_tool text}
button .main.toolbox.arrow -text "Add Arrow" -command {set_tool arrow}

foreach btn {select circle rect text arrow} {
    pack .main.toolbox.$btn -fill x -padx 5 -pady 2
}
#############################################################################################
# Center panel: Canvas
frame .main.canvasframe
pack .main.canvasframe -side left -fill both -expand 1 -padx 5

label .main.canvasframe.label -text "ANIMATION CANVAS" -font {Arial 11 bold}
pack .main.canvasframe.label -pady 5

canvas .main.canvasframe.canvas -width 700 -height 500 -bg white -relief sunken -bd 2
pack .main.canvasframe.canvas -fill both -expand 1
#############################################################################################
# Right panel: Properties
frame .main.props -width 250 -bg #f8f8f8 -relief raised -bd 1
pack .main.props -side right -fill y -padx 2

label .main.props.title -text "PROPERTIES" -bg #e8e8e8 -font {Arial 10 bold}
pack .main.props.title -fill x -pady 5

# Property controls
frame .main.props.color -bg #f8f8f8
label .main.props.color.label -text "Color:" -bg #f8f8f8
entry .main.props.color.entry -width 15
.main.props.color.entry insert 0 "#3498db"
pack .main.props.color.label .main.props.color.entry -side left -padx 5
pack .main.props.color -anchor w -padx 10 -pady 5
##############################################################################################
# Bottom panel: Timeline
frame .timeline -height 100 -bg #202020
pack .timeline -fill x -side bottom -pady 5

label .timeline.label -text "TIMELINE" -fg white -bg #202020 -font {Arial 10 bold}
pack .timeline.label -side top -anchor w -padx 10 -pady 5

canvas .timeline.canvas -height 60 -bg #404040 -highlightthickness 0
pack .timeline.canvas -fill x -padx 10 -pady 5
##############################################################################################
# Bottom status bar
frame .status -height 24 -bg #2c3e50
pack .status -fill x -side bottom

label .status.text -text "Ready to create math animations..." -fg white -bg #2c3e50 -font {Arial 9}
pack .status.text -side left -padx 10
##############################################################################################
# Add to your GUI - choose ONE of these locations:

# OPTION A: In a new "Render" frame (recommended for organization)
frame .renderframe -bg #f8f8f8 -relief ridge -bd 2
pack .renderframe -fill x -padx 10 -pady 10 -side bottom

label .renderframe.label -text "Render Controls" -bg #e8e8e8 -font {Arial 11 bold}
pack .renderframe.label -fill x -pady 5

# Main render button
button .renderframe.render -text "▶ Render Video" \
    -bg "#4CAF50" -fg white -font {Arial 12 bold} \
    -activebackground "#45a049" \
    -command render_video
pack .renderframe.render -pady 10 -padx 20

# Status display
label .renderframe.status -text "Ready to render" -bg #f8f8f8
pack .renderframe.status -pady 5

# Progress frame
frame .renderframe.progress -bg #f8f8f8
pack .renderframe.progress -fill x -padx 20 -pady 5

canvas .renderframe.progress.bar -width 200 -height 20 -bg white -relief sunken -bd 1
pack .renderframe.progress.bar -side left

label .renderframe.progress.text -text "0%" -bg #f8f8f8 -width 5
pack .renderframe.progress.text -side left -padx 10

# Hide progress initially
pack forget .renderframe.progress

# OPTION B: Simple button in existing toolbar (if you prefer minimal)
# button .toolbar.render -text "Render" -command render_video
# pack .toolbar.render -side left -padx 5
##############################################################################################


# Test C++ integration button
button .testcpp -text "Test C++ Integration" -command {
    set result [say_hello]
    .status.text configure -text $result
}
pack .testcpp -pady 10

# Button to test addition
button .testadd -text "Test Addition (C++)" -command {
    set sum [add_numbers 42 58]
    .status.text configure -text "42 + 58 = $sum (calculated in C++)"
}
pack .testadd -pady 5

##############################################################################################
# Add to your toolbox panel or create a new "Math" panel
frame .main.toolbox.math -width 150 -bg #f0f0f0 -relief raised -bd 1
pack .main.toolbox.math -side left -fill y -padx 2 

label .main.toolbox.math.title -text "Math Symbols" -bg #e0e0e0 -font {Arial 10 bold}
pack .main.toolbox.math.title -fill x -pady 5

# Common math symbols
set symbols {
    alpha    "\\alpha"    beta    "\\beta"
    gamma    "\\gamma"    delta   "\\delta"
    theta    "\\theta"    pi      "\\pi"
    sum      "\\sum"      int     "\\int"
    frac     "\\frac{}{}" sqrt    "\\sqrt{}"
    infty    "\\infty"    pm      "\\pm"
    times    "\\times"    div     "\\div"
    leq      "\\leq"      geq     "\\geq"
    neq      "\\neq"      approx  "\\approx"
}

foreach {name symbol} $symbols {
    button .main.toolbox.math.$name -text $symbol -command "insert_math_symbol \"$symbol\""
    pack .main.toolbox.math.$name -fill x -padx 5 -pady 2
}

# Equation entry field
frame .main.toolbox.math.eqentry -bg #f0f0f0
pack .main.toolbox.math.eqentry -fill x -padx 5 -pady 10

label .main.toolbox.math.eqentry.label -text "LaTeX:" -bg #f0f0f0
entry .main.toolbox.math.eqentry.entry -width 12
button .main.toolbox.math.eqentry.insert -text "Add" -command "add_equation_from_entry"

pack .main.toolbox.math.eqentry.label -side left
pack .main.toolbox.math.eqentry.entry -side left -padx 5
pack .main.toolbox.math.eqentry.insert -side left

# Equation display canvas
frame .main.toolbox.math.preview -height 80 -bg white -relief sunken -bd 1
pack .main.toolbox.math.preview -fill x -padx 5 -pady 5

canvas .main.toolbox.math.preview.canvas -height 60 -bg white -highlightthickness 0
pack .main.toolbox.math.preview.canvas -fill both -expand 1
##############################################################################################
# Equation handling procedures
proc insert_math_symbol {symbol} {
    # Insert symbol into equation entry
    .main.toolbox.math.eqentry.entry insert insert $symbol
    # Move cursor appropriately for placeholders
    if {[string first "{}" $symbol] != -1} {
        .main.toolbox.math.eqentry.entry icursor [expr {[.main.toolbox.math.eqentry.entry index insert] - 1}]
    }
    focus .main.toolbox.math.eqentry.entry
}

proc add_equation_from_entry {} {
    set eq_text [.main.toolbox.math.eqentry.entry get]
    if {$eq_text ne ""} {
        # Call C++ to add equation to model
        set result [add_equation $eq_text 100 100]
        .status.text configure -text $result
        .main.toolbox.math.eqentry.entry delete 0 end
        update_equation_preview $eq_text
    }
}

proc update_equation_preview {latex} {
    # Simple ASCII preview for now
    .main.toolbox.math.preview.canvas delete all
    set preview "E: $latex"
    if {[string length $preview] > 30} {
        set preview [string range $preview 0 27]...
    }
    .main.toolbox.math.preview.canvas create text 5 30 \
        -text $preview -anchor w -font {Courier 10}
}
##############################################################################################
# In your main canvas area, add equation display capability
proc draw_equations_on_canvas {} {
    # Clear previous equation drawings
    .main.canvasframe.canvas delete "equation"
    
    # Get equations from C++
    set eq_list [list_equations]
    
    foreach eq_info $eq_list {
        # Parse equation info
        # For now, draw placeholder text
        set id [lindex [split $eq_info ":"] 0]
        set latex [string range $eq_info [expr [string first ":" $eq_info] + 2] end]
        
        # Simple text placeholder - in real version, you'd render LaTeX
        .main.canvasframe.canvas create text 100 100 \
            -text "{$latex}" \
            -tags "equation eq_$id" \
            -font {Arial 12} \
            -fill blue
    }
}

# Update your redraw_canvas procedure
proc redraw_canvas {} {
    .main.canvasframe.canvas delete all
    draw_equations_on_canvas
    # Draw other shapes here...
}

##############################################################################################
puts "GUI loaded successfully!"
##############################################################################################

# Add these procedures to your gui/main.tcl

# Main render procedure
proc render_video {} {
    puts "Starting video render..."
    
    # Update UI
    .renderframe.status configure -text "Rendering..." -fg "#FF9800"
    .renderframe.render configure -state disabled -text "⏳ Rendering..."
    update
    
    # Show progress bar
    pack .renderframe.progress
    update_progress 10 "Generating script..."
    
    try {
        # Call C++ to render the scene
        set result [render_scene]
        
        update_progress 100 "Render complete!"
        .renderframe.status configure -text $result -fg "#4CAF50"
        
        # Offer to open the video
        set response [tk_messageBox \
            -message "Video rendered successfully!\n\nOpen video folder?" \
            -type yesno \
            -icon info]
        
        if {$response eq "yes"} {
            open_video_folder
        }
        
    } on error {errMsg} {
        .renderframe.status configure -text "Render failed: $errMsg" -fg "#f44336"
        tk_messageBox \
            -message "Render failed:\n$errMsg" \
            -type ok \
            -icon error
    } finally {
        .renderframe.render configure -state normal -text "▶ Render Video"
        after 3000 {pack forget .renderframe.progress}
    }
}

# Progress bar update
proc update_progress {percent message} {
    # Update progress bar visualization
    set width 200
    set fill_width [expr {int($width * $percent / 100.0)}]
    
    .renderframe.progress.bar delete all
    .renderframe.progress.bar create rectangle 0 0 $fill_width 20 \
        -fill "#4CAF50" -outline ""
    .renderframe.progress.bar create rectangle 0 0 $width 20 \
        -outline "#cccccc"
    
    .renderframe.progress.text configure -text "$percent%"
    .renderframe.status configure -text $message
    update
}

# Open video folder
proc open_video_folder {} {
    set video_dir "media/videos/render_output/"
    
    if {[file exists $video_dir]} {
        # Try to open folder with xdg-open (Linux)
        if {[catch {exec xdg-open $video_dir} err]} {
            tk_messageBox \
                -message "Videos saved to:\n[file normalize $video_dir]" \
                -type ok \
                -icon info
        }
    } else {
        tk_messageBox \
            -message "Video folder not found:\n$video_dir" \
            -type ok \
            -warning
    }
}

# Quick render test
proc test_render {} {
    # Clear any existing equations
    catch {clear_scene}
    
    # Add some test equations
    add_equation "\\frac{1}{2}" 0 0
    add_equation "E = mc^2" 0 -1
    add_equation "\\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}" 0 -2
    
    # Render immediately
    render_video
}

# Clear scene
proc clear_scene {} {
    # Call C++ to clear equations (you need to implement this)
    catch {clear_all_equations}
    .main.canvasframe.canvas delete all
    .renderframe.status configure -text "Scene cleared" -fg "#2196F3"
}

##############################################################################################

# Add to your GUI or run in Tcl console
proc test_equation_feature {} {
    # Test adding different equations
    add_equation "\\frac{1}{2}" 100 100
    add_equation "\\int_0^\\infty e^{-x^2} dx" 100 150
    add_equation "\\sum_{n=1}^\\infty \\frac{1}{n^2}" 100 200
    
    # List them
    set eqs [list_equations]
    puts "Equations in scene: $eqs"
    
    # Render
    render_scene
    
    puts "Check render_output.py and media/videos/"
}


##############################################################################################


proc debug_layout {} {
    puts "=== Layout Debug ==="
    puts "Frame .main exists: [winfo exists .main]"
    puts "Frame .main.tools exists: [winfo exists .main.tools]"
    puts "Frame .main.tools.math exists: [winfo exists .main.tools.math]"
    puts "Children of .main: [winfo children .main]"
    puts "Children of .main.tools: [winfo children .main.tools]"
}

# Call after a short delay
after 1000 debug_layout

