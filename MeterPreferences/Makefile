TARGET= :clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = MeterPreferences
MeterPreferences_FILES = MeterPreferences.xm
MeterPreferences_INSTALL_PATH = /Library/PreferenceBundles
MeterPreferences_FRAMEWORKS = UIKit Twitter
MeterPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MeterPreferences.plist$(ECHO_END)
