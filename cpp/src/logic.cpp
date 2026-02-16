#include "project/logic.hpp"
#include <fmt/core.h>

namespace project {
    std::string get_greeting(const std::string& name) {
        nlohmann::json j;
        j["message"] = fmt::format("Hello, {}!", name);
        j["status"] = "success";
        return j.dump();
    }
}
