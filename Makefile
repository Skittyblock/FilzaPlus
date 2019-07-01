PACKAGE_VERSION = 1.0-1
TARGET = iphone:clang::7.0
ARCHS = armv7 arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FilzaPlus
FilzaPlus_CFLAGS = -fobjc-arc
FilzaPlus_FILES = SSCodeString.m SSLayoutManager.m SSTextStorage.m SyntaxSelectorViewController.xm Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Filza"
