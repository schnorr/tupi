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
#include "FDTree.h"


@implementation FDTree
- (id) initWithCell: (NSRect)c
             parent: (FDTree*)p
{
  self = [super init];
  mycell = c;
  parent = p;
  children = nil;
  particle = NSZeroPoint;
  pseudoParticle = NSZeroPoint;
  pseudoParticleCharge = 0;
  return self;
}

- (void) dealloc
{
  [children release];
  [super dealloc];
}

- (void) splitCell
{
  NSPoint c = NSMakePoint(NSMidX(mycell), NSMidY(mycell));
  NSRect bottomLeft = NSMakeRect(mycell.origin.x, mycell.origin.y,
                                 mycell.size.width/2,
                                 mycell.size.height/2);
  FDTree *c1 = [[FDTree alloc] initWithCell: bottomLeft
                                     parent: self];


  NSRect bottomRight = NSMakeRect(c.x, mycell.origin.y, 
                                  mycell.size.width/2,
                                  mycell.size.height/2);
  FDTree *c2 = [[FDTree alloc] initWithCell: bottomRight
                                     parent: self];


  NSRect topLeft = NSMakeRect(mycell.origin.x,c.y,
                              mycell.size.width/2,
                              mycell.size.height/2);
  FDTree *c3 = [[FDTree alloc] initWithCell: topLeft
                                     parent: self];


  NSRect topRight = NSMakeRect(c.x, c.y,
                               mycell.size.width/2,
                               mycell.size.height/2);
  FDTree *c4 = [[FDTree alloc] initWithCell: topRight
                                     parent: self];
  children = [[NSMutableArray alloc] initWithObjects: c1, c2, c3, c4, nil];
  [c1 release];
  [c2 release];
  [c3 release];
  [c4 release];
}

- (void) addParticle: (NSPoint)p
{
  // NSLog (@"%@ add %@", self, NSStringFromPoint(p));
  //three situations
  //0 - zero particle, zero children
  //1 - one particle, zero children
  //2 - zero particle, four children

  if (NSEqualPoints(particle, NSZeroPoint) && children == nil){

    // NSLog (@"Case #0");
    particle = p;


  }else if(!NSEqualPoints(particle, NSZeroPoint) && children == nil){


    // NSLog (@"Case #1.1");
    [self splitCell];
    //add current particle to children
    NSEnumerator *e = [children objectEnumerator];
    FDTree *child;
    while ((child = [e nextObject])){
      if (NSPointInRect(particle, [child cell])){
        [child addParticle: particle];
        particle = NSZeroPoint;
        break;
      }
    }

    // NSLog (@"Case #1.2");
    //add new particle to children
    e = [children objectEnumerator];
    while ((child = [e nextObject])){
      if (NSPointInRect(p, [child cell])){
        [child addParticle: p];
        break;
      }
    }


  }else if(NSEqualPoints(particle, NSZeroPoint) && children != nil){


    // NSLog (@"Case #2");
    //add new particle
    NSEnumerator *e = [children objectEnumerator];
    FDTree *child;
    while ((child = [e nextObject])){
      if (NSPointInRect(p, [child cell])){
        [child addParticle: p];
        break;
      }
    }


  }else{
    NSLog (@"unknow state");
    exit(1);
  }
  pseudoParticleCharge += 10;
  //calculate "center of charge" based on gravity
  if (NSEqualPoints(pseudoParticle, NSZeroPoint)){
    pseudoParticle = p;
  }else{
    NSRect r1 = NSMakeRect(pseudoParticle.x,
                           pseudoParticle.y,
                           1, 1);
    NSRect r2 = NSMakeRect(p.x, p.y, 1, 1);
    NSRect r = NSUnionRect(r1,r2);
    pseudoParticle = NSMakePoint(NSMidX(r), NSMidY(r));
  }
  return;
}

- (NSRect) cell
{
  return mycell;
}

- (void) printWithDepth: (int)level
{
  if (NSEqualPoints(particle, NSZeroPoint)){
    NSLog(@"|#%*.*s<%p> c=%lu c=%.0f P=%@", level, level, "", self, [children count], pseudoParticleCharge, NSStringFromPoint(pseudoParticle));
  }else{
    NSLog(@"|%*.*s<%p> c=%lu p=%@", level, level, "", self, [children count], NSStringFromPoint(particle));
  }
  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    [child printWithDepth: level+1];
  }
}

- (BOOL) isEmpty
{
  // NSLog (@"isEmpty? <%p> c=%lu, particle=%@", self, [children count], 
  //        NSStringFromPoint(particle));
  return ([children count] == 0 &&
          NSEqualPoints(particle, NSZeroPoint));
}

/**
 * This function removes the children that are empty (no particles on them).
 */
- (void) clean
{
  NSMutableSet *removal = [[NSMutableSet alloc] init];
  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    if ([child isEmpty]){
      [removal addObject: child];
    }
  }
  e = [removal objectEnumerator];
  while ((child = [e nextObject])){
    [children removeObject: child];
  }
  [removal release];

  //iterate
  e = [children objectEnumerator];
  while ((child = [e nextObject])){
    [child clean];
  }
}

- (NSPoint) coulombRepulsionOfParticle:(NSPoint)p
                               charge:(double)charge
                             accuracy:(double)accuracy
{
  NSPoint force = NSMakePoint (0, 0);

  double length = mycell.size.height;
  double distance = LMSDistanceBetweenPoints (p, pseudoParticle);
  NSPoint dif = NSSubtractPoints (p, pseudoParticle);

  if (distance == 0){
    return force;
  }

  //coulomb_repulsion (k_e * (q1 * q2 / r*r))
  double coulomb_repulsion = 0;
  double coulomb_constant = 1;
  double r = distance;
  double q1 = charge;
  double q2 = pseudoParticleCharge;
  coulomb_repulsion = coulomb_constant * (q1*q2)/(r*r);
 
  force = NSAddPoints (force,
                       LMSMultiplyPoint (LMSNormalizePoint(dif),
                                         coulomb_repulsion));
  // NSLog (@"<%p> %@", self, NSStringFromPoint(force));
  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    if (NSPointInRect(p, [child cell])){
      NSPoint f = [child coulombRepulsionOfParticle:p
                                             charge:charge
                                           accuracy:accuracy];
      force = NSAddPoints(force, f);
      break;
    }
  }
  return force;
}

- (void) drawCellsWithLevel:(int)level;
{
  if (![children count]){
    NSBezierPath *path = [NSBezierPath bezierPathWithRect: mycell];
    [[NSColor blueColor] set];
    [path stroke];

    double size = pseudoParticleCharge/5;
    [[NSColor yellowColor] set];
    NSRect r = NSMakeRect(pseudoParticle.x-size/2, pseudoParticle.y-size/2, size, size);
    NSRectFill(r);

    [[NSString stringWithFormat: @"%d", level] drawAtPoint: NSMakePoint (pseudoParticle.x,
                                                                         pseudoParticle.y+size)
                                            withAttributes: nil];

  }

  NSEnumerator *e = [children objectEnumerator];
  FDTree *child;
  while ((child = [e nextObject])){
    [child drawCellsWithLevel:level+1];
  }  
}
@end

