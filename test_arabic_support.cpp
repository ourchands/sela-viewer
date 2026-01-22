/**
 * @file test_arabic_support.cpp
 * @brief Test program for Arabic text support
 * @author Sela Viewer Team
 */

#include "llarabicsupport.h"
#include <iostream>
#include <iomanip>
#include <cassert>

// ANSI color codes for better output
#define RESET   "\033[0m"
#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define BLUE    "\033[34m"
#define MAGENTA "\033[35m"
#define CYAN    "\033[36m"

void printTestHeader(const std::string& test_name)
{
    std::cout << "\n" << CYAN << "═══════════════════════════════════════" << RESET << "\n";
    std::cout << YELLOW << "  Test: " << test_name << RESET << "\n";
    std::cout << CYAN << "═══════════════════════════════════════" << RESET << "\n";
}

void printSuccess(const std::string& message)
{
    std::cout << GREEN << "✓ " << message << RESET << "\n";
}

void printFailure(const std::string& message)
{
    std::cout << RED << "✗ " << message << RESET << "\n";
}

void printInfo(const std::string& message)
{
    std::cout << BLUE << "  " << message << RESET << "\n";
}

// Test 1: Character Detection
void testCharacterDetection()
{
    printTestHeader("Character Detection");
    
    LLArabicSupport& arabic = LLArabicSupport::instance();
    
    // Test Arabic characters
    wchar_t arabic_chars[] = {
        L'ا', L'ب', L'ت', L'ث', L'ج', L'ح', L'خ', L'د',
        L'ذ', L'ر', L'ز', L'س', L'ش', L'ص', L'ض', L'ط',
        L'ظ', L'ع', L'غ', L'ف', L'ق', L'ك', L'ل', L'م',
        L'ن', L'ه', L'و', L'ي'
    };
    
    bool all_detected = true;
    for (wchar_t ch : arabic_chars)
    {
        if (!arabic.isArabicChar(ch))
        {
            all_detected = false;
            printFailure(std::string("Failed to detect Arabic character: ") + 
                        static_cast<char>(ch));
        }
    }
    
    if (all_detected)
    {
        printSuccess("All Arabic characters detected correctly");
    }
    
    // Test non-Arabic characters
    wchar_t english_chars[] = {L'A', L'B', L'Z', L'a', L'z', L'0', L'9', L'!', L'@'};
    bool none_false_positive = true;
    
    for (wchar_t ch : english_chars)
    {
        if (arabic.isArabicChar(ch))
        {
            none_false_positive = false;
            printFailure("False positive: Non-Arabic character detected as Arabic");
        }
    }
    
    if (none_false_positive)
    {
        printSuccess("No false positives in English character detection");
    }
    
    // Test digits
    bool digit_test = arabic.isDigit(L'5') && 
                     arabic.isDigit(L'٥') &&  // Arabic-Indic digit 5
                     !arabic.isDigit(L'A');
    
    if (digit_test)
    {
        printSuccess("Digit detection working correctly");
    }
    else
    {
        printFailure("Digit detection failed");
    }
}

// Test 2: Text Detection
void testTextDetection()
{
    printTestHeader("Text Detection");
    
    LLArabicSupport& arabic = LLArabicSupport::instance();
    
    struct TestCase {
        std::wstring text;
        bool should_contain_arabic;
        std::string description;
    };
    
    TestCase test_cases[] = {
        {L"مرحبا", true, "Pure Arabic text"},
        {L"Hello", false, "Pure English text"},
        {L"Hello مرحبا", true, "Mixed Arabic/English"},
        {L"مرحبا Hello", true, "Mixed English/Arabic"},
        {L"12345", false, "Numbers only"},
        {L"مرحبا 123", true, "Arabic with numbers"},
        {L"", false, "Empty string"},
        {L"السلام عليكم ورحمة الله وبركاته", true, "Long Arabic text"},
    };
    
    bool all_passed = true;
    for (const auto& test : test_cases)
    {
        bool result = arabic.containsArabic(test.text);
        if (result == test.should_contain_arabic)
        {
            printSuccess(test.description);
        }
        else
        {
            printFailure(test.description);
            all_passed = false;
        }
    }
    
    if (all_passed)
    {
        printInfo("All text detection tests passed!");
    }
}

