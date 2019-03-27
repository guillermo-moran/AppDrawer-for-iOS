export THEOS=/opt/theos

GO_EASY_ON_ME = 1

SDKVERSION = 9.3
SYSROOT = /opt/theos/sdks/iPhoneOS9.3.sdk


#THEOS_DEVICE_IP = 192.168.1.114
#THEOS_DEVICE_IP = 10.5.45.232
THEOS_DEVICE_IP = 192.168.1.100

#THEOS_DEVICE_PORT=2222

TWEAK_NAME = Index
Index_FILES = Tweak.xm
Index_FRAMEWORKS = UIKit CoreGraphics QuartzCore



SUBPROJECTS = indexprefs

BUNDLE_NAME = IndexBundle
IndexBundle_INSTALL_PATH = /Library/Application Support/AppDrawer


include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
