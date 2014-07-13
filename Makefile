THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 armv7s arm64
DEBUG = 1

include theos/makefiles/common.mk

TWEAK_NAME = Meter
Meter_FILES = Meter.xm MeterListener.xm
Meter_FRAMEWORKS = CoreFoundation UIKit
Meter_LDFLAGS = -lactivator -Ltheos/lib

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-stage::
	find . -name ".DS_Store" -delete
internal-after-install::
	install.exec "killall -9 backboardd"