// Test 3: Bidirectional Text Reordering
void testBidiReordering()
{
    printTestHeader("Bidirectional Text Reordering");
    
    LLArabicSupport& arabic = LLArabicSupport::instance();
    
    // Test cases
    std::wstring arabic_text = L"مرحبا";
    std::wstring english_text = L"Hello";
    std::wstring mixed_text = L"Hello مرحبا World";
    
    printInfo("Testing pure Arabic text...");
    std::wstring reordered_arabic = arabic.reorderBidiText(arabic_text);
    if (!reordered_arabic.empty())
    {
        printSuccess("Arabic text reordered successfully");
        std::wcout << L"  Original: " << arabic_text << L"\n";
        std::wcout << L"  Reordered: " << reordered_arabic << L"\n";
    }
    else
    {
        printFailure("Failed to reorder Arabic text");
    }
    
    printInfo("Testing English text (should remain unchanged)...");
    std::wstring reordered_english = arabic.reorderBidiText(english_text);
    if (reordered_english == english_text)
    {
        printSuccess("English text unchanged (correct)");
    }
    else
    {
        printFailure("English text was modified (incorrect)");
    }
    
    printInfo("Testing mixed text...");
    std::wstring reordered_mixed = arabic.reorderBidiText(mixed_text);
    if (!reordered_mixed.empty())
    {
        printSuccess("Mixed text reordered successfully");
        std::wcout << L"  Original: " << mixed_text << L"\n";
        std::wcout << L"  Reordered: " << reordered_mixed << L"\n";
    }
    else
    {
        printFailure("Failed to reorder mixed text");
    }
}

// Test 4: Complete Arabic Processing
void testCompleteProcessing()
{
    printTestHeader("Complete Arabic Text Processing");
    
    LLArabicSupport& arabic = LLArabicSupport::instance();
    
    struct TestCase {
        std::wstring input;
        std::string description;
    };
    
    TestCase test_cases[] = {
        {L"مرحبا بك", "Simple greeting"},
        {L"السلام عليكم", "Traditional greeting"},
        {L"اللغة العربية", "Arabic language"},
        {L"Hello مرحبا", "Mixed text"},
        {L"123 عربي", "Numbers with Arabic"},
    };
    
    for (const auto& test : test_cases)
    {
        printInfo(std::string("Processing: ") + test.description);
        
        std::wstring processed = arabic.processArabicText(test.input);
        
        if (!processed.empty())
        {
            printSuccess("Processing completed");
            std::wcout << L"  Input:  " << test.input << L"\n";
            std::wcout << L"  Output: " << processed << L"\n";
        }
        else
        {
            printFailure("Processing failed");
        }
    }
}

