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
#include "Cell.h"

@implementation Cell
- (id) init
{
  self = [super init];
  return self;
}

- (id) initRootCellWithSpace: (QuadTreeCellSpace*)sp
                    cellData: (BarycenterCellData*) d
                    andNTree: (NTree*) t
{
  self = [super init];
  parent = nil;
  sub = nil;
  depth = 0;
  index = -1;

  space = sp;
  data = d;
  tree = t;

  [space retain];
  [data retain];

  [data setCell: self];

  particles = [[NSMutableArray alloc] init];
  population = 0;
  return self;
}

- (id) initChildCell: (int) i
           WithSpace: (QuadTreeCellSpace*)sp
            cellData: (BarycenterCellData*) d
            andNTree: (NTree*) t
              parent: (Cell*)p
{
  self = [super init];
  parent = p;
  sub = nil;
  depth = [parent depth] + 1;
  index = i;

  space = sp;
  data = d;
  tree = t;

  [space retain];
  [data retain];

  [data setCell: self];

  particles = [[NSMutableArray alloc] init];
  population = 0;
  return self;
}

- (void) dealloc
{
  [sub release];
  [particles release];
  [space release];
  [data release];
  [super dealloc];
}

- (int) depth
{
  return depth;
}

- (NSRect) boundingBox
{
  return [space bb];
}

- (id<CellSpace>) space
{
  return space;
}

- (id<CellData>) data
{
  return data;
}

- (int) population
{
  return population;
}

- (BOOL) isLeaf
{
  return sub == nil;
}

- (BOOL) isRoot
{
  return parent == nil;
}

- (NSArray*) particles
{
  return particles;
}

- (BOOL) hasParticle: (Particle *) p
{
  return [particles containsObject: p];
}

- (BOOL) containsParticle: (Particle *) p
{
  return [space containsParticle: p];
}

- (void) moveParticle: (Particle *) p
{
  // If it moved out of me, reposition it.

  if (![self isLeaf]){
    [[NSException exceptionWithName: [self description]
                             reason: @"particle moved event in non-leaf cell"
                           userInfo: nil] raise];
  }

  if (![self containsParticle: p]){
    if ([[tree rootCell] containsParticle: p]){
      [self removeParticle: p];
      [[tree rootCell] addParticle: p];
    }else{
      [tree handleOutParticle: p];
    }
  }
}

- (void) removeParticle: (Particle *) p
{
  population--;

  if ([self isLeaf]){
    [particles removeObject: p];
    if (population != [particles count]){
      [[NSException exceptionWithName: [self description]
                               reason: @"population != [children count]"
                             userInfo: nil] raise];
    }
    [p setCell: nil];
  }

  if (![self isRoot]){
    [parent removeParticle: p];
  }
}

- (void) addParticle: (Particle *) p
{
  population++;

  if (![self isLeaf]){
    NSEnumerator *en = [sub objectEnumerator];
    Cell *subcell;
    int k = 0;
    while ((subcell = [en nextObject])){
      if ([subcell containsParticle: p]){
        if (k == 0){
          [subcell addParticle: p];
        }
        k++;
      }
    }
    
    if (k != 1){
      [[NSException exceptionWithName: [self description]
                               reason: @"no subcell or too many subcells to add particle"
                             userInfo: nil] raise];
    }
  }else{
    if ([particles containsObject: p]){
      [[NSException exceptionWithName: [self description]
                               reason: @"Particle added in the cell already exists"
                             userInfo: nil] raise];
    }
    [particles addObject: p];
    [p setCell: self];

    if (population != [particles count]){
      [[NSException exceptionWithName: [self description]
                               reason: @"Discrepancy in population count"
                        userInfo: nil] raise];
    }
  }
}

- (void) recompute
{
  if ([self isLeaf]){
    if (population != [particles count]){
      [[NSException exceptionWithName: [self description]
                               reason: @"population != [children count]"
                             userInfo: nil] raise];
    }

    if ([self depth] < [tree maxTreeDepth] &&
        population > [tree numberOfParticlesPerCell]){
     
      [self mitosis];

      NSEnumerator *en = [sub objectEnumerator];
      Cell *c;
      while ((c = [en nextObject])){
        [c recompute];
      }
    }
  }else{
    int hasLeafs = 0;
    int divisions = [space getDivisions];
    NSEnumerator *en = [sub objectEnumerator];
    Cell *c;
    while ((c = [en nextObject])){
      [c recompute];
      if ([c isLeaf]){
        hasLeafs++;
      }
    }

    if (hasLeafs == divisions && population <= [tree numberOfParticlesPerCell]){
      [self fusion];
    }
  }

  if (data){
    [data recompute];
  }
}

