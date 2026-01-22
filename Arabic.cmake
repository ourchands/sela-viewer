# -*- cmake -*-
# Arabic.cmake - Configuration for Arabic text support libraries
# Part of Sela Viewer project

include(FindPkgConfig)

set(ARABIC_FIND_REQUIRED ON)

# Find system libraries (HarfBuzz and FriBidi)
pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
if (NOT HARFBUZZ_FOUND)
    message(FATAL_ERROR "HarfBuzz not found. Please install libharfbuzz-dev")
endif()

pkg_check_modules(FRIBIDI REQUIRED fribidi)
if (NOT FRIBIDI_FOUND)
    message(FATAL_ERROR "FriBidi not found. Please install libfribidi-dev")
endif()

message(STATUS "Using system HarfBuzz: ${HARFBUZZ_LIBRARIES}")
message(STATUS "Using system FriBidi: ${FRIBIDI_LIBRARIES}")

# Add include directories
include_directories(
    ${HARFBUZZ_INCLUDE_DIRS}
    ${FRIBIDI_INCLUDE_DIRS}
)

# Add library directories
if (DEFINED HARFBUZZ_LIBRARY_DIRS)
    link_directories(${HARFBUZZ_LIBRARY_DIRS})
endif()

if (DEFINED FRIBIDI_LIBRARY_DIRS)
    link_directories(${FRIBIDI_LIBRARY_DIRS})
endif()

# Create convenience variables for linking
set(ARABIC_LIBRARIES
    ${HARFBUZZ_LIBRARIES}
    ${FRIBIDI_LIBRARIES}
)

# Export for use in other CMakeLists
set(ARABIC_INCLUDE_DIRS
    ${HARFBUZZ_INCLUDE_DIRS}
    ${FRIBIDI_INCLUDE_DIRS}
    PARENT_SCOPE
)

set(ARABIC_LIBRARIES ${ARABIC_LIBRARIES} PARENT_SCOPE)

message(STATUS "Arabic support libraries configured successfully")
