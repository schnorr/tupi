include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = ForceDirected
ForceDirected_OBJC_FILES = main.m DrawView.m
ForceDirected_RESOURCE_FILES = ForceDirected.gsmarkup

ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

ForceDirected_LDFLAGS += -lgvc

include $(GNUSTEP_MAKEFILES)/application.make
