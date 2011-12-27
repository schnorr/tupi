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
#ifndef __PARTICLEBOX_H__
#define __PARTICLEBOX_H__
#include <Foundation/Foundation.h>
#include "CellSpace.h"
#include "CellData.h"
#include "Cell.h"
#include "NTree.h"
#include "Particle.h"

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
                  cellSpace: (id<CellSpace>) space
                   cellData: (id<CellData>) data;
- (NSRect) boundingBox;
- (void) step; //one iteration
- (NSArray*) allParticles;
- (void) removeAllParticles;
- (void) addParticle: (Particle *)p;
- (void) removeParticle: (Particle *)p;
- (NTree*) tree;
@end

#endif
