ARCHS = arm64
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = FreeFire

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FF_Panel_iOS
FF_Panel_iOS_FILES = Tweak.xm Menu.m
FF_Panel_iOS_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-nonportable-include-path
FF_Panel_iOS_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
