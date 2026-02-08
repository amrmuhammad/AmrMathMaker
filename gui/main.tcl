# gui/main.tcl - Main GUI for Manim Tool
puts "Loading Manim GUI Tool..."

# Set window title and size
wm title . "Manim Video Tool v1.0"
wm geometry . 1024x768

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

# Main interface with three panels
frame .main
pack .main -fill both -expand 1 -padx 5 -pady 5

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

# Center panel: Canvas
frame .main.canvasframe
pack .main.canvasframe -side left -fill both -expand 1 -padx 5

label .main.canvasframe.label -text "ANIMATION CANVAS" -font {Arial 11 bold}
pack .main.canvasframe.label -pady 5

canvas .main.canvasframe.canvas -width 700 -height 500 -bg white -relief sunken -bd 2
pack .main.canvasframe.canvas -fill both -expand 1

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

# Bottom panel: Timeline
frame .timeline -height 100 -bg #202020
pack .timeline -fill x -side bottom -pady 5

label .timeline.label -text "TIMELINE" -fg white -bg #202020 -font {Arial 10 bold}
pack .timeline.label -side top -anchor w -padx 10 -pady 5

canvas .timeline.canvas -height 60 -bg #404040 -highlightthickness 0
pack .timeline.canvas -fill x -padx 10 -pady 5

# Bottom status bar
frame .status -height 24 -bg #2c3e50
pack .status -fill x -side bottom

label .status.text -text "Ready to create math animations..." -fg white -bg #2c3e50 -font {Arial 9}
pack .status.text -side left -padx 10

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

puts "GUI loaded successfully!"
