cmake_minimum_required(VERSION 3.22.0)
# We can version our project using CMake
project(foo VERSION 0.1.0)

# Sometimes, a C++ project might require a certain C++ standard to build.
# The following directives make sure that the compiler supports the required
# standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# This adds a library target called "foolib"
add_library(foolib)
# We assume our project also has a binary target called "fooapp"
add_executable(fooapp)

# The source files for both the library and the application are added in
add_subdirectory(src)

# This step makes the library foolib usable for fooapp.
# There are three linkage categories: PRIVATE, INTERFACE and PUBLIC.
# For applications, only PRIVATE linkage makes sense (although public is possible too)
# The three linkage categories are best shown with an example
# 
# PRIVATE linkage:
# Library A wants to use target B. It links B privately
#
# PUBLIC linkage:
# Library A wants to use target B but also exposes parts of B as part of its API.
# It needs to link B publicly. Another application C which links A now links A and B
#
# INTERFACE linkage:
# Library A wants to expose target B to a target but does not use B itself.
# It can use INTERFACE linkage to do so.
#
# These properties can be applied to source files (target_source command)
# and include directories as well (target_include_directories).
# For example, a library might be interested to use another internal include 
# structure than the one exposes to users. PRIVATE include directories can be
# used for the internal structure, while INTERFACE includes are used for the externally exposed
# include structure. If both are the same, PUBLIC can be used.
target_link_libraries(fooapp PRIVATE foolib)