// Test 5: UTF-8 Utilities
void testUtf8Utilities()
{
    printTestHeader("UTF-8 Utility Functions");
    
    std::string utf8_arabic = "مرحبا";
    std::string utf8_english = "Hello";
    std::string utf8_mixed = "Hello مرحبا";
    
    // Test conversion
    printInfo("Testing UTF-8 to wide string conversion...");
    std::wstring wide_arabic = LLArabicUtil::utf8_to_wstring(utf8_arabic);
    if (!wide_arabic.empty())
    {
        printSuccess("Conversion successful");
    }
    else
    {
        printFailure("Conversion failed");
    }
    
    // Test back conversion
    printInfo("Testing wide string to UTF-8 conversion...");
    std::string back_to_utf8 = LLArabicUtil::wstring_to_utf8(wide_arabic);
    if (back_to_utf8 == utf8_arabic)
    {
        printSuccess("Round-trip conversion successful");
    }
    else
    {
        printFailure("Round-trip conversion failed");
    }
    
    // Test needs processing
    printInfo("Testing needsArabicProcessing...");
    bool needs_arabic = LLArabicUtil::needsArabicProcessing(utf8_arabic);
    bool needs_english = LLArabicUtil::needsArabicProcessing(utf8_english);
    bool needs_mixed = LLArabicUtil::needsArabicProcessing(utf8_mixed);
    
    if (needs_arabic && !needs_english && needs_mixed)
    {
        printSuccess("needsArabicProcessing works correctly");
    }
    else
    {
        printFailure("needsArabicProcessing has issues");
    }
    
    // Test string processing
    printInfo("Testing processArabicString...");
    std::string processed = LLArabicUtil::processArabicString(utf8_arabic);
    if (!processed.empty())
    {
        printSuccess("String processing successful");
        std::cout << "  Input:  " << utf8_arabic << "\n";
        std::cout << "  Output: " << processed << "\n";
    }
    else
    {
        printFailure("String processing failed");
    }
}

// Test 6: Caching System
void testCachingSystem()
{
    printTestHeader("Caching System");
    
    LLArabicSupport& arabic = LLArabicSupport::instance();
    
    // Clear cache first
    arabic.clearCache();
    
    size_t cache_size, hit_count, miss_count;
    arabic.getCacheStats(cache_size, hit_count, miss_count);
    
    printInfo("Initial cache state:");
    std::cout << "  Size: " << cache_size << ", Hits: " << hit_count 
              << ", Misses: " << miss_count << "\n";
    
    // Process same text multiple times
    std::wstring test_text = L"مرحبا بك في العالم";
    
    printInfo("Processing text first time...");
    arabic.processArabicText(test_text);
    
    printInfo("Processing same text second time...");
    arabic.processArabicText(test_text);
    
    printInfo("Processing same text third time...");
    arabic.processArabicText(test_text);
    
    arabic.getCacheStats(cache_size, hit_count, miss_count);
    
    printInfo("Final cache state:");
    std::cout << "  Size: " << cache_size << ", Hits: " << hit_count 
              << ", Misses: " << miss_count << "\n";
    
    if (hit_count >= 2)
    {
        printSuccess("Caching is working (at least 2 hits)");
    }
    else
    {
        printFailure("Caching may not be working properly");
    }
    
    // Test cache clearing
    arabic.clearCache();
    arabic.getCacheStats(cache_size, hit_count, miss_count);
    
    if (cache_size == 0 && hit_count == 0 && miss_count == 0)
    {
        printSuccess("Cache clearing works correctly");
    }
    else
    {
        printFailure("Cache clearing may have issues");
    }
}

// Main test runner
int main(int argc, char* argv[])
{
    std::cout << "\n";
    std::cout << MAGENTA << "╔═══════════════════════════════════════════════════╗\n";
    std::cout << "║                                                   ║\n";
    std::cout << "║      Sela Viewer - Arabic Support Test Suite     ║\n";
    std::cout << "║                                                   ║\n";
    std::cout << "╚═══════════════════════════════════════════════════╝" << RESET << "\n";
    
    try
    {
        // Run all tests
        testCharacterDetection();
        testTextDetection();
        testBidiReordering();
        testCompleteProcessing();
        testUtf8Utilities();
        testCachingSystem();
        
        // Summary
        std::cout << "\n" << CYAN << "═══════════════════════════════════════" << RESET << "\n";
        std::cout << GREEN << "  All tests completed!" << RESET << "\n";
        std::cout << CYAN << "═══════════════════════════════════════" << RESET << "\n\n";
        
        return 0;
    }
    catch (const std::exception& e)
    {
        std::cerr << RED << "\nException occurred: " << e.what() << RESET << "\n";
        return 1;
    }
    catch (...)
    {
        std::cerr << RED << "\nUnknown exception occurred!" << RESET << "\n";
        return 1;
    }
}
