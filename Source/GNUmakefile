include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = Tupi
APP_NAME = tupi

tupi_OBJC_FILES = \
	GraphNode.m \
	Tupi.m \
	FDView.m \
	main.m
tupi_RESOURCE_FILES = Tupi.gsmarkup

Tupi_OBJC_FILES = \
	Particle.m \
	Cell.m \
	ParticleBox.m \
	Layout.m \
	LayoutRunner.m \
	NTree.m \
	QuadTreeCellSpace.m \
	BarycenterCellData.m \
	Energy.m \
	BasicView.m

Tupi_HEADER_FILES = \
	Particle.h \
	Cell.h \
	ParticleBox.h \
	Layout.h \
	LayoutRunner.h \
	NTree.h \
	QuadTreeCellSpace.h \
	BarycenterCellData.h \
	Energy.h \
	BasicView.h \
	CellSpace.h \
	CellData.h \
	FDNode.h \
	TupiProtocols.h \
	Tupi.h

LDFLAGS=-L./Tupi.framework/Versions/Current/ 
ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance -framework Tupi -lgvc -lgraph
else
  ADDITIONAL_GUI_LIBS += -lRenaissance -lTupi -lgvc -lgraph
endif

include $(GNUSTEP_MAKEFILES)/framework.make
include $(GNUSTEP_MAKEFILES)/application.make