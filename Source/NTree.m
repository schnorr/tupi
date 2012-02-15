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
#include "NTree.h"

static Cell *rootCell = nil;

@implementation NTree
- (id) init
{
  self = [super init];
  return self;
}

- (id) initRootTreeWithNodesPerCell: (int)max
                          cellSpace: (QuadTreeCellSpace*)space
                           cellData: (BarycenterCellData*) data
                        particleBox: (ParticleBox*) pb
{
  self = [super init];
  mode = Resize;
  particleBox = pb;
  numberOfParticlesPerCell = max;
  maxTreeDepth = 100;

  if (rootCell != nil){
    [[NSException exceptionWithName: [self description]
                             reason: @"rootCell is already defined"
                           userInfo: nil] raise];
  }else{
    rootCell = [[Cell alloc] initRootCellWithSpace: space cellData: data andNTree: self];
  }
  needResize = NO;
  return self;
}

- (void) dealloc
{
//  [rootCell release];
  [super dealloc];
}

- (NSRect) boundingBox
{
  return [rootCell boundingBox];
}

- (BOOL) isValid
{
  return [rootCell isValid];
}

- (void) checkDivisions
{
  if (needResize){
    QuadTreeCellSpace *space = [rootCell space];
    NSRect bb = [space bb];

    NSPoint min = minPointForResize;
    NSPoint max = maxPointForResize;
    NSRect minMaxRect = NSMakeRect (min.x,
                                    min.y,
                                    max.x - min.x,
                                    max.y - min.y);
    NSRect doubleRect = NSMakeRect (bb.origin.x - bb.size.width/2,
                                    bb.origin.y - bb.size.height/2,
                                    bb.size.width*2,
                                    bb.size.height*2);
    NSRect unionRect = NSUnionRect (doubleRect, minMaxRect);

    // //double the space
    // newBB.origin.x -= newBB.size.width;
    // newBB.origin.y -= newBB.size.height;
    // newBB.size.width *= 2;
    // newBB.size.height *= 2;

    // //a little larger
    // newBB.origin.x -= newBB.size.width*0.001;
    // newBB.origin.y -= newBB.size.height*0.001;
    // newBB.size.width += newBB.size.width*0.001;
    // newBB.size.height += newBB.size.height*0.001;
    
    [rootCell resizeToBoundingBox: unionRect]; //calls recompute
    needResize = NO;
  }else{
    [rootCell recompute];
  }

  if (![self isValid]){
    [[NSException exceptionWithName: [self description]
                             reason: @"tree not valid"
                           userInfo: nil] raise];
  }
}

- (void) resize: (Particle *) p
{
  NSPoint pos = [p position];

  if (pos.x > maxPointForResize.x) maxPointForResize.x = pos.x;
  else if (pos.x < minPointForResize.x) minPointForResize.x = pos.x;

  if (pos.y > maxPointForResize.y) maxPointForResize.y = pos.y;
  else if (pos.y < minPointForResize.y) minPointForResize.y = pos.y;

  needResize = YES;
}

- (void) delete: (Particle *) p
{
  [p suicide];
}

- (int) maxTreeDepth
{
  return maxTreeDepth;
}

- (int) numberOfParticlesPerCell
{
  return numberOfParticlesPerCell;
}

- (ParticleBox*) particleBox
{
  return particleBox;
}

- (void) handleOutParticle: (Particle *)p
{
  switch(mode){
  case Delete:
    [self delete: p];
    break;
  case Resize:
    [self resize: p];
    break;
  default:
    [[NSException exceptionWithName: [self description]
                             reason: @"unknown mode"
                           userInfo: nil] raise];
  }
}

- (void) addParticle: (Particle *)p
{
  if (![rootCell containsParticle: p]){
    [self handleOutParticle: p];
    [self checkDivisions];
    if (![rootCell containsParticle: p]){
      [[NSException exceptionWithName: [self description]
                               reason: @"even after handling out, new particle is not within the rootCell universe"
                             userInfo: nil] raise];
    }
  }

  [rootCell addParticle: p];
}

- (void) removeParticle: (Particle *)p
{
  Cell *cell = [p cell];
  if (cell != nil){
    [cell removeParticle: p];
  }
}

- (Cell*) rootCell
{
  return rootCell;
}
@end
