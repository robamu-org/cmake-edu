target_sources(foolib PRIVATE lib.cpp)

target_include_directories(foolib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(foo)
