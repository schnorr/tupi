include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = fd

fd_OBJC_FILES = \
	fd.m \
	GraphNode.m \
	Particle.m \
	Cell.m \
	ParticleBox.m \
	Layout.m \
	LayoutRunner.m \
	NTree.m \
	QuadTreeCellSpace.m \
	BarycenterCellData.m \
	Energy.m \
	FDView.m \
	BasicView.m

fd_RESOURCE_FILES = fd.gsmarkup

ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

fd_LDFLAGS += -lgvc

include $(GNUSTEP_MAKEFILES)/application.make
