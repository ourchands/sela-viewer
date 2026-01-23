# Arabic.cmake - Arabic language support for Firestorm Viewer

# On Windows, we'll skip the HarfBuzz dependency check since it's not available via pkg-config
# The Arabic support files will be compiled without external HarfBuzz dependency

if(WINDOWS)
    # Windows doesn't use pkg-config, so we skip the HarfBuzz check
    message(STATUS "Building with Arabic support for Windows (without external HarfBuzz)")
    
    # Add the Arabic support source files
    set(ARABIC_SUPPORT_SOURCES
        llarabicsupport.cpp
    )
    
    set(ARABIC_SUPPORT_HEADERS
        llarabicsupport.h
    )
    
    # These will be added to the llui library
    list(APPEND llui_SOURCE_FILES ${ARABIC_SUPPORT_SOURCES})
    list(APPEND llui_HEADER_FILES ${ARABIC_SUPPORT_HEADERS})
    
else()
    # On Linux/Mac, use pkg-config to find HarfBuzz
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
    
    if(NOT HARFBUZZ_FOUND)
        message(FATAL_ERROR "HarfBuzz not found. Please install libharfbuzz-dev")
    endif()
    
    # Add the Arabic support source files
    set(ARABIC_SUPPORT_SOURCES
        llarabicsupport.cpp
    )
    
    set(ARABIC_SUPPORT_HEADERS
        llarabicsupport.h
    )
    
    # Add to llui library
    list(APPEND llui_SOURCE_FILES ${ARABIC_SUPPORT_SOURCES})
    list(APPEND llui_HEADER_FILES ${ARABIC_SUPPORT_HEADERS})
    
    # Add HarfBuzz include directories and libraries
    include_directories(${HARFBUZZ_INCLUDE_DIRS})
    link_directories(${HARFBUZZ_LIBRARY_DIRS})
    
endif()

message(STATUS "Arabic language support enabled")
