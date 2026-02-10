

// src/SceneManager.hpp

#ifndef SCENEMANAGER_HPP
#define SCENEMANAGER_HPP

#include "Equation.hpp"
#include <vector>
#include <memory>

class SceneManager {
private:
    std::vector<std::unique_ptr<MathEquation>> equations;
    int next_id = 0;
    
public:
    // Add equation and return its ID
    int addEquation(const std::string& latex, double x, double y) {
        equations.emplace_back(std::make_unique<MathEquation>(latex, x, y, next_id));
        return next_id++;
    }
    
    // Get all equations as formatted string for Tcl
    std::string listEquations() const {
        std::string result;
        for (const auto& eq : equations) {
            result += "Eq#" + std::to_string(eq->id) + ": " + eq->latex + "\n";
        }
        return result;
    }
    
    // Clear all equations
    void clearAll() {
        equations.clear();
        next_id = 0;
    }
    
    // Get equations for Manim generation
    const std::vector<std::unique_ptr<MathEquation>>& getEquations() const {
        return equations;
    }
};

#endif
