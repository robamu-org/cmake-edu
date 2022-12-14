# Based on https://github.com/Pro/raspi-toolchain but rewritten completely.

if(NOT DEFINED ENV{RASPBERRY_VERSION})
	message(STATUS "Raspberry Pi version not specified, setting version 4!")
	set(RASPBERRY_VERSION 4)
else()
	set(RASPBERRY_VERSION $ENV{RASPBERRY_VERSION})
endif()


# LINUX_ROOTFS should point to the local directory which contains all the 
# libraries and includes from the target raspi.
# The following command can be used to do this, replace <ip-address> and the
# local <rootfs-path> accordingly:
# rsync -vR --progress -rl --delete-after --safe-links pi@<ip-address>:/{lib,usr,opt/vc/lib} <rootfs-path>
# LINUX_ROOTFS needs to be passed to the CMake command or defined in the
# application CMakeLists.txt before loading the toolchain file.

# CROSS_COMPILE also needs to be set accordingly or passed to the CMake command
if(NOT DEFINED ENV{LINUX_ROOTFS})
    # Sysroot has not been cached yet and was not set in environment either
    if(NOT SYSROOT_PATH)
    	message(FATAL_ERROR
    		"Define the LINUX_ROOTFS variable to point to the Raspberry Pi rootfs."
        )
    endif()
else()
    set(SYSROOT_PATH "$ENV{LINUX_ROOTFS}" CACHE PATH "Local linux root filesystem path")
    message(STATUS "Raspberry Pi sysroot: ${SYSROOT_PATH}")
endif()

if(NOT DEFINED ENV{CROSS_COMPILE})
	set(CROSS_COMPILE "arm-linux-gnueabihf")
	message(STATUS 
		"No CROSS_COMPILE environmental variable set, using default ARM linux "
		"cross compiler name ${CROSS_COMPILE}"
	)
else()
	set(CROSS_COMPILE "$ENV{CROSS_COMPILE}")
	message(STATUS 
		"Using environmental variable CROSS_COMPILE as cross-compiler: "
		"$ENV{CROSS_COMPILE}"
	)
endif()

# Generally, the debian roots will be a multiarch rootfs where some libraries are put
# into a folder named "arm-linux-gnueabihf". The user can override the folder name if this is
# not the case
if(NOT ENV{MULTIARCH_FOLDER_NAME})
    set(MULTIARCH_FOLDER_NAME "arm-linux-gnueabihf")
else()
    set(MUTLIARCH_FOLDER_NAME $ENV{MULTIARCH_FOLDER_NAME})
endif()

message(STATUS "Using sysroot path: ${SYSROOT_PATH}")

set(CROSS_COMPILE_CC "${CROSS_COMPILE}-gcc")
set(CROSS_COMPILE_CXX "${CROSS_COMPILE}-g++")
set(CROSS_COMPILE_LD "${CROSS_COMPILE}-ld")
set(CROSS_COMPILE_AR "${CROSS_COMPILE}-ar")
set(CROSS_COMPILE_RANLIB "${CROSS_COMPILE}-ranlib")
set(CROSS_COMPILE_STRIP "${CROSS_COMPILE}-strip")
set(CROSS_COMPILE_NM "${CROSS_COMPILE}-nm")
set(CROSS_COMPILE_OBJCOPY "${CROSS_COMPILE}-objcopy")
set(CROSS_COMPILE_SIZE "${CROSS_COMPILE}-size")

# At the very least, cross compile gcc and g++ have to be set!
find_program (CMAKE_C_COMPILER ${CROSS_COMPILE_CC} REQUIRED)
find_program (CMAKE_CXX_COMPILER ${CROSS_COMPILE_CXX} REQUIRED)
# Useful utilities, not strictly necessary
find_program(CMAKE_SIZE ${CROSS_COMPILE_SIZE})
find_program(CMAKE_OBJCOPY ${CROSS_COMPILE_OBJCOPY})

set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSROOT "${SYSROOT_PATH}")

# Define name of the target system
set(CMAKE_SYSTEM_NAME "Linux")
if(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_SYSTEM_PROCESSOR "armv7")
else()
	set(CMAKE_SYSTEM_PROCESSOR "arm")
endif()

set(COMMON_FLAGS "")

if(RASPBERRY_VERSION VERSION_GREATER 3)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a72 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 4"
	)
	set(CMAKE_CXX_FLAGS 
		"${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 4"
	)
elseif(RASPBERRY_VERSION VERSION_GREATER 2)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a53 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 3"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 3"
	)
elseif(RASPBERRY_VERSION VERSION_GREATER 1)
	set(CMAKE_C_FLAGS 
		"-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 2"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 2"
	)
else()
	set(CMAKE_C_FLAGS 
		"-mcpu=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard ${COMMON_FLAGS}" 
		CACHE STRING "Flags for Raspberry Pi 1 B+ Zero"
	)
	set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" 
		CACHE STRING "Flags for Raspberry PI 1 B+ Zero"
	)
endif()

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
