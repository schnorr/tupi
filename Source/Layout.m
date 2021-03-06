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
#include "Layout.h"
#include "NSPointFunctions.h"

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
  area = NSZeroRect;
  diagonalOfArea = 0;
  maxMoveLength = 0;
  averageLength = 0;
  numberOfMovedNodes = 0;

  stabilizationLimit = 0.9;

  QuadTreeCellSpace *space = [[QuadTreeCellSpace alloc] initWithBB: NSMakeRect(-10, -10, 20, 20)];
  BarycenterCellData *data = [[BarycenterCellData alloc] init];
  mainBox = [[ParticleBox alloc] initWithNodesPerCell: nodesPerCell
                                            cellSpace: space
                                             cellData: data];
  energy = [[Energy alloc] init];
  [self setQuality: quality];

  lock = [[NSConditionLock alloc] initWithCondition: 0];
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
}

- (double) force
{
  return force;
}

- (void) setForce: (double) f
{
  force = f;
}

- (void) compute
{
  [lock lock];

  area = [mainBox boundingBox];
  diagonalOfArea = LMSDiagonalRect (area);
  maxMoveLength = -MAXFLOAT;
  k = 1.0;

  numberOfMovedNodes = 0;
  averageLength = 0;

  [mainBox step];

  if (numberOfMovedNodes > 0)
    averageLength /= numberOfMovedNodes;

  // Ready for the next step.
  [energy store];
  time++;

  [lock unlock];
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

- (void) freezeNode: (id<FDNode>) node frozen: (BOOL) fr
{
  [lock lock];
  Particle *p = [node particle];
  [p setFreeze: fr];
  [lock unlock];
}

- (void) removeNode: (id<FDNode>) node
{
  [lock lock];
  Particle *p = [node particle];
  [mainBox removeParticle: p];

  [energy clear];
  [lock unlock];
}

- (void) addNode: (id<FDNode>) node withName: (NSString *) nodeName
{
  [lock lock];
  Particle *p = [[Particle alloc] initForGraphNode: node
                                          withName: nodeName
                                        withLayout: self
                                    andParticleBox: mainBox];
  [mainBox addParticle: p];
  [node setParticle: p];
  [p release];

  [energy clear];
  [lock unlock];
}

- (void) addNode: (id<FDNode>) node withName: (NSString *) nodeName withLocation: (NSPoint) loc
{
  [lock lock];
  Particle *p = [[Particle alloc] initForGraphNode: node
                                          withName: nodeName
                                      withLocation: loc
                                        withLayout: self
                                    andParticleBox: mainBox];
  [mainBox addParticle: p];
  [node setParticle: p];
  [p release];

  [energy clear];
  [lock unlock];
}

- (void) moveNode: (id<FDNode>) node toLocation: (NSPoint) loc
{
  //remove the corresponding particle from the layout
  [self removeNode: node];

  //add the particle again, forcing it to the new location
  [self addNode: node
         withName: [node name]
     withLocation: loc];

  //freeze the particle that was just added
  [self freezeNode: node frozen: YES];
}

- (void) list
{
  NSLog (@"There are %lu particles:", [[self allParticles] count]);
  NSEnumerator *en = [[self allParticles] objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    NSLog (@"%@ connected to %@", [p name], [p->graphNode connectedNodes]);
  }
}

- (void) shake
{
  [mainBox shake];
  [energy clear];
}

- (void) clear
{
  [energy clear];
  [mainBox removeAllParticles];
}

@end
