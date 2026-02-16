cmake_minimum_required(VERSION 3.20)
project(MyCppProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

# 1. Find Dependencies
find_package(fmt CONFIG REQUIRED)
find_package(GTest CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

# 2. GLOB source files
file(GLOB_RECURSE LIB_SOURCES
    CONFIGURE_DEPENDS
    "src/*.cpp"
    "vendor/*.cpp"
)

# Filter out the entry_point from being added twice.
list(REMOVE_ITEM LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/entry_point.cpp")

# 3. Define your Library
add_library(project_lib ${LIB_SOURCES})
target_include_directories(project_lib PUBLIC include)
target_include_directories(project_lib PUBLIC vendor)

# 4. Link dependencies
target_link_libraries(project_lib
    PUBLIC
        fmt::fmt
        nlohmann_json::nlohmann_json
)

# 5. Executable
add_executable(my_app src/entry_point.cpp)
target_link_libraries(my_app PRIVATE project_lib)


# 6. Tests
file(GLOB_RECURSE TEST_SOURCES CONFIGURE_DEPENDS "tests/*.cpp")

enable_testing()
add_executable(unit_tests ${TEST_SOURCES})
target_link_libraries(unit_tests PRIVATE project_lib GTest::gtest_main)
add_test(NAME AllTests COMMAND unit_tests)
