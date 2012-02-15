include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = Tupi

Tupi_OBJC_FILES = \
	main.m \
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
	BasicView.m \
	Tupi.m

Tupi_RESOURCE_FILES = Tupi.gsmarkup

ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

Tupi_LDFLAGS += -lgvc

include $(GNUSTEP_MAKEFILES)/application.make
