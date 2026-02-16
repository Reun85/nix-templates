#pragma once
#include <string>
#include <nlohmann/json.hpp>

namespace project {
    // Returns a JSON-formatted greeting
    std::string get_greeting(const std::string& name);
}
