GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

BUNDLE_NAME = indexprefs
indexprefs_FILES = $(wildcard *.mm) $(wildcard *.m)
indexprefs_INSTALL_PATH = /Library/PreferenceBundles
indexprefs_FRAMEWORKS = UIKit
indexprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/indexprefs.plist$(ECHO_END)
