# gui/main.tcl - Main GUI for AmrMathMaker Tool
puts "Loading AmrMathMaker GUI Tool..."

# Set window title and size
wm title . "AmrMathMaker Video Tool v1.0"
wm geometry . 1200x800

#############################################################################################
proc create_menu_bar {} {
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
    .menubar.render add command -label "Render Animation" -command render_video

    # Help menu
    menu .menubar.help -tearoff 0
    .menubar add cascade -label "Help" -menu .menubar.help
    .menubar.help add command -label "About" -command {show_about}
}
############################################################################################
proc create_bottom_section {} {
    #############################################################################
    # BOTTOM SECTION: Pack these FIRST (bottom-up packing)
    #############################################################################

    # 1. Status bar (lowest)
    frame .status -height 28 -bg #2c3e50
    pack .status -fill x -side bottom

    label .status.text -text "Ready to create math animations..." -fg white -bg #2c3e50 -font {Arial 9}
    pack .status.text -side left -padx 10

    # 2. Timeline (above status bar)
    frame .timeline -height 120 -bg #202020
    pack .timeline -fill x -side bottom -pady 2

    label .timeline.label -text "TIMELINE" -fg white -bg #202020 -font {Arial 10 bold}
    pack .timeline.label -side top -anchor w -padx 10 -pady 5

    canvas .timeline.canvas -height 80 -bg #404040 -highlightthickness 0
    pack .timeline.canvas -fill x -padx 10 -pady 5

    # 3. Render frame (above timeline)
    frame .renderframe -bg #f8f8f8 -relief ridge -bd 2
    pack .renderframe -fill x -side bottom -padx 10 -pady 5

    label .renderframe.label -text "Render Controls" -bg #e8e8e8 -font {Arial 11 bold}
    pack .renderframe.label -fill x -pady 5

    button .renderframe.render -text "▶ Render Video" \
        -bg "#4CAF50" -fg white -font {Arial 12 bold} \
        -activebackground "#45a049" \
        -command render_video
    pack .renderframe.render -pady 10 -padx 20

    label .renderframe.status -text "Ready to render" -bg #f8f8f8
    pack .renderframe.status -pady 5

    frame .renderframe.progress -bg #f8f8f8
    canvas .renderframe.progress.bar -width 200 -height 20 -bg white -relief sunken -bd 1
    label .renderframe.progress.text -text "0%" -bg #f8f8f8 -width 5
    pack .renderframe.progress.bar -side left
    pack .renderframe.progress.text -side left -padx 10
    pack .renderframe.progress -fill x -padx 20 -pady 5
    pack forget .renderframe.progress  # Hide initially

}
##################################################################################################################################
proc create_toolbox_panel {} {
    # Toolbox panel
    frame .main.content.leftpanels.toolbox -width 180 -bg #f0f0f0 -relief raised -bd 1
    pack .main.content.leftpanels.toolbox -side left -fill y -padx 2

    label .main.content.leftpanels.toolbox.title -text "TOOLS" -bg #e0e0e0 -font {Arial 10 bold}
    pack .main.content.leftpanels.toolbox.title -fill x -pady 5

    foreach btn {select circle rect text arrow} {
        button .main.content.leftpanels.toolbox.$btn -text [string totitle $btn] -command "set_tool $btn"
        pack .main.content.leftpanels.toolbox.$btn -fill x -padx 5 -pady 2
    }
}
##################################################################################################################################
proc create_math_symbols_panel {} {
    # Math symbols panel
    frame .main.content.leftpanels.math -width 180 -bg #e8f4f8 -relief raised -bd 1
    pack .main.content.leftpanels.math -side left -fill y -padx 2

    label .main.content.leftpanels.math.title -text "Math Symbols" -bg #d0e8f0 -font {Arial 10 bold}
    pack .main.content.leftpanels.math.title -fill x -pady 5

    # Math symbols grid
    set symbols {
        alpha "α"  beta "β"    gamma "γ"    delta "δ"
        theta "θ"  pi "π"      sum "∑"      int "∫"
        sqrt "√"   infty "∞"   pm "±"       times "×"
        div "÷"    leq "≤"     geq "≥"      neq "≠"
        approx "≈" frac "a/b"  rightarrow "→" forall "∀"
        exists "∃" nabla "∇"   partial "∂"  hbar "ħ"
    }

    frame .main.content.leftpanels.math.grid
    pack .main.content.leftpanels.math.grid -fill both -expand 1 -padx 5

    set row 0
    set col 0
    foreach {name symbol} $symbols {
        button .main.content.leftpanels.math.grid.$name -text $symbol \
            -width 3 -font {Arial 12} \
            -command "insert_math_symbol \"$symbol\""
        
        grid .main.content.leftpanels.math.grid.$name -row $row -column $col -padx 2 -pady 2
        
        set col [expr {$col + 1}]
        if {$col >= 3} {
            set col 0
            incr row
        }
    }

    # Equation entry
    frame .main.content.leftpanels.math.eqentry -bg #e8f4f8
    pack .main.content.leftpanels.math.eqentry -fill x -padx 5 -pady 10

    label .main.content.leftpanels.math.eqentry.label -text "LaTeX:" -bg #e8f4f8
    entry .main.content.leftpanels.math.eqentry.entry -width 15
    button .main.content.leftpanels.math.eqentry.insert -text "Add" -command add_equation_from_entry

    pack .main.content.leftpanels.math.eqentry.label -side left
    pack .main.content.leftpanels.math.eqentry.entry -side left -padx 5
    pack .main.content.leftpanels.math.eqentry.insert -side left

    # Equation preview
    frame .main.content.leftpanels.math.preview -height 60 -bg white -relief sunken -bd 1
    pack .main.content.leftpanels.math.preview -fill x -padx 5 -pady 5

    canvas .main.content.leftpanels.math.preview.canvas -height 40 -bg white -highlightthickness 0
    pack .main.content.leftpanels.math.preview.canvas -fill both -expand 1

}
##################################################################################################################################
proc create_canvas_area {} {

    # Canvas area (takes remaining space)
    frame .main.content.canvasarea
    pack .main.content.canvasarea -side left -fill both -expand 1 -padx 5

    label .main.content.canvasarea.label -text "ANIMATION CANVAS" -font {Arial 12 bold}
    pack .main.content.canvasarea.label -pady 5

    canvas .main.content.canvasarea.canvas -bg white -relief sunken -bd 2
    pack .main.content.canvasarea.canvas -fill both -expand 1
    
    
    # Add canvas click handler to select equations
    #bind .main.content.canvasarea.canvas <Button-1> {
    #    set item [%W find withtag current]
    #    if {$item ne ""} {
    #        set tags [%W gettags $item]
    #        foreach tag $tags {
    #            if {[string match "eq_*" $tag]} {
    #                set eq_id [string range $tag 3 end]
    #                .status.text configure -text "Selected equation #$eq_id"
    #                break
    #            }
    #        }
    #    }
    #}
}
##################################################################################################################################
proc create_properties_panel {} {
    # Properties panel (right side)
    frame .main.content.props -width 250 -bg #f8f8f8 -relief raised -bd 1
    pack .main.content.props -side right -fill y -padx 2

    label .main.content.props.title -text "PROPERTIES" -bg #e8e8e8 -font {Arial 10 bold}
    pack .main.content.props.title -fill x -pady 5

    frame .main.content.props.color -bg #f8f8f8
    label .main.content.props.color.label -text "Color:" -bg #f8f8f8
    entry .main.content.props.color.entry -width 15
    .main.content.props.color.entry insert 0 "#3498db"
    pack .main.content.props.color.label .main.content.props.color.entry -side left -padx 5
    pack .main.content.props.color -anchor w -padx 10 -pady 5
}
##################################################################################################################################
proc create_main_window {} {

    puts "DEBUG: create_main_window started..."
    ############################################################################################
    # MAIN WINDOW STRUCTURE 
    ############################################################################################

    # Main container
    frame .main
    pack .main -fill both -expand 1

    create_bottom_section
    
    #############################################################################
    # MIDDLE SECTION: Main content area (fills remaining space)
    #############################################################################

    # Container for left panels and canvas
    frame .main.content
    pack .main.content -fill both -expand 1 -pady 5

    # Left panels container
    frame .main.content.leftpanels
    pack .main.content.leftpanels -side left -fill y

    create_toolbox_panel    
    #create_math_symbols_panel    
    create_canvas_area
    create_properties_panel

    puts "DEBUG: create_main_window completed..."
}
#################################################################################################################
proc test_cpp_integration {} {
    
    # Test C++ integration buttons
    frame .main.content.leftpanels.toolbox.testframe -bg #f0f0f0
    pack .main.content.leftpanels.toolbox.testframe -fill x -padx 5 -pady 10

    button .main.content.leftpanels.toolbox.testframe.testcpp -text "Test C++" \
        -command {
            set result [say_hello]
            .status.text configure -text $result
        }
    button .main.content.leftpanels.toolbox.testframe.testadd -text "Test Math" \
        -command {
            set sum [add_numbers 42 58]
            .status.text configure -text "42 + 58 = $sum"
        }

    pack .main.content.leftpanels.toolbox.testframe.testcpp \
         .main.content.leftpanels.toolbox.testframe.testadd \
         -fill x -pady 2

}
#################################################################################################################

