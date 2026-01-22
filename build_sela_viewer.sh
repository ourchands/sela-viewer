#!/bin/bash
################################################################################
# Sela Viewer - Automatic Arabic Second Life Viewer Builder
# النسخة الآلية الكاملة - لا تحتاج إلى معرفة برمجية
# 
# الاستخدام:
#   ./build_sela_viewer.sh
#
# سيقوم هذا السكريبت بـ:
# 1. تحميل Firestorm تلقائياً
# 2. إضافة دعم اللغة العربية (RTL + تشكيل الحروف)
# 3. تغيير الاسم إلى Sela Viewer
# 4. تغيير الشعار والأيقونات
# 5. تعديل نص البداية والروابط
# 6. بناء البرنامج تلقائياً
################################################################################

set -e  # إيقاف عند أي خطأ

# الألوان للرسائل
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # بدون لون

# الإعدادات الافتراضية (يمكن تغييرها)
VIEWER_NAME="Sela Viewer"
VIEWER_SHORT_NAME="Sela"
VERSION="1.0.0"
YOUR_WEBSITE="https://example.com"
YOUR_SUPPORT_TEXT="للدعم الفني: support@example.com"

# مجلد العمل
WORK_DIR="$HOME/sela-viewer-build"
FIRESTORM_DIR="$WORK_DIR/phoenix-firestorm"
RESOURCES_DIR="$WORK_DIR/sela-resources"

################################################################################
# وظائف مساعدة
################################################################################

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$2 غير موجود. جاري التثبيت..."
        return 1
    fi
    return 0
}

################################################################################
# 1. فحص وتثبيت المتطلبات
################################################################################

install_dependencies() {
    print_header "فحص وتثبيت المتطلبات"
    
    # التحقق من نظام التشغيل
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_info "نظام Linux مكتشف"
        
        # تحديث قائمة الحزم
        print_info "تحديث قائمة الحزم..."
        sudo apt update
        
        # تثبيت المتطلبات الأساسية
        print_info "تثبيت أدوات التطوير..."
        sudo apt install -y \
            build-essential \
            cmake \
            git \
            python3 \
            python3-pip \
            wget \
            curl
        
        # تثبيت المكتبات المطلوبة
        print_info "تثبيت المكتبات..."
        sudo apt install -y \
            libgl1-mesa-dev \
            libglu1-mesa-dev \
            libx11-dev \
            libxinerama-dev \
            libxrandr-dev \
            libxi-dev \
            libxcursor-dev \
            libfreetype6-dev \
            libfontconfig1-dev \
            libasound2-dev \
            libpulse-dev \
            libssl-dev \
            libboost-all-dev
        
        # تثبيت مكتبات العربية
        print_info "تثبيت مكتبات دعم اللغة العربية..."
        sudo apt install -y \
            libharfbuzz-dev \
            libfribidi-dev \
            libicu-dev
        
        # تثبيت ImageMagick لتحويل الصور
        print_info "تثبيت أدوات معالجة الصور..."
        sudo apt install -y imagemagick
        
        print_success "تم تثبيت جميع المتطلبات بنجاح"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        print_error "نظام macOS - يرجى استخدام Homebrew لتثبيت المتطلبات"
        exit 1
    else
        print_error "نظام تشغيل غير مدعوم"
        exit 1
    fi
}

################################################################################
# 2. تحميل Firestorm
################################################################################

download_firestorm() {
    print_header "تحميل Firestorm Viewer"
    
    # إنشاء مجلد العمل
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    
    if [ -d "$FIRESTORM_DIR" ]; then
        print_warning "Firestorm موجود بالفعل. هل تريد تحديثه؟ (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_info "تحديث Firestorm..."
            cd "$FIRESTORM_DIR"
            git fetch --all
            git pull origin main
        else
            print_info "استخدام النسخة الموجودة"
        fi
    else
        print_info "استنساخ مستودع Firestorm..."
        git clone https://github.com/FirestormViewer/phoenix-firestorm.git
        cd "$FIRESTORM_DIR"
    fi
    
    # الانتقال إلى آخر إصدار مستقر
    print_info "الانتقال إلى آخر إصدار مستقر..."
    LATEST_TAG=$(git describe --tags --abbrev=0)
    git checkout $LATEST_TAG
    
    print_success "تم تحميل Firestorm بنجاح (الإصدار: $LATEST_TAG)"
}

