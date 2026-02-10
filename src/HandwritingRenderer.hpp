// src/HandwritingRenderer.hpp
#ifndef HANDWRITINGRENDERER_HPP
#define HANDWRITINGRENDERER_HPP

#include <string>
#include <vector>
#include <map>
#include <functional>

struct StrokePoint {
    double x, y;
    bool pen_down;  // true = drawing, false = moving to new position
};

class HandwritingRenderer {
private:
    // Stroke data for symbols
    std::map<char, std::vector<StrokePoint>> symbol_strokes;
    
    // Callback to send drawing commands to Tcl
    std::function<void(const std::string&)> tcl_callback;
    
public:
    HandwritingRenderer();
    
    // Set Tcl callback
    void setTclCallback(std::function<void(const std::string&)> callback);
    
    // Render LaTeX with handwriting animation
    void renderHandwriting(const std::string& latex, double x, double y, int id);
    
    // Convert LaTeX to display text
    static std::string latexToDisplay(const std::string& latex);
    
private:
    // Initialize stroke database
    void initializeStrokes();
    
    // Generate strokes for a character
    std::vector<StrokePoint> getStrokesForChar(char c, double x, double y);
    
    // Generate typing animation for text
    std::vector<StrokePoint> generateTypingAnimation(const std::string& text, double x, double y);
};

#endif
