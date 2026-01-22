# -*- cmake -*-
# Arabic.cmake - Configuration for Arabic text support libraries
# Part of Sela Viewer project

include(Prebuilt)

set(ARABIC_FIND_REQUIRED ON)

# Try to find system libraries first (for Linux)
if (STANDALONE)
    include(FindPkgConfig)
    
    # Find HarfBuzz
    pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
    if (NOT HARFBUZZ_FOUND)
        message(FATAL_ERROR "HarfBuzz not found. Please install libharfbuzz-dev")
    endif()
    
    # Find FriBidi
    pkg_check_modules(FRIBIDI REQUIRED fribidi)
    if (NOT FRIBIDI_FOUND)
        message(FATAL_ERROR "FriBidi not found. Please install libfribidi-dev")
    endif()
    
    message(STATUS "Using system HarfBuzz: ${HARFBUZZ_LIBRARIES}")
    message(STATUS "Using system FriBidi: ${FRIBIDI_LIBRARIES}")
    
else (STANDALONE)
    # Use prebuilt binaries
    use_prebuilt_binary(harfbuzz)
    use_prebuilt_binary(fribidi)
    
    # Set include directories
    set(HARFBUZZ_INCLUDE_DIRS ${LIBS_PREBUILT_DIR}/include/harfbuzz)
    set(FRIBIDI_INCLUDE_DIRS ${LIBS_PREBUILT_DIR}/include/fribidi)
    
    # Set library names based on platform
    if (LINUX)
        set(HARFBUZZ_LIBRARIES harfbuzz)
        set(FRIBIDI_LIBRARIES fribidi)
        set(HARFBUZZ_LIBRARY_DIRS ${LIBS_PREBUILT_DIR}/lib/release)
        set(FRIBIDI_LIBRARY_DIRS ${LIBS_PREBUILT_DIR}/lib/release)
    elseif (DARWIN)
        set(HARFBUZZ_LIBRARIES harfbuzz)
        set(FRIBIDI_LIBRARIES fribidi)
        set(HARFBUZZ_LIBRARY_DIRS ${LIBS_PREBUILT_DIR}/lib/release)
        set(FRIBIDI_LIBRARY_DIRS ${LIBS_PREBUILT_DIR}/lib/release)
    elseif (WINDOWS)
        set(HARFBUZZ_LIBRARIES 
            optimized harfbuzz
            debug harfbuzz_d)
        set(FRIBIDI_LIBRARIES 
            optimized fribidi
            debug fribidi_d)
        set(HARFBUZZ_LIBRARY_DIRS 
            ${LIBS_PREBUILT_DIR}/lib/release
            ${LIBS_PREBUILT_DIR}/lib/debug)
        set(FRIBIDI_LIBRARY_DIRS 
            ${LIBS_PREBUILT_DIR}/lib/release
            ${LIBS_PREBUILT_DIR}/lib/debug)
    endif ()
    
    message(STATUS "Using prebuilt HarfBuzz from: ${HARFBUZZ_INCLUDE_DIRS}")
    message(STATUS "Using prebuilt FriBidi from: ${FRIBIDI_INCLUDE_DIRS}")
endif (STANDALONE)

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
