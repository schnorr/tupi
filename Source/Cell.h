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
#ifndef __CELL_H__
#define __CELL_H__
#include <Foundation/Foundation.h>
#include "QuadTreeCellSpace.h"
#include "BarycenterCellData.h"
#include "Particle.h"
#include "NTree.h"

@class NTree;
@class Particle;
@class QuadTreeCellSpace;
@class BarycenterCellData;

@interface Cell : NSObject
{
  Cell *parent;
  NSMutableArray *sub;
  int depth;
  int index;

  QuadTreeCellSpace *space;
  BarycenterCellData *data;
  NTree *tree;

  NSMutableArray *particles;
  int population;
}
- (id) initRootCellWithSpace: (QuadTreeCellSpace*)sp
                    cellData: (BarycenterCellData*) d
                    andNTree: (NTree*) t;
- (id) initChildCell: (int) index
           WithSpace: (QuadTreeCellSpace*)sp
            cellData: (BarycenterCellData*) d
            andNTree: (NTree*) t
            parent: (Cell*)p;
- (int) depth;
- (NSRect) boundingBox;
- (QuadTreeCellSpace*) space;
- (BarycenterCellData*) data;

- (int) population;
- (BOOL) isLeaf;
- (NSArray*) particles;
- (NSArray*) divisions;
- (BOOL) hasParticle: (Particle *) p;
- (BOOL) containsParticle: (Particle *) p;
- (void) moveParticle: (Particle *) p;
- (void) removeParticle: (Particle *) p;
- (void) addParticle: (Particle *) p;
- (void) recompute;
- (void) mitosis;
- (void) fusion;
- (void) resizeToBoundingBox: (NSRect) newBB;
- (BOOL) isValid;
@end
#endif
