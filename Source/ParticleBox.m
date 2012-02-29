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
#include "ParticleBox.h"

extern double gettime();

@implementation ParticleBox
- (id) init
{
  self = [super init];
  return self;
}

- (id) initWithNodesPerCell: (int)pmax
                  cellSpace: (QuadTreeCellSpace *) space
                   cellData: (BarycenterCellData *) data
{
  self = [super init];
  tree = [[NTree alloc] initRootTreeWithNodesPerCell:pmax
                                           cellSpace:space
                                            cellData:data
                                         particleBox:self];
  particles = [[NSMutableDictionary alloc] init];
  return self;
}

- (void) dealloc
{
  [tree release];
  [particles release];
  [super dealloc];
}

- (NSRect) boundingBox
{
  return [tree boundingBox];
}

- (void) step
{
  NSEnumerator *en;
  Particle *p;
  BOOL debug = NO;
  double tt1, tt2;

  if (debug){
    tt1 = gettime();
  }

  //this is the most expensive operation
  en = [particles objectEnumerator];
  while ((p = [en nextObject])){
    [p move: time];
  }

  if (debug){
    tt2 = gettime();
    NSLog (@"\t%s: time elapsed: %f per_particle = %f", "Move",
           tt2-tt1, (tt2-tt1)/[particles count]);
    tt1 = gettime();
  }

  en = [particles objectEnumerator];
  while ((p = [en nextObject])){
    [p nextStep: time];
  }

  if (debug){
    tt2 = gettime();
    NSLog (@"\t%s: time elapsed: %f per_particle = %f", "nextStep", tt2-tt1, (tt2-tt1)/[particles count]);
    tt1 = gettime();
  }

  [tree checkDivisions];

  if (debug){
    tt2 = gettime();
    NSLog (@"\t%s: time elapsed: %f", "checkDivisions", tt2-tt1);
  }

  time++;
}

- (NSArray*) allParticles
{
  return [particles allValues];
}

- (void) removeAllParticles
{
  NSEnumerator *en = [particles objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    Cell *cell = [p cell];
    if (cell == nil){
      [[NSException exceptionWithName: [self description]
                               reason: @"removing a particle that is not in the tree, it has no cell"
                             userInfo: nil] raise]; 
    }

    [tree removeParticle: p];
    
    if ([cell hasParticle: p]){
      [[NSException exceptionWithName: [self description]
                               reason: @"the cell from which the particle was removed still contains the particle"
                             userInfo: nil] raise]; 
    }
    [p setParticleBox: nil];
  }
  [particles removeAllObjects];
}

- (void) addParticle: (Particle *)p
{
  if ([particles objectForKey: [p description]]){
    [[NSException exceptionWithName: [self description]
                               reason: @"a particle with the same identifier already exists"
                             userInfo: nil] raise]; 
  }
  [tree addParticle: p]; 
  [particles setObject: p forKey: [p description]];
  [p setParticleBox: self];
  [p inserted];
}

- (void) removeParticle: (Particle *)p
{
  Particle *pRemoved = [particles objectForKey: [p description]];
  if (pRemoved != p){
    [[NSException exceptionWithName: [self description]
                             reason: @"removed particle not the same that was asked to remove"
                           userInfo: nil] raise]; 
  }
  if (pRemoved != nil){
    [tree removeParticle: pRemoved];
    [pRemoved setParticleBox: nil];
    [pRemoved setCell: nil];
    [particles removeObjectForKey: [p description]];
    [pRemoved removed];
  }
}

- (NTree*) tree
{
  return tree;
}

- (void) shake
{
  NSEnumerator *en = [particles objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    [p shake];
  }
}
@end
