#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sela Viewer Configuration Tool
أداة تخصيص Sela Viewer - واجهة رسومية بسيطة
لا تحتاج لأي معرفة برمجية!
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import os
import json
from pathlib import Path

class SelaConfigTool:
    def __init__(self, root):
        self.root = root
        self.root.title("Sela Viewer - أداة التخصيص")
        self.root.geometry("800x900")
        self.root.resizable(True, True)
        
        # المسارات
        self.home = str(Path.home())
        self.work_dir = os.path.join(self.home, "sela-viewer-build")
        self.resources_dir = os.path.join(self.work_dir, "sela-resources")
        self.config_file = os.path.join(self.resources_dir, "sela_config.json")
        
        # إنشاء المجلدات إذا لم تكن موجودة
        os.makedirs(self.resources_dir, exist_ok=True)
        
        # البيانات
        self.config = self.load_config()
        
        # إنشاء الواجهة
        self.create_widgets()
        
        # تحميل البيانات
        self.load_ui_data()
        
    def load_config(self):
        """تحميل الإعدادات من الملف"""
        default_config = {
            "viewer_name": "Sela Viewer",
            "viewer_short_name": "Sela",
            "version": "1.0.0",
            "website": "https://example.com",
            "support_email": "support@example.com",
            "support_text": "للدعم الفني: support@example.com",
            "welcome_text": "مرحباً بك في Sela Viewer - مشاهد Second Life بدعم اللغة العربية",
            "logo_path": "",
            "icon_path": "",
            "splash_path": ""
        }
        
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    loaded_config = json.load(f)
                    default_config.update(loaded_config)
            except:
                pass
        
        return default_config
    
    def save_config(self):
        """حفظ الإعدادات"""
        with open(self.config_file, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, ensure_ascii=False, indent=4)
    
    def create_widgets(self):
        """إنشاء عناصر الواجهة"""
        
        # إطار التمرير
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # العنوان
        title = ttk.Label(main_frame, 
                         text="🌟 Sela Viewer - أداة التخصيص 🌟",
                         font=('Arial', 16, 'bold'))
        title.grid(row=0, column=0, columnspan=3, pady=10)
        
        subtitle = ttk.Label(main_frame,
                            text="خصص برنامجك بكل سهولة - بدون أي برمجة!",
                            font=('Arial', 10))
        subtitle.grid(row=1, column=0, columnspan=3, pady=5)
        
        # فاصل
        ttk.Separator(main_frame, orient='horizontal').grid(
            row=2, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        
        current_row = 3
        
        # ═══════════════════════════════════════════════
        # قسم المعلومات الأساسية
        # ═══════════════════════════════════════════════
        section1 = ttk.LabelFrame(main_frame, text="📝 المعلومات الأساسية", padding="10")
        section1.grid(row=current_row, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        current_row += 1
        
        # اسم البرنامج
        ttk.Label(section1, text="اسم البرنامج:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.viewer_name_entry = ttk.Entry(section1, width=40)
        self.viewer_name_entry.grid(row=0, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # اسم مختصر
        ttk.Label(section1, text="الاسم المختصر:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.short_name_entry = ttk.Entry(section1, width=40)
        self.short_name_entry.grid(row=1, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # رقم الإصدار
        ttk.Label(section1, text="رقم الإصدار:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.version_entry = ttk.Entry(section1, width=40)
        self.version_entry.grid(row=2, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # ═══════════════════════════════════════════════
        # قسم معلومات الاتصال
        # ═══════════════════════════════════════════════
        section2 = ttk.LabelFrame(main_frame, text="🌐 معلومات الاتصال", padding="10")
        section2.grid(row=current_row, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        current_row += 1
        
        # الموقع
        ttk.Label(section2, text="الموقع الإلكتروني:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.website_entry = ttk.Entry(section2, width=40)
        self.website_entry.grid(row=0, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # البريد الإلكتروني
        ttk.Label(section2, text="البريد الإلكتروني:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.email_entry = ttk.Entry(section2, width=40)
        self.email_entry.grid(row=1, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # نص الدعم
        ttk.Label(section2, text="نص الدعم الفني:").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.support_entry = ttk.Entry(section2, width=40)
        self.support_entry.grid(row=2, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # ═══════════════════════════════════════════════
        # قسم النصوص
        # ═══════════════════════════════════════════════
        section3 = ttk.LabelFrame(main_frame, text="💬 النصوص المخصصة", padding="10")
        section3.grid(row=current_row, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        current_row += 1
        
        # نص الترحيب
        ttk.Label(section3, text="نص الترحيب:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.welcome_text = scrolledtext.ScrolledText(section3, width=50, height=4, wrap=tk.WORD)
        self.welcome_text.grid(row=0, column=1, columnspan=2, sticky=(tk.W, tk.E), pady=5, padx=5)
        
        # ═══════════════════════════════════════════════
        # قسم الصور
        # ═══════════════════════════════════════════════
        section4 = ttk.LabelFrame(main_frame, text="🖼️ الصور والشعارات", padding="10")
        section4.grid(row=current_row, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        current_row += 1
        
        # الشعار
        ttk.Label(section4, text="الشعار (512x512):").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.logo_label = ttk.Label(section4, text="لم يتم اختيار ملف", foreground="gray")
        self.logo_label.grid(row=0, column=1, sticky=tk.W, pady=5, padx=5)
        ttk.Button(section4, text="اختر ملف", command=self.choose_logo).grid(row=0, column=2, pady=5)
        
        # الأيقونة
        ttk.Label(section4, text="الأيقونة (256x256):").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.icon_label = ttk.Label(section4, text="لم يتم اختيار ملف", foreground="gray")
        self.icon_label.grid(row=1, column=1, sticky=tk.W, pady=5, padx=5)
        ttk.Button(section4, text="اختر ملف", command=self.choose_icon).grid(row=1, column=2, pady=5)
        
        # شاشة البداية
        ttk.Label(section4, text="شاشة البداية (600x400):").grid(row=2, column=0, sticky=tk.W, pady=5)
        self.splash_label = ttk.Label(section4, text="لم يتم اختيار ملف", foreground="gray")
        self.splash_label.grid(row=2, column=1, sticky=tk.W, pady=5, padx=5)
        ttk.Button(section4, text="اختر ملف", command=self.choose_splash).grid(row=2, column=2, pady=5)
        
        # ملاحظة
        note = ttk.Label(section4, 
                        text="💡 يمكنك استخدام ملفات PNG أو JPG",
                        foreground="blue",
                        font=('Arial', 9, 'italic'))
        note.grid(row=3, column=0, columnspan=3, pady=5)
        
        # ═══════════════════════════════════════════════
        # أزرار التحكم
        # ═══════════════════════════════════════════════
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=current_row, column=0, columnspan=3, pady=20)
        
        ttk.Button(button_frame, text="💾 حفظ الإعدادات", 
                  command=self.save_settings,
                  style='Accent.TButton').pack(side=tk.LEFT, padx=5)
        
        ttk.Button(button_frame, text="🔄 إعادة تعيين", 
                  command=self.reset_settings).pack(side=tk.LEFT, padx=5)
        
        ttk.Button(button_frame, text="🚀 بناء Sela Viewer", 
                  command=self.build_viewer,
                  style='Accent.TButton').pack(side=tk.LEFT, padx=5)
        
        ttk.Button(button_frame, text="❓ مساعدة", 
                  command=self.show_help).pack(side=tk.LEFT, padx=5)
        
        # ═══════════════════════════════════════════════
        # شريط الحالة
        # ═══════════════════════════════════════════════
        self.status_label = ttk.Label(main_frame, text="جاهز", relief=tk.SUNKEN)
        self.status_label.grid(row=current_row+1, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=5)
        
        # تكوين الشبكة للتوسع
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
    
    def load_ui_data(self):
        """تحميل البيانات إلى الواجهة"""
        self.viewer_name_entry.insert(0, self.config["viewer_name"])
        self.short_name_entry.insert(0, self.config["viewer_short_name"])
        self.version_entry.insert(0, self.config["version"])
        self.website_entry.insert(0, self.config["website"])
        self.email_entry.insert(0, self.config["support_email"])
        self.support_entry.insert(0, self.config["support_text"])
        self.welcome_text.insert('1.0', self.config["welcome_text"])
        
        # تحديث تسميات الملفات
        if self.config["logo_path"]:
            self.logo_label.config(text=os.path.basename(self.config["logo_path"]), foreground="green")
        if self.config["icon_path"]:
            self.icon_label.config(text=os.path.basename(self.config["icon_path"]), foreground="green")
        if self.config["splash_path"]:
            self.splash_label.config(text=os.path.basename(self.config["splash_path"]), foreground="green")
    
    def choose_logo(self):
        """اختيار ملف الشعار"""
        filename = filedialog.askopenfilename(
            title="اختر ملف الشعار",
            filetypes=[("ملفات الصور", "*.png *.jpg *.jpeg"), ("جميع الملفات", "*.*")]
        )
        if filename:
            self.config["logo_path"] = filename
            self.logo_label.config(text=os.path.basename(filename), foreground="green")
            self.update_status("تم اختيار الشعار: " + os.path.basename(filename))
    
    def choose_icon(self):
        """اختيار ملف الأيقونة"""
        filename = filedialog.askopenfilename(
            title="اختر ملف الأيقونة",
            filetypes=[("ملفات الصور", "*.png *.jpg *.jpeg"), ("جميع الملفات", "*.*")]
        )
        if filename:
            self.config["icon_path"] = filename
            self.icon_label.config(text=os.path.basename(filename), foreground="green")
            self.update_status("تم اختيار الأيقونة: " + os.path.basename(filename))
    
    def choose_splash(self):
        """اختيار ملف شاشة البداية"""
        filename = filedialog.askopenfilename(
            title="اختر ملف شاشة البداية",
            filetypes=[("ملفات الصور", "*.png *.jpg *.jpeg"), ("جميع الملفات", "*.*")]
        )
        if filename:
            self.config["splash_path"] = filename
            self.splash_label.config(text=os.path.basename(filename), foreground="green")
            self.update_status("تم اختيار شاشة البداية: " + os.path.basename(filename))
    
    def save_settings(self):
        """حفظ الإعدادات"""
        try:
            # تحديث البيانات من الواجهة
            self.config["viewer_name"] = self.viewer_name_entry.get()
            self.config["viewer_short_name"] = self.short_name_entry.get()
            self.config["version"] = self.version_entry.get()
            self.config["website"] = self.website_entry.get()
            self.config["support_email"] = self.email_entry.get()
            self.config["support_text"] = self.support_entry.get()
            self.config["welcome_text"] = self.welcome_text.get('1.0', tk.END).strip()
            
            # حفظ
            self.save_config()
            
            # نسخ الصور إلى مجلد الموارد
            if self.config["logo_path"]:
                import shutil
                shutil.copy2(self.config["logo_path"], 
                           os.path.join(self.resources_dir, "logo.png"))
            
            if self.config["icon_path"]:
                import shutil
                shutil.copy2(self.config["icon_path"], 
                           os.path.join(self.resources_dir, "icon.png"))
            
            if self.config["splash_path"]:
                import shutil
                shutil.copy2(self.config["splash_path"], 
                           os.path.join(self.resources_dir, "splash.png"))
            
            self.update_status("✓ تم حفظ الإعدادات بنجاح!")
            messagebox.showinfo("نجاح", "تم حفظ الإعدادات بنجاح!")
            
        except Exception as e:
            self.update_status("✗ خطأ في الحفظ: " + str(e))
            messagebox.showerror("خطأ", f"فشل حفظ الإعدادات:\n{str(e)}")
    
    def reset_settings(self):
        """إعادة تعيين الإعدادات"""
        if messagebox.askyesno("تأكيد", "هل تريد إعادة تعيين جميع الإعدادات للقيم الافتراضية؟"):
            self.config = self.load_config()
            
            # مسح الحقول
            self.viewer_name_entry.delete(0, tk.END)
            self.short_name_entry.delete(0, tk.END)
            self.version_entry.delete(0, tk.END)
            self.website_entry.delete(0, tk.END)
            self.email_entry.delete(0, tk.END)
            self.support_entry.delete(0, tk.END)
            self.welcome_text.delete('1.0', tk.END)
            
            # إعادة التحميل
            self.load_ui_data()
            
            self.update_status("تم إعادة تعيين الإعدادات")
    
    def build_viewer(self):
        """بناء Sela Viewer"""
        # حفظ الإعدادات أولاً
        self.save_settings()
        
        # التحقق من وجود سكريبت البناء
        build_script = os.path.join(self.work_dir, "build_sela_viewer.sh")
        
        if not os.path.exists(build_script):
            messagebox.showerror("خطأ", 
                               f"سكريبت البناء غير موجود:\n{build_script}\n\n"
                               "يرجى التأكد من تشغيل السكريبت الرئيسي أولاً.")
            return
        
        # تأكيد البناء
        if messagebox.askyesno("تأكيد البناء", 
                              "سيتم الآن بناء Sela Viewer.\n"
                              "هذه العملية قد تستغرق 30-60 دقيقة.\n\n"
                              "هل تريد المتابعة؟"):
            
            self.update_status("جاري بناء Sela Viewer...")
            
            # فتح نافذة الطرفية لعرض التقدم
            import subprocess
            
            try:
                if os.name == 'posix':  # Linux/Mac
                    subprocess.Popen(['x-terminal-emulator', '-e', f'bash {build_script}'])
                else:
                    subprocess.Popen(['cmd', '/c', 'start', build_script])
                
                messagebox.showinfo("تم البدء", 
                                   "تم بدء عملية البناء في نافذة طرفية جديدة.\n"
                                   "يمكنك متابعة التقدم من هناك.")
                
            except Exception as e:
                messagebox.showerror("خطأ", f"فشل تشغيل سكريبت البناء:\n{str(e)}")
    
    def show_help(self):
        """عرض المساعدة"""
        help_text = """
═══════════════════════════════════════════════
        مساعدة Sela Viewer
═══════════════════════════════════════════════

📝 كيفية الاستخدام:

1. املأ جميع الحقول بمعلوماتك
2. اختر الصور (الشعار، الأيقونة، شاشة البداية)
3. اضغط "حفظ الإعدادات"
4. اضغط "بناء Sela Viewer"
5. انتظر حتى انتهاء البناء (30-60 دقيقة)

💡 نصائح:

• استخدم صور بجودة عالية للحصول على أفضل نتيجة
• تأكد من صحة الروابط والبريد الإلكتروني
• يمكنك تغيير الإعدادات وإعادة البناء في أي وقت

🔧 متطلبات الصور:

• الشعار: 512x512 بكسل (PNG/JPG)
• الأيقونة: 256x256 بكسل (PNG/JPG)  
• شاشة البداية: 600x400 بكسل (PNG/JPG)

📞 للدعم:

إذا واجهت أي مشاكل، يمكنك:
• مراجعة دليل الاستخدام
• التواصل عبر GitHub
• إرسال بريد إلكتروني للدعم

═══════════════════════════════════════════════
        """
        
        help_window = tk.Toplevel(self.root)
        help_window.title("المساعدة")
        help_window.geometry("600x500")
        
        text_widget = scrolledtext.ScrolledText(help_window, wrap=tk.WORD, 
                                                font=('Courier', 10))
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert('1.0', help_text)
        text_widget.config(state=tk.DISABLED)
        
        ttk.Button(help_window, text="إغلاق", 
                  command=help_window.destroy).pack(pady=10)
    
    def update_status(self, message):
        """تحديث شريط الحالة"""
        self.status_label.config(text=message)
        self.root.update_idletasks()

def main():
    root = tk.Tk()
    app = SelaConfigTool(root)
    root.mainloop()

if __name__ == "__main__":
    main()
