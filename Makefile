include theos/makefiles/common.mk

TWEAK_NAME = ControlFreak
ControlFreak_FILES = Tweak.xm iCPEvent.m
ControlFreak_FRAMEWORKS = UIKit
ControlFreak_PRIVATE_FRAMEWORKS = QuartzCore GraphicsServices
ControlFreak_LDFLAGS = -L./ -lhidsupport

include $(THEOS_MAKE_PATH)/tweak.mk
