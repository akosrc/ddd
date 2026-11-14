TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = M7MD

M7MD_FILES = Dolphins.mm FloatView.mm OverlayView.mm mi.mm Bypass.mm KeySystem.mm ImageResources.m

M7MD_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function -Wno-nontrivial-memcall -Wno-nonportable-include-path -I. -Iimgui -Iutils

M7MD_FRAMEWORKS = UIKit Foundation CoreGraphics Metal QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
