TWEAK_NAME = WitchAccounts
WitchAccounts_FILES = Tweak.xm
WitchAccounts_FRAMEWORKS = Foundation UIKit
WitchAccounts_CFLAGS = -fobjc-arc

ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk