include theos/makefiles/common.mk

TWEAK_NAME = ControlFreak
ControlFreak_FILES = Tweak.xm UIEvent+Synthesize.m UITouch+Synthesize.m
ControlFreak_FRAMEWORKS = UIKit
ControlFreak_PRIVATE_FRAMEWORKS = QuartzCore GraphicsServices CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
