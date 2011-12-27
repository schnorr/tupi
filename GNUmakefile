include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = ForceDirected fd
ForceDirected_OBJC_FILES = \
	main.m \
	BasicView.m \
	ForceDirectedView.m \
	FDTree.m \
	GraphNode.m

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
ForceDirected_RESOURCE_FILES = ForceDirected.gsmarkup

ifeq ($(FOUNDATION_LIB), apple)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

ForceDirected_LDFLAGS += -lgvc
fd_LDFLAGS += -lgvc

include $(GNUSTEP_MAKEFILES)/application.make
