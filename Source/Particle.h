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
#ifndef __PARTICLE_H__
#define __PARTICLE_H__
#include <Foundation/Foundation.h>
#include "Cell.h"
#include "Layout.h"
#include "FDNode.h"

@class Cell;
@class Layout;
@class ParticleBox;

@interface Particle : NSObject
{
  NSString *name; //the unique identifier

  NSPoint pos;
  Cell *cell;
  Layout *layout;
  ParticleBox *box;

  @private
  BOOL frozen;
  NSPoint disp; // Displacement vector.
  double len; // Last computed displacement vector length.
  double attE; // Attraction energy for this node only.
  double repE; // Repulsion energy for this node only.
  double weight; //the particle importance

  //this particle represents a graph node
  id<FDNode> graphNode;
}
- (id) initForGraphNode: (id<FDNode>) gn
               WithName: (NSString *)n
             WithLayout: (Layout*)pb
         andParticleBox: (ParticleBox*) b;
- (NSString*)name;
- (double) weight;
- (BOOL) closeTo: (Particle *) p;
- (NSPoint) position;
- (void) setPosition: (NSPoint) newPosition;
- (Cell *) cell;
- (void) setCell: (Cell *) c;
- (ParticleBox *) box;
- (void) setParticleBox: (ParticleBox *) b;
- (void) suicide;
- (void) inserted;
- (void) removed;

// Force-directed operations
- (void) move: (long) time;
- (void) nextStep: (long) time;
@end
#endif
