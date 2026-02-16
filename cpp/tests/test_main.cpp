#include <gtest/gtest.h>
#include "project/logic.hpp"

TEST(LogicTest, ReturnsValidJson) {
    std::string result = project::get_greeting("Nix");
    nlohmann::json j = nlohmann::json::parse(result);
    
    EXPECT_EQ(j["status"], "success");
    EXPECT_EQ(j["message"], "Hello, Nix!");
}