- (void) mitosis
{
  if (sub != nil){
      [[NSException exceptionWithName: [self description]
                               reason: @"sub needs to be nil here"
                             userInfo: nil] raise];    
  }

  if ([particles count] <= [tree numberOfParticlesPerCell]){
    [[NSException exceptionWithName: [self description]
                             reason: @"no subdivision needed ?"
                           userInfo: nil] raise];  
  }

  int divisions = [space getDivisions];
  NSMutableArray *subdiv = [[NSMutableArray alloc] initWithCapacity: divisions];
  for (int i = 0; i < divisions; i++){
    Cell *subcell = [[Cell alloc] initChildCell: i
                                      WithSpace: [space newSubCellSpace: i]
                                       cellData: [data newCellData]
                                       andNTree: tree
                                         parent: self];
    NSMutableSet *toBeAddedBucket = [NSMutableSet set];
    NSEnumerator *en;
    Particle *p;
    en = [particles objectEnumerator];
    while ((p = [en nextObject])){
      if ([subcell containsParticle: p]){
        [toBeAddedBucket addObject: p];
      }
    }
    en = [toBeAddedBucket objectEnumerator];
    while ((p = [en nextObject])){
      [particles removeObject: p];
      [subcell addParticle: p];
    }
    [subdiv addObject: subcell];
    [subcell release];
  }
  sub = subdiv;

  if ([particles count]){
    [[NSException exceptionWithName: [self description]
                             reason: @"there are unclassified particles after mitosis ?"
                           userInfo: nil] raise];  
  }
}

- (void) fusion
{
  if ([particles count] != 0){
    [[NSException exceptionWithName: [self description]
                             reason: @"when fusioning cells, no particles should be in the destination cell"
                           userInfo: nil] raise];  
  }

  NSEnumerator *en;
  Cell *subcell;
  en = [sub objectEnumerator];
  while ((subcell = [en nextObject])){
    if (![subcell isLeaf]){
      [[NSException exceptionWithName: [self description]
                               reason: @"Fusion of non leaf-subcells"
                             userInfo: nil] raise];  
    }
    [particles addObjectsFromArray: [subcell particles]];
  }

  [sub release];
  sub = nil;

  en = [particles objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    [p setCell: self];
  }
}

- (void) resizeToBoundingBox: (NSRect) newBB
{
  if (parent != nil){
    [[NSException exceptionWithName: [self description]
                             reason: @"can only resize the root cell"
                           userInfo: nil] raise];  
  }

  // 1. We are sure we are in the root cell.
  // 2. We remove all particles from the particle box.

  int oldPopulation = population;
  NSArray *allParticles = [[NSArray alloc] initWithArray: [[tree particleBox] allParticles]];
  [[tree particleBox] removeAllParticles];

  // 3. Recompute the tree to remove all children by fusion. We do this
  //    to trigger removal events.

  if (population != 0){
    [[NSException exceptionWithName: [self description]
                             reason: @"after removal of all particles the root cell still contains particles"
                           userInfo: nil] raise];
  }

  if ([particles count] != 0){
    [[NSException exceptionWithName: [self description]
                             reason: @"after removal of all particles the root cell still contains #2"
                           userInfo: nil] raise];
  }

  [self recompute];

  if (![self isLeaf] || ![self isRoot]){
    [[NSException exceptionWithName: [self description]
                             reason: @"after particles removal the mama cell should be root and leaf"
                           userInfo: nil] raise];
  }

  // 4. We resize this root cell.

  [space setBB: newBB];
		
  // 5. Re-insert all particles in this root cell.

  NSEnumerator *en = [allParticles objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    [[tree particleBox] addParticle: p];
  }

  // 6. Recompute the tree to subdivide it. We use recompute to trigger
  //    mitosis events.

  [self recompute];

  if (population != [[[tree particleBox] allParticles] count]){
    [[NSException exceptionWithName: [self description]
                             reason: @"discrepancy when resinserting particles during mama resize"
                           userInfo: nil] raise];
  }

  if (oldPopulation != population){
   [[NSException exceptionWithName: [self description]
                             reason: @"after resize new population size != old"
                           userInfo: nil] raise];
  }
  [allParticles release];
}

- (BOOL) isValid
{
  int divisions = [space getDivisions];
  int pop = 0;

  if (![self isLeaf]){
    if (divisions != [sub count]){
      return NO;
    }

    NSEnumerator *en = [sub objectEnumerator];
    Cell *subcell;
    while ((subcell = [en nextObject])){
      if (![subcell isValid]) return NO;
      pop += [subcell population];
      if ([subcell depth] != [self depth]+1) return NO;
    }

    if (pop != [self population]) return NO;
  }
  return YES;
}

- (NSArray*) divisions
{
  return sub;
}
@end