##############################################################################################
# PROCEDURES
##############################################################################################

# Equation handling procedures
proc insert_math_symbol {symbol} {
    .main.content.leftpanels.math.eqentry.entry insert insert $symbol
    focus .main.content.leftpanels.math.eqentry.entry
}


proc add_equation_from_entry {} {
    set eq_text [.main.content.leftpanels.math.eqentry.entry get]
    if {$eq_text ne ""} {
        # Get random position on canvas for demo
        set x [expr {rand() * 400 - 200}]
        set y [expr {rand() * 300 - 150}]
        
        set result [add_equation $eq_text $x $y]
        .status.text configure -text $result
        
        # Update preview and canvas
        update_equation_preview $eq_text
        draw_equations_on_canvas
        
        .main.content.leftpanels.math.eqentry.entry delete 0 end
    }
}

proc update_equation_preview {latex} {
    .main.content.leftpanels.math.preview.canvas delete all
    set preview "LaTeX: $latex"
    if {[string length $preview] > 25} {
        set preview [string range $preview 0 22]...
    }
    .main.content.leftpanels.math.preview.canvas create text 5 20 \
        -text $preview -anchor w -font {Courier 9}
}

# Canvas procedures
proc draw_equations_on_canvas {} {
    .main.content.canvasarea.canvas delete "equation"
    
    set eq_list [list_equations]
    set y_pos 150
    
    foreach line [split $eq_list "\n"] {
        if {$line eq ""} continue
        
        # Parse: "Eq#0: \frac{1}{2}"
        if {[regexp {Eq#(\d+): (.+)} $line -> id latex]} {
            set x [expr {100 + $id * 30}]
            set y [expr {150 - $id * 40}]
            
            .main.content.canvasarea.canvas create text $x $y \
                -text "$latex" \
                -tags "equation eq_$id" \
                -font {Arial 14} \
                -fill "#2c3e50" \
                -anchor w
                
            # Add ID label
            .main.content.canvasarea.canvas create text [expr {$x - 20}] $y \
                -text "#$id" \
                -tags "equation_id" \
                -font {Arial 10} \
                -fill "#7f8c8d" \
                -anchor w
        }
    }
}



proc redraw_canvas {} {
    .main.content.canvasarea.canvas delete all
    draw_equations_on_canvas
}

# Render procedures
proc render_video {} {
    puts "Starting video render..."
    
    .renderframe.status configure -text "Rendering..." -fg "#FF9800"
    .renderframe.render configure -state disabled -text "⏳ Rendering..."
    update
    
    pack .renderframe.progress
    update_progress 10 "Generating script..."
    
    try {
        set result [render_scene]
        
        update_progress 100 "Render complete!"
        .renderframe.status configure -text $result -fg "#4CAF50"
        
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

proc update_progress {percent message} {
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

proc open_video_folder {} {
    set video_dir "media/videos/render_output/"
    
    if {[file exists $video_dir]} {
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

proc test_render {} {
    catch {clear_scene}
    
    add_equation "\\frac{1}{2}" 0 0
    add_equation "E = mc^2" 0 -1
    add_equation "\\int_0^\\infty e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}" 0 -2
    
    render_video
}

proc clear_scene {} {
    catch {clear_all_equations}
    .main.content.canvasarea.canvas delete all
    .renderframe.status configure -text "Scene cleared" -fg "#2196F3"
}

proc test_equation_feature {} {
    add_equation "\\frac{1}{2}" 100 100
    add_equation "\\int_0^\\infty e^{-x^2} dx" 100 150
    add_equation "\\sum_{n=1}^\\infty \\frac{1}{n^2}" 100 200
    
    set eqs [list_equations]
    puts "Equations in scene: $eqs"
    
    render_scene
    
    puts "Check render_output.py and media/videos/"
}

# Dummy procedures for menu commands (implement these in C++ later)
proc new_project {} { tk_messageBox -message "New Project" -type ok }
proc open_project {} { tk_messageBox -message "Open Project" -type ok }
proc save_project {} { tk_messageBox -message "Save Project" -type ok }
proc undo_action {} { tk_messageBox -message "Undo" -type ok }
proc redo_action {} { tk_messageBox -message "Redo" -type ok }
proc show_about {} { tk_messageBox -message "AmrMathMaker v1.0\nMath Video Tool" -type ok }
proc set_tool {tool} { .status.text configure -text "Selected tool: $tool" }


##########################################################################################################################

puts "Before Window creation ..."

create_menu_bar
create_main_window
test_cpp_integration

puts "After Window creation ..."

##########################################################################################################################


##############################################################################################
# STARTUP
##############################################################################################

# Initial test
after 1000 {
    .status.text configure -text "GUI loaded successfully!"
    update_equation_preview "E = mc^2"
}

puts "GUI loaded successfully!"
