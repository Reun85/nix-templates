#include "project/logic.hpp"
#include <iostream>
#include <fmt/color.h>

int main() {
    auto result = project::get_greeting("World!");
    
    // Printing with some color
    fmt::print(fg(fmt::color::green) | fmt::emphasis::bold, 
               "Output: {}\n", result);
    
    return 0;
}
