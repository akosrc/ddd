ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

# --- iOS 18.0 ve ÜZERİ İÇİN HEDEF AYARI ---
TARGET = iphone:clang:latest:18.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

# Frameworkler
M7MD_FRAMEWORKS = IOKit UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController WebKit

# Arama yolları
M7MD_CFLAGS += -I. -ISDK -I/opt/theos/include

# Derleyici ayarları
M7MD_CCFLAGS = -w -std=gnu++17 -fno-rtti -fno-exceptions -DNDEBUG -Wno-module-import-in-extern-c
M7MD_CFLAGS = -w -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value

# ÖNEMLİ DEĞİŞİKLİK: Dosyaları tek tek ve net bir şekilde tanımlıyoruz
M7MD_FILES = \
    Menux/*.mm \
    菜单/*.mm \
    View/*.mm \
    CustomView/*.m \
    utils/*.cpp \
    utils/*.m \
    imgui/*.mm \
    imgui/*.cpp \
    ESP/*.mm \
    ESP/*.cpp \
    SDK/*.cpp \
    NSURL+hook/*.m \
    MBProgressHUD/*.m \
    FCFileManager/*.m \
    NSEtcHosts/*.m \
    DBLOCKRASHID/*.m \
    ZXURLProtocol/*.m \
    EtcHostsURLProtocol/*.m \
    NSObject+URL/*.m \
    ViewController/*.m \
    ZXHttpIPGet/*.m \
    NSURLSession+ZXHttpProxy/*.m \
    main/*.m \
    旁路/*.mm \
    behaviorbypassforESP/*.h \
    Bypass.mm \
    JRMemory/MemScan.mm

include $(THEOS)/makefiles/tweak.mk
