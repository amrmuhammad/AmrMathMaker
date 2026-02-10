// src/HandwritingRenderer.cpp
#include "HandwritingRenderer.hpp"
#include <cmath>
#include <sstream>
#include <iostream>

HandwritingRenderer::HandwritingRenderer() {
    initializeStrokes();
}

void HandwritingRenderer::setTclCallback(std::function<void(const std::string&)> callback) {
    tcl_callback = callback;
}

void HandwritingRenderer::renderHandwriting(const std::string& latex, double x, double y, int id) {
    std::cout << "[Renderer] Rendering handwriting for: " << latex << std::endl;
    
    // Clear canvas first
    if (tcl_callback) {
        std::string clear_cmd = "clear_canvas_for_animation " + std::to_string(id);
        tcl_callback(clear_cmd);
    }
    
    // Convert LaTeX to display text
    std::string display_text = latexToDisplay(latex);
    
    // Generate animation
    std::vector<StrokePoint> strokes = generateTypingAnimation(display_text, x, y);
    
    // Send strokes to Tcl for animation
    if (tcl_callback && !strokes.empty()) {
        std::stringstream cmd;
        cmd << "start_handwriting_animation " << id << " " << x << " " << y << " {"
            << display_text << "}";
        tcl_callback(cmd.str());
        
        // Send individual strokes
        for (size_t i = 0; i < strokes.size(); i++) {
            const auto& point = strokes[i];
            cmd.str("");
            cmd << "add_stroke_point " << id << " " << i << " "
                << point.x << " " << point.y << " " 
                << (point.pen_down ? "1" : "0");
            tcl_callback(cmd.str());
        }
        
        // Start animation
        cmd.str("");
        cmd << "execute_handwriting_animation " << id;
        tcl_callback(cmd.str());
    }
}

std::string HandwritingRenderer::latexToDisplay(const std::string& latex) {
    std::string result = latex;
    
    // Simple LaTeX to Unicode conversion
    std::map<std::string, std::string> replacements = {
        {"\\alpha", "α"}, {"\\beta", "β"}, {"\\gamma", "γ"}, {"\\delta", "δ"},
        {"\\theta", "θ"}, {"\\pi", "π"}, {"\\sum", "∑"}, {"\\int", "∫"},
        {"\\infty", "∞"}, {"\\pm", "±"}, {"\\times", "×"}, {"\\div", "÷"},
        {"\\leq", "≤"}, {"\\geq", "≥"}, {"\\neq", "≠"}, {"\\approx", "≈"},
        {"\\sqrt", "√"}, {"\\frac{1}{2}", "½"}, {"\\frac{1}{4}", "¼"},
        {"^2", "²"}, {"^3", "³"}, {"_0", "₀"}, {"_1", "₁"},
        {"\\to", "→"}, {"\\forall", "∀"}, {"\\exists", "∃"}
    };
    
    for (const auto& [from, to] : replacements) {
        size_t pos = 0;
        while ((pos = result.find(from, pos)) != std::string::npos) {
            result.replace(pos, from.length(), to);
            pos += to.length();
        }
    }
    
    // Remove curly braces
    std::string clean;
    for (char c : result) {
        if (c != '{' && c != '}') {
            clean += c;
        }
    }
    
    return clean;
}

void HandwritingRenderer::initializeStrokes() {
    // Initialize with some basic symbols
    // Each symbol is defined as a series of points
    
    // Letter 'E'
    symbol_strokes['E'] = {
        {0, 0, true}, {0, 20, true},           // Vertical line
        {0, 0, false}, {0, 0, true}, {10, 0, true},  // Top horizontal
        {0, 10, false}, {0, 10, true}, {8, 10, true}, // Middle horizontal
        {0, 20, false}, {0, 20, true}, {10, 20, true} // Bottom horizontal
    };
    
    // Letter 'q' (for equals)
    symbol_strokes['='] = {
        {0, 7, false}, {0, 7, true}, {15, 7, true},   // Top line
        {0, 13, false}, {0, 13, true}, {15, 13, true} // Bottom line
    };
    
    // Plus sign
    symbol_strokes['+'] = {
        {5, 0, false}, {5, 0, true}, {5, 10, true},   // Vertical
        {0, 5, false}, {0, 5, true}, {10, 5, true}    // Horizontal
    };
    
    // Greek alpha
    symbol_strokes['α'] = {
        {5, 0, false}, {5, 0, true}, {2, 10, true},   // Left curve
        {2, 10, false}, {2, 10, true}, {8, 10, true}, // Bottom
        {8, 10, false}, {8, 10, true}, {5, 0, true},  // Right curve
        {3, 6, false}, {3, 6, true}, {7, 6, true}     // Cross bar
    };
    
    // Pi symbol
    symbol_strokes['π'] = {
        {2, 0, false}, {2, 0, true}, {2, 10, true},   // Left vertical
        {2, 0, false}, {2, 0, true}, {8, 0, true},    // Top bar
        {8, 0, false}, {8, 0, true}, {8, 10, true}    // Right vertical
    };
}

std::vector<StrokePoint> HandwritingRenderer::generateTypingAnimation(
    const std::string& text, double x, double y) {
    
    std::vector<StrokePoint> strokes;
    double current_x = x;
    double char_width = 12.0;
    
    for (char c : text) {
        // If we have stroke data for this character, use it
        if (symbol_strokes.find(c) != symbol_strokes.end()) {
            const auto& char_strokes = symbol_strokes[c];
            
            // Add pen up movement to character start
            strokes.push_back({current_x + 5, y, false});
            
            // Add character strokes
            for (const auto& point : char_strokes) {
                strokes.push_back({
                    current_x + point.x,
                    y + point.y,
                    point.pen_down
                });
            }
            
            // Add small pause after character
            strokes.push_back({current_x + 5, y, false});
            
        } else {
            // For unknown characters, create a simple typing stroke
            strokes.push_back({current_x, y - 2, false});
            strokes.push_back({current_x, y - 2, true});
            strokes.push_back({current_x, y + 10, true});
        }
        
        current_x += char_width;
    }
    
    return strokes;
}
