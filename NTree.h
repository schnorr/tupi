/*
    This file is part of ForceDirected

    ForceDirected is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ForceDirected is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ForceDirected.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __NTREE_H__
#define __NTREE_H__
#include <Foundation/Foundation.h>
#include "Cell.h"
#include "ParticleBox.h"
#include "QuadTreeCellSpace.h"

@class ParticleBox;
@class Cell;

enum OutOfUniverseMode {Delete, Resize};

@interface NTree : NSObject
{
  enum OutOfUniverseMode mode;
  ParticleBox *particleBox;
  int numberOfParticlesPerCell;
  int maxTreeDepth;

  BOOL needResize;
  NSPoint minPointForResize;
  NSPoint maxPointForResize;
}
- (id) initRootTreeWithNodesPerCell: (int)pmax
                          cellSpace: (id<CellSpace>)space
                           cellData: (id<CellData>) data
                        particleBox: (ParticleBox*) pb;
- (NSRect) boundingBox;
- (void) checkDivisions;
- (int) maxTreeDepth;
- (int) numberOfParticlesPerCell;
- (ParticleBox*) particleBox;
- (void) handleOutParticle: (Particle *)p;
- (void) addParticle: (Particle *)p;
- (void) removeParticle: (Particle *)p;
- (Cell*) rootCell;
@end

#endif
