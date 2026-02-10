// src/Equation.hpp
#ifndef EQUATION_HPP
#define EQUATION_HPP

#include <string>

class MathEquation {
public:
    int id;
    std::string latex;
    double x, y;
    double scale;
    std::string color;
    
    MathEquation(const std::string& latex, double x, double y, int id) 
        : id(id), latex(latex), x(x), y(y), scale(1.0), color("blue") {}
    
    std::string toManimCode() const {
        // Convert to Manim's MathTex code
        std::string code;
        code += "        equation = MathTex(r\"" + latex + "\")\n";
        code += "        equation.move_to([" + std::to_string(x) + ", " + std::to_string(y) + ", 0])\n";
        code += "        equation.set_color(\"" + color + "\")\n";
        code += "        equation.scale(" + std::to_string(scale) + ")\n";
        code += "        self.play(Write(equation))\n";
        return code;
    }
};

#endif
