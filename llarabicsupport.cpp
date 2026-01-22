/**
 * @file llarabicsupport.cpp
 * @brief Arabic text support implementation
 * @author Sela Viewer Team
 *
 * $LicenseInfo:firstyear=2025&license=lgpl$
 * $/LicenseInfo$
 */

#include "llarabicsupport.h"

// HarfBuzz includes
#include <harfbuzz/hb.h>
#include <harfbuzz/hb-ft.h>

// FriBidi includes
#include <fribidi/fribidi.h>

// FreeType includes
#include <ft2build.h>
#include FT_FREETYPE_H

// Standard includes
#include <algorithm>
#include <codecvt>
#include <locale>

//-----------------------------------------------------------------------------
// LLArabicSupport implementation
//-----------------------------------------------------------------------------

LLArabicSupport& LLArabicSupport::instance()
{
    static LLArabicSupport sInstance;
    return sInstance;
}

LLArabicSupport::LLArabicSupport()
    : mHBBuffer(nullptr)
    , mHBFont(nullptr)
    , mInitialized(false)
    , mEnableCache(true)
    , mMaxCacheSize(1000)
    , mCacheHits(0)
    , mCacheMisses(0)
{
    // Create HarfBuzz buffer
    mHBBuffer = hb_buffer_create();
    
    if (!hb_buffer_allocation_successful(mHBBuffer))
    {
        hb_buffer_destroy(mHBBuffer);
        mHBBuffer = nullptr;
    }
}

LLArabicSupport::~LLArabicSupport()
{
    if (mHBBuffer)
    {
        hb_buffer_destroy(mHBBuffer);
        mHBBuffer = nullptr;
    }
    
    if (mHBFont)
    {
        hb_font_destroy(mHBFont);
        mHBFont = nullptr;
    }
}

bool LLArabicSupport::initialize(FT_Face font_face)
{
    if (mInitialized)
    {
        return true;
    }
    
    if (!font_face)
    {
        return false;
    }
    
    // Clean up old font if exists
    if (mHBFont)
    {
        hb_font_destroy(mHBFont);
        mHBFont = nullptr;
    }
    
    // Create HarfBuzz font from FreeType face
    mHBFont = hb_ft_font_create(font_face, nullptr);
    
    if (!mHBFont)
    {
        return false;
    }
    
    mInitialized = true;
    return true;
}

bool LLArabicSupport::isArabicChar(wchar_t ch) const
{
    // Unicode ranges for Arabic script
    return (ch >= 0x0600 && ch <= 0x06FF) ||  // Arabic
           (ch >= 0x0750 && ch <= 0x077F) ||  // Arabic Supplement
           (ch >= 0x08A0 && ch <= 0x08FF) ||  // Arabic Extended-A
           (ch >= 0xFB50 && ch <= 0xFDFF) ||  // Arabic Presentation Forms-A
           (ch >= 0xFE70 && ch <= 0xFEFF);    // Arabic Presentation Forms-B
}

bool LLArabicSupport::isDigit(wchar_t ch) const
{
    return (ch >= L'0' && ch <= L'9') ||       // ASCII digits
           (ch >= 0x0660 && ch <= 0x0669) ||   // Arabic-Indic digits
           (ch >= 0x06F0 && ch <= 0x06F9);     // Extended Arabic-Indic digits
}

bool LLArabicSupport::containsArabic(const std::wstring& text) const
{
    for (wchar_t ch : text)
    {
        if (isArabicChar(ch))
        {
            return true;
        }
    }
    return false;
}

std::wstring LLArabicSupport::reorderBidiText(const std::wstring& input)
{
    if (input.empty())
    {
        return input;
    }
    
    // Check cache first
    if (mEnableCache)
    {
        std::wstring cached = getCachedText(input);
        if (!cached.empty())
        {
            return cached;
        }
    }
    
    // Prepare buffers
    size_t length = input.length();
    std::vector<FriBidiChar> unicode_str(length);
    std::vector<FriBidiChar> visual_str(length);
    std::vector<FriBidiCharType> bidi_types(length);
    std::vector<FriBidiLevel> embedding_levels(length);
    std::vector<FriBidiStrIndex> positions_map(length);
    
    // Copy input to FriBidi format
    for (size_t i = 0; i < length; ++i)
    {
        unicode_str[i] = static_cast<FriBidiChar>(input[i]);
    }
    
    // Set paragraph direction to RTL for Arabic text
    FriBidiParType base_dir = containsArabic(input) ? 
                              FRIBIDI_PAR_RTL : FRIBIDI_PAR_LTR;
    
    // Get character types
    fribidi_get_bidi_types(unicode_str.data(), length, bidi_types.data());
    
    // Get embedding levels
    FriBidiLevel max_level = fribidi_get_par_embedding_levels(
        bidi_types.data(), length, &base_dir, embedding_levels.data());
    
    if (max_level == 0)
    {
        // No reordering needed
        return input;
    }
    
    // Reorder the text
    if (!fribidi_reorder_line(
            FRIBIDI_FLAGS_DEFAULT,
            bidi_types.data(), length,
            0, base_dir,
            embedding_levels.data(),
            visual_str.data(),
            positions_map.data()))
    {
        // Reordering failed, return original
        return input;
    }
    
    // Convert back to wstring
    std::wstring result;
    result.reserve(length);
    for (size_t i = 0; i < length; ++i)
    {
        result.push_back(static_cast<wchar_t>(visual_str[i]));
    }
    
    // Cache the result
    if (mEnableCache)
    {
        cacheText(input, result);
    }
    
    return result;
}

