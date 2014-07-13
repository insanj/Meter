TARGET = :clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = MeterListener
MeterListener_FILES = MeterListener.xm
MeterListener_FRAMEWORKS = Foundation
MeterListener_LDFLAGS = -lactivator -L../theos/lib

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	find . -name ".DS_Store" -delete