THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 armv7s arm64
DEBUG = 1

include theos/makefiles/common.mk

TWEAK_NAME = Meter
Meter_FILES = Meter.xm
Meter_FRAMEWORKS = CoreFoundation UIKit CoreTelephony

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete
internal-after-install::
	install.exec "killall -9 backboardd"
