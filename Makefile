THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Unread
Unread_FILES = Unread.xm
Unread_FRAMEWORKS = UIKit
Unread_PRIVATE_FRAMEWORKS = ChatKit IMCore

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 backboardd"