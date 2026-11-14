TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

M7MD_FILES = dolphins.mm FloatView.mm OverlayView.mm mi.mm Bypass.mm KeySystem.mm ImageResources.mm

M7MD_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

M7MD_FRAMEWORKS = UIKit Foundation CoreGraphics Metal QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
