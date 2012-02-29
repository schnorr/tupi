/*
    This file is part of Tupi

    Tupi is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Tupi is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Tupi.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __NTREE_H__
#define __NTREE_H__
#include <Foundation/Foundation.h>
#include "QuadTreeCellSpace.h"
#include "BarycenterCellData.h"

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
                          cellSpace: (QuadTreeCellSpace *)space
                           cellData: (BarycenterCellData *) data
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

#include "Cell.h"
#include "ParticleBox.h"
#endif
