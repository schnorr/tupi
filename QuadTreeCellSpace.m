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
#include "QuadTreeCellSpace.h"
#include "NSPointFunctions.h"

//this is a NSRect that knows how to divide itself in four quadrants
@implementation QuadTreeCellSpace
- (id) initWithBB: (NSRect) b
{
  self = [super init];
  bb = b;
  return self;
}

- (int) getDivisions
{
  return 4;
}

- (id) newSubCellSpace: (int) i
{
  QuadTreeCellSpace *ret = nil;
  double w = bb.size.width;
  double h = bb.size.height;
  switch (i){
  case 0:
    ret = [[QuadTreeCellSpace alloc] initWithBB:
                                       NSMakeRect (bb.origin.x,
                                                   bb.origin.y,
                                                   w/2,
                                                   h/2)];
    break;
  case 1:
    ret = [[QuadTreeCellSpace alloc] initWithBB:
                                       NSMakeRect (bb.origin.x + w/2,
                                                   bb.origin.y,
                                                   w/2,
                                                   h/2)];
    break;
  case 2:
    ret = [[QuadTreeCellSpace alloc] initWithBB:
                                       NSMakeRect (bb.origin.x,
                                                   bb.origin.y + h/2,
                                                   w/2,
                                                   h/2)];
    break;
  case 3:
    ret = [[QuadTreeCellSpace alloc] initWithBB:
                                       NSMakeRect (bb.origin.x + w/2,
                                                   bb.origin.y + h/2,
                                                   w/2,
                                                   h/2)];
    break;
  default: 
    [[NSException exceptionWithName: [self description]
                             reason: @"invalid sub division identifier provided"
                           userInfo: nil] raise];  
    break;
  }
  [ret autorelease];
  return ret;
}

- (BOOL) containsParticle: (Particle *) p
{
  return NSPointInRect ([p position], bb);
}

- (NSRect) bb
{
  return bb;
}

- (void) setBB: (NSRect) b
{
  bb = b;
}

- (double) size
{
  return LMSDiagonalRect (bb);
}
@end
