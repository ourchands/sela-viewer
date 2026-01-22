/**
 * @file llarabicsupport.h
 * @brief Arabic text support for Second Life viewers
 * @author Sela Viewer Team
 *
 * $LicenseInfo:firstyear=2025&license=lgpl$
 * Second Life Viewer Source Code
 * Copyright (C) 2025, Sela Viewer Team
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation;
 * version 2.1 of the License only.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * $/LicenseInfo$
 */

#ifndef LL_LLARABICSUPPORT_H
#define LL_LLARABICSUPPORT_H

#include <string>
#include <vector>
#include <map>
#include <memory>

// Forward declarations for external libraries
typedef struct hb_buffer_t hb_buffer_t;
typedef struct hb_font_t hb_font_t;
typedef struct FT_FaceRec_* FT_Face;

/**
 * @class LLArabicSupport
 * @brief Singleton class providing Arabic text processing
 *
 * This class handles:
 * - Arabic character detection
 * - Bidirectional text reordering (RTL/LTR)
 * - Arabic text shaping (connecting letters)
 * - Mixed Arabic/English text processing
 */
class LLArabicSupport
{
public:
    /**
     * Get singleton instance
     */
    static LLArabicSupport& instance();
    
    /**
     * Initialize with a font face (must be called before shaping)
     * @param font_face FreeType font face
     * @return true if successful
     */
    bool initialize(FT_Face font_face);
    
    /**
     * Check if initialized
     */
    bool isInitialized() const { return mInitialized; }
    
    /**
     * Process Arabic text completely (reorder + shape)
     * @param input Input text (may contain mixed Arabic/English)
     * @return Processed text ready for display
     */
    std::wstring processArabicText(const std::wstring& input);
    
    /**
     * Shape Arabic text (connect letters)
     * @param input Input text with isolated Arabic letters
     * @return Shaped text with connected letters
     */
    std::wstring shapeArabicText(const std::wstring& input);
    
    /**
     * Reorder bidirectional text (handle RTL/LTR)
     * @param input Input text
     * @return Reordered text
     */
    std::wstring reorderBidiText(const std::wstring& input);
    
    /**
     * Check if text contains Arabic characters
     * @param text Text to check
     * @return true if contains Arabic
     */
    bool containsArabic(const std::wstring& text) const;
    
    /**
     * Check if a character is Arabic
     * @param ch Character to check
     * @return true if Arabic
     */
    bool isArabicChar(wchar_t ch) const;
    
    /**
     * Check if a character is a digit
     * @param ch Character to check
     * @return true if digit (0-9 or Arabic-Indic)
     */
    bool isDigit(wchar_t ch) const;
    
    /**
     * Enable/disable caching
     * @param enable true to enable caching
     */
    void setEnableCache(bool enable) { mEnableCache = enable; }
    
    /**
     * Clear text cache
     */
    void clearCache();
    
    /**
     * Get cache statistics
     */
    void getCacheStats(size_t& cache_size, size_t& hit_count, size_t& miss_count) const;
    
    /**
     * Set maximum cache size
     * @param max_size Maximum number of cached entries (0 = unlimited)
     */
    void setMaxCacheSize(size_t max_size) { mMaxCacheSize = max_size; }

private:
    LLArabicSupport();
    ~LLArabicSupport();
    
    // Prevent copying
    LLArabicSupport(const LLArabicSupport&) = delete;
    LLArabicSupport& operator=(const LLArabicSupport&) = delete;
    
    // HarfBuzz objects
    hb_buffer_t* mHBBuffer;
    hb_font_t* mHBFont;
    
    // Initialization flag
    bool mInitialized;
    
    // Caching system
    bool mEnableCache;
    size_t mMaxCacheSize;
    std::map<std::wstring, std::wstring> mProcessedTextCache;
    size_t mCacheHits;
    size_t mCacheMisses;
    
    // Helper methods
    void limitCacheSize();
    std::wstring getCachedText(const std::wstring& key) const;
    void cacheText(const std::wstring& key, const std::wstring& value);
};

/**
 * Utility functions for string conversion
 */
namespace LLArabicUtil
{
    /**
     * Convert UTF-8 string to wide string
     */
    std::wstring utf8_to_wstring(const std::string& str);
    
    /**
     * Convert wide string to UTF-8 string
     */
    std::string wstring_to_utf8(const std::wstring& wstr);
    
    /**
     * Detect if string needs Arabic processing
     * @param str UTF-8 string
     * @return true if contains Arabic characters
     */
    bool needsArabicProcessing(const std::string& str);
    
    /**
     * Process Arabic string (UTF-8 convenience wrapper)
     * @param str Input UTF-8 string
     * @return Processed UTF-8 string
     */
    std::string processArabicString(const std::string& str);
}

#endif // LL_LLARABICSUPPORT_H