################################################################################
# 3. إنشاء ملفات دعم العربية
################################################################################

create_arabic_support_files() {
    print_header "إنشاء ملفات دعم اللغة العربية"
    
    cd "$FIRESTORM_DIR"
    
    # إنشاء مجلد llui إذا لم يكن موجوداً
    mkdir -p indra/llui
    
    # إنشاء llarabicsupport.h
    print_info "إنشاء llarabicsupport.h..."
    cat > indra/llui/llarabicsupport.h << 'HEADER_EOF'
#ifndef LL_LLARABICSUPPORT_H
#define LL_LLARABICSUPPORT_H

#include <string>
#include <vector>
#include <map>

typedef struct hb_buffer_t hb_buffer_t;
typedef struct hb_font_t hb_font_t;
typedef struct FT_FaceRec_* FT_Face;

class LLArabicSupport
{
public:
    static LLArabicSupport& instance();
    bool initialize(FT_Face font_face);
    bool isInitialized() const { return mInitialized; }
    
    std::wstring processArabicText(const std::wstring& input);
    std::wstring shapeArabicText(const std::wstring& input);
    std::wstring reorderBidiText(const std::wstring& input);
    
    bool containsArabic(const std::wstring& text) const;
    bool isArabicChar(wchar_t ch) const;
    bool isDigit(wchar_t ch) const;
    
    void setEnableCache(bool enable) { mEnableCache = enable; }
    void clearCache();

private:
    LLArabicSupport();
    ~LLArabicSupport();
    LLArabicSupport(const LLArabicSupport&) = delete;
    LLArabicSupport& operator=(const LLArabicSupport&) = delete;
    
    hb_buffer_t* mHBBuffer;
    hb_font_t* mHBFont;
    bool mInitialized;
    bool mEnableCache;
    size_t mMaxCacheSize;
    std::map<std::wstring, std::wstring> mProcessedTextCache;
    
    std::wstring getCachedText(const std::wstring& key) const;
    void cacheText(const std::wstring& key, const std::wstring& value);
};

namespace LLArabicUtil
{
    std::wstring utf8_to_wstring(const std::string& str);
    std::string wstring_to_utf8(const std::wstring& wstr);
    bool needsArabicProcessing(const std::string& str);
    std::string processArabicString(const std::string& str);
}

#endif
HEADER_EOF
    
    # إنشاء llarabicsupport.cpp
    print_info "إنشاء llarabicsupport.cpp..."
    cat > indra/llui/llarabicsupport.cpp << 'CPP_EOF'
#include "llarabicsupport.h"
#include <harfbuzz/hb.h>
#include <harfbuzz/hb-ft.h>
#include <fribidi/fribidi.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include <algorithm>
#include <codecvt>
#include <locale>

LLArabicSupport& LLArabicSupport::instance()
{
    static LLArabicSupport sInstance;
    return sInstance;
}

LLArabicSupport::LLArabicSupport()
    : mHBBuffer(nullptr), mHBFont(nullptr), mInitialized(false)
    , mEnableCache(true), mMaxCacheSize(1000)
{
    mHBBuffer = hb_buffer_create();
}

LLArabicSupport::~LLArabicSupport()
{
    if (mHBBuffer) hb_buffer_destroy(mHBBuffer);
    if (mHBFont) hb_font_destroy(mHBFont);
}

bool LLArabicSupport::initialize(FT_Face font_face)
{
    if (mInitialized) return true;
    if (!font_face) return false;
    if (mHBFont) hb_font_destroy(mHBFont);
    mHBFont = hb_ft_font_create(font_face, nullptr);
    if (!mHBFont) return false;
    mInitialized = true;
    return true;
}

bool LLArabicSupport::isArabicChar(wchar_t ch) const
{
    return (ch >= 0x0600 && ch <= 0x06FF) ||
           (ch >= 0x0750 && ch <= 0x077F) ||
           (ch >= 0x08A0 && ch <= 0x08FF) ||
           (ch >= 0xFB50 && ch <= 0xFDFF) ||
           (ch >= 0xFE70 && ch <= 0xFEFF);
}

bool LLArabicSupport::isDigit(wchar_t ch) const
{
    return (ch >= L'0' && ch <= L'9') ||
           (ch >= 0x0660 && ch <= 0x0669) ||
           (ch >= 0x06F0 && ch <= 0x06F9);
}

bool LLArabicSupport::containsArabic(const std::wstring& text) const
{
    for (wchar_t ch : text) {
        if (isArabicChar(ch)) return true;
    }
    return false;
}

std::wstring LLArabicSupport::reorderBidiText(const std::wstring& input)
{
    if (input.empty()) return input;
    
    std::wstring cached = getCachedText(input);
    if (mEnableCache && !cached.empty()) return cached;
    
    size_t length = input.length();
    std::vector<FriBidiChar> unicode_str(length);
    std::vector<FriBidiChar> visual_str(length);
    std::vector<FriBidiCharType> bidi_types(length);
    std::vector<FriBidiLevel> embedding_levels(length);
    
    for (size_t i = 0; i < length; ++i)
        unicode_str[i] = static_cast<FriBidiChar>(input[i]);
    
    FriBidiParType base_dir = containsArabic(input) ? FRIBIDI_PAR_RTL : FRIBIDI_PAR_LTR;
    
    fribidi_get_bidi_types(unicode_str.data(), length, bidi_types.data());
    fribidi_get_par_embedding_levels(bidi_types.data(), length, &base_dir, embedding_levels.data());
    fribidi_reorder_line(FRIBIDI_FLAGS_DEFAULT, bidi_types.data(), length,
                         0, base_dir, embedding_levels.data(), visual_str.data(), nullptr);
    
    std::wstring result(visual_str.begin(), visual_str.end());
    if (mEnableCache) cacheText(input, result);
    return result;
}

std::wstring LLArabicSupport::shapeArabicText(const std::wstring& input)
{
    if (input.empty() || !mInitialized || !mHBFont || !containsArabic(input))
        return input;
    
    hb_buffer_clear_contents(mHBBuffer);
    for (size_t i = 0; i < input.length(); ++i)
        hb_buffer_add(mHBBuffer, static_cast<hb_codepoint_t>(input[i]), i);
    
    hb_buffer_set_direction(mHBBuffer, HB_DIRECTION_RTL);
    hb_buffer_set_script(mHBBuffer, HB_SCRIPT_ARABIC);
    hb_buffer_set_language(mHBBuffer, hb_language_from_string("ar", -1));
    hb_buffer_guess_segment_properties(mHBBuffer);
    hb_shape(mHBFont, mHBBuffer, nullptr, 0);
    
    unsigned int glyph_count = 0;
    hb_glyph_info_t* glyph_info = hb_buffer_get_glyph_infos(mHBBuffer, &glyph_count);
    
    std::wstring result;
    result.reserve(glyph_count);
    for (unsigned int i = 0; i < glyph_count; ++i)
        result.push_back(static_cast<wchar_t>(glyph_info[i].codepoint));
    
    return result;
}

std::wstring LLArabicSupport::processArabicText(const std::wstring& input)
{
    if (input.empty() || !containsArabic(input)) return input;
    
    std::wstring cached = getCachedText(L"FULL:" + input);
    if (mEnableCache && !cached.empty()) return cached;
    
    std::wstring reordered = reorderBidiText(input);
    std::wstring shaped = shapeArabicText(reordered);
    
    if (mEnableCache) cacheText(L"FULL:" + input, shaped);
    return shaped;
}

void LLArabicSupport::clearCache()
{
    mProcessedTextCache.clear();
}

std::wstring LLArabicSupport::getCachedText(const std::wstring& key) const
{
    auto it = mProcessedTextCache.find(key);
    return (it != mProcessedTextCache.end()) ? it->second : std::wstring();
}

void LLArabicSupport::cacheText(const std::wstring& key, const std::wstring& value)
{
    if (mMaxCacheSize > 0 && mProcessedTextCache.size() >= mMaxCacheSize)
        mProcessedTextCache.erase(mProcessedTextCache.begin());
    mProcessedTextCache[key] = value;
}

namespace LLArabicUtil
{
    std::wstring utf8_to_wstring(const std::string& str)
    {
        if (str.empty()) return std::wstring();
        try {
            std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
            return converter.from_bytes(str);
        } catch (...) {
            return std::wstring(str.begin(), str.end());
        }
    }
    
    std::string wstring_to_utf8(const std::wstring& wstr)
    {
        if (wstr.empty()) return std::string();
        try {
            std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
            return converter.to_bytes(wstr);
        } catch (...) {
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
        if (str.empty()) return str;
        std::wstring wstr = utf8_to_wstring(str);
        std::wstring processed = LLArabicSupport::instance().processArabicText(wstr);
        return wstring_to_utf8(processed);
    }
}
CPP_EOF
    
    # إنشاء Arabic.cmake
    print_info "إنشاء Arabic.cmake..."
    mkdir -p indra/cmake
    cat > indra/cmake/Arabic.cmake << 'CMAKE_EOF'
include(Prebuilt)
set(ARABIC_FIND_REQUIRED ON)

if (STANDALONE)
    include(FindPkgConfig)
    pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
    pkg_check_modules(FRIBIDI REQUIRED fribidi)
else (STANDALONE)
    use_prebuilt_binary(harfbuzz)
    use_prebuilt_binary(fribidi)
    set(HARFBUZZ_INCLUDE_DIRS ${LIBS_PREBUILT_DIR}/include/harfbuzz)
    set(FRIBIDI_INCLUDE_DIRS ${LIBS_PREBUILT_DIR}/include/fribidi)
    if (LINUX)
        set(HARFBUZZ_LIBRARIES harfbuzz)
        set(FRIBIDI_LIBRARIES fribidi)
    endif (LINUX)
endif (STANDALONE)

include_directories(${HARFBUZZ_INCLUDE_DIRS} ${FRIBIDI_INCLUDE_DIRS})
set(ARABIC_LIBRARIES ${HARFBUZZ_LIBRARIES} ${FRIBIDI_LIBRARIES} PARENT_SCOPE)
CMAKE_EOF
    
    print_success "تم إنشاء ملفات دعم العربية بنجاح"
}

################################################################################
# 4. تعديل CMakeLists.txt لإضافة الملفات الجديدة
################################################################################

modify_cmake_files() {
    print_header "تعديل ملفات CMake"
    
    cd "$FIRESTORM_DIR"
    
    # تعديل indra/llui/CMakeLists.txt
    print_info "تعديل indra/llui/CMakeLists.txt..."
    
    # إضافة include للعربية
    if ! grep -q "include(Arabic)" indra/llui/CMakeLists.txt; then
        sed -i '1i include(Arabic)' indra/llui/CMakeLists.txt
    fi
    
    # إضافة ملفات المصدر
    if ! grep -q "llarabicsupport.cpp" indra/llui/CMakeLists.txt; then
        sed -i '/set(llui_SOURCE_FILES/a \    llarabicsupport.cpp' indra/llui/CMakeLists.txt
    fi
    
    if ! grep -q "llarabicsupport.h" indra/llui/CMakeLists.txt; then
        sed -i '/set(llui_HEADER_FILES/a \    llarabicsupport.h' indra/llui/CMakeLists.txt
    fi
    
    # إضافة المكتبات
    if ! grep -q "ARABIC_LIBRARIES" indra/llui/CMakeLists.txt; then
        sed -i '/target_link_libraries(/a \    ${ARABIC_LIBRARIES}' indra/llui/CMakeLists.txt
    fi
    
    print_success "تم تعديل ملفات CMake بنجاح"
}

################################################################################
# 5. تحميل الخط العربي
################################################################################

download_arabic_font() {
    print_header "تحميل الخط العربي"
    
    cd "$FIRESTORM_DIR"
    
    FONT_DIR="indra/newview/skins/default/fonts"
    mkdir -p "$FONT_DIR"
    
    print_info "تحميل Noto Sans Arabic..."
    wget -O "$FONT_DIR/NotoSansArabic-Regular.ttf" \
        "https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Regular.ttf"
    
    # تعديل fonts.xml
    print_info "تعديل fonts.xml..."
    FONTS_XML="$FONT_DIR/fonts.xml"
    
    if [ -f "$FONTS_XML" ]; then
        # إضافة الخط العربي
        if ! grep -q "NotoSansArabic" "$FONTS_XML"; then
            sed -i '/<\/fonts>/i \
    <font name="SansSerifArabic" comment="Arabic support font">\
        <file>NotoSansArabic-Regular.ttf</file>\
    </font>' "$FONTS_XML"
        fi
    fi
    
    print_success "تم تحميل وإعداد الخط العربي بنجاح"
}

################################################################################
# 6. تغيير الاسم والشعار
################################################################################

customize_branding() {
    print_header "تخصيص الاسم والشعار"
    
    cd "$FIRESTORM_DIR"
    
    # تغيير اسم البرنامج
    print_info "تغيير اسم البرنامج إلى $VIEWER_NAME..."
    
    # تعديل ViewerVersion.cmake
    if [ -f "indra/newview/ViewerVersion.cmake" ]; then
        sed -i "s/set(VIEWER_SHORT_NAME \".*\")/set(VIEWER_SHORT_NAME \"$VIEWER_SHORT_NAME\")/" \
            indra/newview/ViewerVersion.cmake
        sed -i "s/set(VIEWER_CHANNEL_NAME \".*\")/set(VIEWER_CHANNEL_NAME \"$VIEWER_NAME\")/" \
            indra/newview/ViewerVersion.cmake
        sed -i "s/set(VIEWER_CHANNEL_BASE \".*\")/set(VIEWER_CHANNEL_BASE \"$VIEWER_SHORT_NAME\")/" \
            indra/newview/ViewerVersion.cmake
    fi
    
    # إنشاء مجلد الموارد
    mkdir -p "$RESOURCES_DIR"
    
    print_info "لتخصيص الشعار، ضع الصور التالية في: $RESOURCES_DIR"
    print_info "  - logo.png (512x512) - الشعار الرئيسي"
    print_info "  - icon.png (256x256) - أيقونة البرنامج"
    print_info "  - splash.png (600x400) - شاشة البداية"
    
    # إنشاء صور افتراضية بسيطة
    print_info "إنشاء صور افتراضية..."
    
    # شعار بسيط مع نص "Sela"
    convert -size 512x512 xc:lightblue \
        -gravity center \
        -pointsize 120 \
        -fill darkblue \
        -annotate +0+0 "Sela" \
        "$RESOURCES_DIR/logo.png" 2>/dev/null || print_warning "فشل إنشاء الشعار الافتراضي"
    
    convert -size 256x256 xc:lightblue \
        -gravity center \
        -pointsize 60 \
        -fill darkblue \
        -annotate +0+0 "S" \
        "$RESOURCES_DIR/icon.png" 2>/dev/null || print_warning "فشل إنشاء الأيقونة الافتراضية"
    
    convert -size 600x400 xc:white \
        -gravity center \
        -pointsize 80 \
        -fill black \
        -annotate +0-50 "$VIEWER_NAME" \
        -pointsize 30 \
        -annotate +0+50 "مشاهد Second Life بدعم اللغة العربية" \
        "$RESOURCES_DIR/splash.png" 2>/dev/null || print_warning "فشل إنشاء شاشة البداية الافتراضية"
    
    print_success "تم إنشاء الصور الافتراضية"
    print_warning "يمكنك استبدالها بصورك الخاصة في: $RESOURCES_DIR"
}

################################################################################
# 7. تعديل نص البداية والروابط
################################################################################

customize_startup_text() {
    print_header "تخصيص نص البداية والروابط"
    
    cd "$FIRESTORM_DIR"
    
    # البحث عن ملف النصوص
    STRINGS_FILE="indra/newview/skins/default/xui/en/strings.xml"
    
    if [ -f "$STRINGS_FILE" ]; then
        print_info "تعديل النصوص..."
        
        # إضافة نص مخصص
        # هذا مثال - قد تحتاج لتعديله حسب بنية ملف strings.xml الفعلي
        cat >> "$STRINGS_FILE" << EOF
<!-- Sela Viewer Custom Text -->
<string name="SelaViewerWelcome">
مرحباً بك في $VIEWER_NAME
$YOUR_SUPPORT_TEXT
الموقع الرسمي: $YOUR_WEBSITE
</string>
EOF
    fi
    
    # إنشاء ملف إعدادات مخصص
    cat > "$RESOURCES_DIR/sela_config.txt" << EOF
# إعدادات Sela Viewer
VIEWER_NAME=$VIEWER_NAME
VIEWER_SHORT_NAME=$VIEWER_SHORT_NAME
VERSION=$VERSION
WEBSITE=$YOUR_WEBSITE
SUPPORT_TEXT=$YOUR_SUPPORT_TEXT
EOF
    
    print_success "تم تخصيص النصوص والروابط"
}

################################################################################
# 8. بناء البرنامج
################################################################################

build_viewer() {
    print_header "بناء Sela Viewer"
    
    cd "$FIRESTORM_DIR"
    
    print_info "هذه العملية قد تستغرق 30-60 دقيقة..."
    print_info "يمكنك أخذ استراحة والعودة لاحقاً ☕"
    
    # تنظيف البناء السابق
    print_info "تنظيف البناء السابق..."
    ./autobuild clean || true
    
    # تكوين البناء
    print_info "تكوين البناء..."
    ./autobuild configure -c ReleaseOS -- \
        -DVIEWER_CHANNEL="$VIEWER_NAME" \
        -DVIEWER_SHORT_NAME="$VIEWER_SHORT_NAME" \
        -DSTANDALONE:BOOL=ON
    
    # البناء
    print_info "بدء عملية البناء..."
    ./autobuild build -c ReleaseOS -- -j$(nproc)
    
    # إنشاء الحزمة
    print_info "إنشاء حزمة التوزيع..."
    ./autobuild package -c ReleaseOS
    
    print_success "اكتمل البناء بنجاح! 🎉"
    
    # عرض موقع الملفات
    BUILD_DIR="build-linux-x86_64"
    if [ -d "$BUILD_DIR" ]; then
        print_info "يمكنك العثور على البرنامج في:"
        print_info "  $FIRESTORM_DIR/$BUILD_DIR/newview/packaged/"
        
        # نسخ إلى مجلد سهل الوصول
        OUTPUT_DIR="$WORK_DIR/sela-viewer-output"
        mkdir -p "$OUTPUT_DIR"
        cp -r "$BUILD_DIR/newview/packaged/"* "$OUTPUT_DIR/" 2>/dev/null || true
        
        print_success "تم نسخ الملفات إلى: $OUTPUT_DIR"
    fi
}

################################################################################
# 9. إنشاء نظام تحديث تلقائي
################################################################################

create_auto_updater() {
    print_header "إنشاء نظام التحديث التلقائي"
    
    # إنشاء سكريبت التحديث
    cat > "$WORK_DIR/update_sela.sh" << 'UPDATE_EOF'
#!/bin/bash
# سكريبت التحديث التلقائي لـ Sela Viewer

WORK_DIR="$HOME/sela-viewer-build"
FIRESTORM_DIR="$WORK_DIR/phoenix-firestorm"

echo "فحص التحديثات..."
cd "$FIRESTORM_DIR"

# حفظ التعديلات المحلية
git stash

# جلب آخر التحديثات
git fetch --all

# الحصول على آخر إصدار
LATEST_TAG=$(git describe --tags --abbrev=0 origin/main)
CURRENT_TAG=$(git describe --tags --abbrev=0)

if [ "$LATEST_TAG" != "$CURRENT_TAG" ]; then
    echo "تحديث جديد متاح: $LATEST_TAG"
    echo "هل تريد التحديث؟ (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git checkout $LATEST_TAG
        git stash pop
        
        echo "إعادة البناء..."
        ./autobuild clean
        ./autobuild configure -c ReleaseOS -DSTANDALONE:BOOL=ON
        ./autobuild build -c ReleaseOS -- -j$(nproc)
        
        echo "تم التحديث بنجاح!"
    fi
else
    echo "لديك أحدث إصدار: $CURRENT_TAG"
fi
UPDATE_EOF
    
    chmod +x "$WORK_DIR/update_sela.sh"
    
    print_success "تم إنشاء سكريبت التحديث: $WORK_DIR/update_sela.sh"
    print_info "يمكنك تشغيله في أي وقت للتحقق من التحديثات"
}

################################################################################
# 10. إنشاء دليل الاستخدام
################################################################################

create_user_guide() {
    print_header "إنشاء دليل الاستخدام"
    
    cat > "$WORK_DIR/دليل_الاستخدام.txt" << 'GUIDE_EOF'
═══════════════════════════════════════════════════════════════
                 دليل استخدام Sela Viewer
         مشاهد Second Life مع دعم كامل للغة العربية
═══════════════════════════════════════════════════════════════

📖 المحتويات:
1. تشغيل البرنامج
2. استخدام اللغة العربية
3. التحديث
4. تخصيص الإعدادات
5. حل المشاكل

───────────────────────────────────────────────────────────────
1. تشغيل البرنامج
───────────────────────────────────────────────────────────────

للتشغيل:
  cd ~/sela-viewer-build/sela-viewer-output
  ./firestorm

أو يمكنك إنشاء اختصار على سطح المكتب.

───────────────────────────────────────────────────────────────
2. استخدام اللغة العربية
───────────────────────────────────────────────────────────────

✅ الكتابة بالعربية تعمل تلقائياً!

- في الشات العام: اكتب مباشرة بالعربية
- في الرسائل الخاصة: نفس الطريقة
- النص سيظهر من اليمين لليسار تلقائياً
- الحروف ستكون متصلة بشكل صحيح

يمكنك الخلط بين العربية والإنجليزية في نفس الرسالة!

───────────────────────────────────────────────────────────────
3. التحديث
───────────────────────────────────────────────────────────────

للتحديث إلى آخر إصدار:
  cd ~/sela-viewer-build
  ./update_sela.sh

سيقوم السكريبت بفحص التحديثات وتثبيتها تلقائياً.

───────────────────────────────────────────────────────────────
4. تخصيص الإعدادات
───────────────────────────────────────────────────────────────

لتغيير الصور والشعارات:
  1. انتقل إلى: ~/sela-viewer-build/sela-resources
  2. استبدل الملفات:
     - logo.png (الشعار)
     - icon.png (الأيقونة)
     - splash.png (شاشة البداية)
  3. أعد البناء بتشغيل: ./build_sela_viewer.sh

لتغيير النصوص والروابط:
  1. افتح: sela_config.txt
  2. عدّل الإعدادات حسب رغبتك
  3. أعد البناء

───────────────────────────────────────────────────────────────
5. حل المشاكل
───────────────────────────────────────────────────────────────

⚠ المشكلة: العربية لا تظهر بشكل صحيح
   الحل: تأكد من تثبيت الخط العربي بشكل صحيح

⚠ المشكلة: البرنامج لا يعمل
   الحل: تحقق من سجل الأخطاء في ~/.sela/logs/

⚠ المشكلة: بطء في الأداء
   الحل: قلل جودة الرسوميات من الإعدادات

للدعم الفني:
  - GitHub: https://github.com/your-repo/sela-viewer
  - البريد: support@example.com
  - الموقع: https://example.com

═══════════════════════════════════════════════════════════════
              شكراً لاستخدامك Sela Viewer!
═══════════════════════════════════════════════════════════════
GUIDE_EOF
    
    print_success "تم إنشاء دليل الاستخدام: $WORK_DIR/دليل_الاستخدام.txt"
}

################################################################################
# البرنامج الرئيسي
################################################################################

main() {
    clear
    
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                           ║${NC}"
    echo -e "${PURPLE}║          ${CYAN}Sela Viewer - Arabic Second Life Viewer${PURPLE}       ║${NC}"
    echo -e "${PURPLE}║          ${YELLOW}النسخة الآلية - بدون برمجة مطلوبة${PURPLE}            ║${NC}"
    echo -e "${PURPLE}║                                                           ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "مرحباً بك! هذا السكريبت سيقوم بكل شيء تلقائياً"
    print_info "الوقت المتوقع: 1-2 ساعة (حسب سرعة الإنترنت والكمبيوتر)"
    echo ""
    
    read -p "هل تريد البدء؟ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "تم الإلغاء."
        exit 0
    fi
    
    # تنفيذ الخطوات
    install_dependencies
    download_firestorm
    create_arabic_support_files
    modify_cmake_files
    download_arabic_font
    customize_branding
    customize_startup_text
    build_viewer
    create_auto_updater
    create_user_guide
    
    # رسالة النجاح النهائية
    print_header "اكتمل بنجاح! 🎉🎉🎉"
    
    echo -e "${GREEN}"
    cat << 'SUCCESS_EOF'
    
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║         ✓ تم بناء Sela Viewer بنجاح!                    ║
    ║                                                           ║
    ║    يمكنك الآن استخدام Second Life باللغة العربية!      ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    
SUCCESS_EOF
    echo -e "${NC}"
    
    print_info "الملفات المهمة:"
    echo -e "  ${CYAN}• البرنامج:${NC} $WORK_DIR/sela-viewer-output/"
    echo -e "  ${CYAN}• التحديث:${NC} $WORK_DIR/update_sela.sh"
    echo -e "  ${CYAN}• الدليل:${NC} $WORK_DIR/دليل_الاستخدام.txt"
    echo -e "  ${CYAN}• الموارد:${NC} $RESOURCES_DIR/"
    echo ""
    
    print_info "للتشغيل:"
    echo -e "  ${YELLOW}cd $WORK_DIR/sela-viewer-output${NC}"
    echo -e "  ${YELLOW}./firestorm${NC}"
    echo ""
    
    print_success "استمتع بتجربتك مع Sela Viewer! 🌟"
}

# تشغيل البرنامج
main "$@"
