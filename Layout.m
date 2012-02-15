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
#include "Layout.h"
#include "NSPointFunctions.h"

double gettime ();

#ifndef MAXFLOAT
#define MAXFLOAT ((float)3.402823466e+38F)
#endif

@implementation Layout
- (id) init
{
  self = [super init];

  k = 1.0;
  K1 = 0.06;
  K2 = 0.024;
  force = 1.0;
  //viewZone = 5.0; calculated by the quality level
  theta = 0.7;
  quality = 1;
  nodesPerCell = 10;

  time = 0;
  lastStepDuration = 0;
  area = NSZeroRect;
  diagonalOfArea = 0;
  maxMoveLength = 0;
  averageLength = 0;
  numberOfMovedNodes = 0;

  stabilizationLimit = 0.9;

  id<CellSpace> space;
  id<CellData> data;
  space = [[QuadTreeCellSpace alloc] initWithBB: NSMakeRect(-10, -10, 20, 20)];
  data = [[BarycenterCellData alloc] init];
  mainBox = [[ParticleBox alloc] initWithNodesPerCell: nodesPerCell
                                            cellSpace: space
                                             cellData: data];
  energy = [[Energy alloc] init];
  [self setQuality: quality];
  return self;
}

- (long) numberOfMovedNodes
{
  return numberOfMovedNodes;
}

- (double) stabilization
{
  return [energy stabilization];
}

- (double) stabilizationLimit
{
  return stabilizationLimit;
}

- (NSTimeInterval) lastStepDuration
{
  return lastStepDuration;
}

- (int) quality
{
  return quality;
}

- (void) setQuality: (int) q
{
  //viewZone depends on the quality
  quality = q;

  switch (quality) {
  case 0: viewZone = k; break;
  case 1: viewZone = 2 * k; break;
  case 2: viewZone = 5 * k; break;
  case 3: viewZone = 10 * k; break;
  case 4: viewZone = -1; break; //N2 algorithm
  default: viewZone = k; break;
  }
  NSLog (@"quality set to %d, viewZone calculated to %f", quality, viewZone);
}

- (double) force
{
  return force;
}

- (void) setForce: (double) f
{
  force = f;
}

- (void) moveNode: (NSString*) id toLocation: (NSPoint) newLocation
{

}


- (void) freezeNode: (NSString*) id to: (BOOL) frozen
{

}

- (void) shake
{
}


- (void) clear
{
}

- (void) compute
{
  area = [mainBox boundingBox];
  diagonalOfArea = LMSDiagonalRect (area);
  maxMoveLength = -MAXFLOAT;
  k = 1.0;

  numberOfMovedNodes = 0;
  averageLength = 0;

  double t1 = gettime();
  [mainBox step];
  double t2 = gettime();

  if (numberOfMovedNodes > 0)
    averageLength /= numberOfMovedNodes;

  // Ready for the next step.
  [energy store];
  lastStepDuration = t2 - t1;
  time++;
}

- (void) setProvider: (id) prov
{
  provider = prov;
}

- (NSArray *)allParticles
{
  return [mainBox allParticles];
}

- (NSRect) boundingBox
{
  return [[[mainBox tree] rootCell] boundingBox];
}

- (Cell *)rootCell
{
  return [[mainBox tree] rootCell];
}

- (Energy*) energy
{
  return energy;
}

- (void) addNode: (GraphNode*) node withName: (NSString *) nodeName
{
  Particle *p = [[Particle alloc] initForGraphNode: node
                                          WithName: nodeName
                                        WithLayout: self
                                    andParticleBox: mainBox];
  [node setParticle: p];
  [mainBox addParticle: p];
  [p release];

}
@end