std::wstring LLArabicSupport::shapeArabicText(const std::wstring& input)
{
    if (input.empty() || !mInitialized || !mHBFont)
    {
        return input;
    }
    
    // Only shape if text contains Arabic
    if (!containsArabic(input))
    {
        return input;
    }
    
    // Clear HarfBuzz buffer
    hb_buffer_clear_contents(mHBBuffer);
    
    // Add text to buffer
    for (size_t i = 0; i < input.length(); ++i)
    {
        hb_buffer_add(mHBBuffer, static_cast<hb_codepoint_t>(input[i]), i);
    }
    
    // Set buffer properties for Arabic
    hb_buffer_set_direction(mHBBuffer, HB_DIRECTION_RTL);
    hb_buffer_set_script(mHBBuffer, HB_SCRIPT_ARABIC);
    hb_buffer_set_language(mHBBuffer, hb_language_from_string("ar", -1));
    
    // Guess segment properties if not set
    hb_buffer_guess_segment_properties(mHBBuffer);
    
    // Shape the text
    hb_shape(mHBFont, mHBBuffer, nullptr, 0);
    
    // Get glyph information
    unsigned int glyph_count = 0;
    hb_glyph_info_t* glyph_info = hb_buffer_get_glyph_infos(mHBBuffer, &glyph_count);
    
    if (glyph_count == 0)
    {
        return input;
    }
    
    // Build result string from glyphs
    std::wstring result;
    result.reserve(glyph_count);
    
    for (unsigned int i = 0; i < glyph_count; ++i)
    {
        // Note: In a real implementation, you would map glyph IDs to Unicode
        // For now, we use the codepoint which HarfBuzz provides
        result.push_back(static_cast<wchar_t>(glyph_info[i].codepoint));
    }
    
    return result;
}

std::wstring LLArabicSupport::processArabicText(const std::wstring& input)
{
    if (input.empty())
    {
        return input;
    }
    
    // Check if processing is needed
    if (!containsArabic(input))
    {
        return input;
    }
    
    // Check cache
    if (mEnableCache)
    {
        std::wstring cached = getCachedText(L"FULL:" + input);
        if (!cached.empty())
        {
            mCacheHits++;
            return cached;
        }
        mCacheMisses++;
    }
    
    // Step 1: Reorder bidirectional text
    std::wstring reordered = reorderBidiText(input);
    
    // Step 2: Shape Arabic characters
    std::wstring shaped = shapeArabicText(reordered);
    
    // Cache the final result
    if (mEnableCache)
    {
        cacheText(L"FULL:" + input, shaped);
    }
    
    return shaped;
}

void LLArabicSupport::clearCache()
{
    mProcessedTextCache.clear();
    mCacheHits = 0;
    mCacheMisses = 0;
}

void LLArabicSupport::getCacheStats(size_t& cache_size, size_t& hit_count, 
                                    size_t& miss_count) const
{
    cache_size = mProcessedTextCache.size();
    hit_count = mCacheHits;
    miss_count = mCacheMisses;
}

std::wstring LLArabicSupport::getCachedText(const std::wstring& key) const
{
    auto it = mProcessedTextCache.find(key);
    if (it != mProcessedTextCache.end())
    {
        return it->second;
    }
    return std::wstring();
}

void LLArabicSupport::cacheText(const std::wstring& key, const std::wstring& value)
{
    // Check if we need to limit cache size
    if (mMaxCacheSize > 0 && mProcessedTextCache.size() >= mMaxCacheSize)
    {
        limitCacheSize();
    }
    
    mProcessedTextCache[key] = value;
}

void LLArabicSupport::limitCacheSize()
{
    // Simple strategy: remove oldest entries (first 25%)
    if (mProcessedTextCache.empty())
    {
        return;
    }
    
    size_t to_remove = mProcessedTextCache.size() / 4;
    if (to_remove == 0)
    {
        to_remove = 1;
    }
    
    auto it = mProcessedTextCache.begin();
    for (size_t i = 0; i < to_remove && it != mProcessedTextCache.end(); ++i)
    {
        it = mProcessedTextCache.erase(it);
    }
}

//-----------------------------------------------------------------------------
// LLArabicUtil implementation
//-----------------------------------------------------------------------------

namespace LLArabicUtil
{
    std::wstring utf8_to_wstring(const std::string& str)
    {
        if (str.empty())
        {
            return std::wstring();
        }
        
        try
        {
            std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
            return converter.from_bytes(str);
        }
        catch (...)
        {
            // Fallback: simple cast (may not work for non-ASCII)
            return std::wstring(str.begin(), str.end());
        }
    }
    
    std::string wstring_to_utf8(const std::wstring& wstr)
    {
        if (wstr.empty())
        {
            return std::string();
        }
        
        try
        {
            std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
            return converter.to_bytes(wstr);
        }
        catch (...)
        {
            // Fallback: simple cast (may not work for non-ASCII)
            return std::string(wstr.begin(), wstr.end());
        }
    }
    
    bool needsArabicProcessing(const std::string& str)
    {
        std::wstring wstr = utf8_to_wstring(str);
        return LLArabicSupport::instance().containsArabic(wstr);
    }
    
    std::string processArabicString(const std::string& str)
    {
        if (str.empty())
        {
            return str;
        }
        
        // Convert to wide string
        std::wstring wstr = utf8_to_wstring(str);
        
        // Process
        std::wstring processed = LLArabicSupport::instance().processArabicText(wstr);
        
        // Convert back to UTF-8
        return wstring_to_utf8(processed);
    }
}
