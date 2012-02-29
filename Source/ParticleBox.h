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
#ifndef __PARTICLEBOX_H__
#define __PARTICLEBOX_H__
#include <Foundation/Foundation.h>
#include "Cell.h"
#include "Particle.h"
#include "QuadTreeCellSpace.h"
#include "BarycenterCellData.h"

@class NTree;
@class Cell;
@class Particle;

@interface ParticleBox : NSObject
{
  NSMutableDictionary *particles;
  NTree *tree;
  long time; //current time step
}
- (id) initWithNodesPerCell: (int)pmax
                  cellSpace: (QuadTreeCellSpace *) space
                   cellData: (BarycenterCellData *) data;
- (NSRect) boundingBox;
- (void) step; //one iteration
- (NSArray*) allParticles;
- (void) removeAllParticles;
- (void) addParticle: (Particle *)p;
- (void) removeParticle: (Particle *)p;
- (NTree*) tree;

- (void) shake;
@end

#endif
