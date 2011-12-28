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
#include "Particle.h"
#include "NSPointFunctions.h"

@implementation Particle
- (id) initForGraphNode: (GraphNode*) gn
               WithName: (NSString *)n
             WithLayout: (Layout*)pb
         andParticleBox: (ParticleBox*) b
{
  self = [super init];
  name = n;
  cell = nil;
  layout = pb;
  box = b;
  frozen = NO;
  weight = 1;
  pos = NSMakePoint (drand48() * 2 * layout->k - layout->k,
                     drand48() * 2 * layout->k - layout->k);
  graphNode = gn;
  [graphNode retain];
  [graphNode setPosition: pos];
  return self;
}

- (void) dealloc
{
  [graphNode release];
  [super dealloc];
}

- (NSString *) description
{
  return name;
}

- (NSString *) name
{
  return name;
}

- (NSUInteger)hash
{
  return [name hash];
}

- (BOOL)isEqual:(id)anObject
{
  return [name isEqual: [anObject name]];
}

- (double) weight
{
  return weight;
}

- (BOOL) closeTo: (Particle *) p
{
  //TODO
  return NO;
}

- (NSPoint) position
{
  return pos;
}

- (void) setPosition: (NSPoint) newPosition
{
  pos = newPosition;
  //set the position of the corresponding graphnode
  //since drawings don't have the information about
  //the particles
  [graphNode setPosition: pos];
}

- (Cell *) cell
{
  return cell;
}

- (void) setCell: (Cell *) c
{
  cell = c;
}

- (ParticleBox *) box
{
  return box;
}

- (void) setParticleBox: (ParticleBox *) b
{
  if ((box && b) && box != b){
    [[NSException exceptionWithName: [self description]
                             reason: @"particle in two ParticleBoxes?"
                           userInfo: nil] raise];
  }
  box = b;
}

- (void) attraction
{
  int connected = [[graphNode connectedNodes] count];
  if (connected == 0){
    return;
  }
  NSEnumerator *en = [[graphNode connectedNodes] objectEnumerator];
  GraphNode *node;

  NSPoint attractionDisp = NSZeroPoint;
  while ((node = [en nextObject])){
    Particle *p = [node particle];
    if (p == nil){
      [[NSException exceptionWithName: [node description]
                               reason: @"corresponding particle of graph node is not defined"
                             userInfo: nil] raise];
    }
    NSPoint n1p = [self position];
    NSPoint n2p = [p position];
    NSPoint normalized = LMSNormalizePoint(NSSubtractPoints (n1p, n2p));
    double distance = LMSDistanceBetweenPoints (n1p, n2p);

    double factor = (layout->K1 * (distance - layout->k)) * 1/connected;

    attractionDisp = NSAddPoints (attractionDisp, LMSMultiplyPoint (normalized, -factor));

    attE += factor;
    [[layout energy] add: factor];
  }
  disp = NSAddPoints (disp, attractionDisp);
}

- (void) repulsionN2
{
  NSEnumerator *en = [[layout allParticles] objectEnumerator];
  Particle *p;
  NSPoint repulsionDisp = NSZeroPoint;
  while ((p = [en nextObject])){
    if (self != p){
      NSPoint n1p = [self position];
      NSPoint n2p = [p position];
      NSPoint dif = NSSubtractPoints (n1p, n2p);
      double distance = LMSDistanceBetweenPoints (n1p, n2p);

      if (distance > 0){
        if (distance < layout->k){
          distance = layout->k;
        }
        double factor = distance != 0 ? (layout->K2/(distance*distance)) * [p weight] : 0.00001;
        repulsionDisp = NSAddPoints (repulsionDisp, LMSMultiplyPoint (LMSNormalizePoint(dif), factor));
        repE += factor;
        [[layout energy] add: factor];
      }
    }
  }
  disp = NSAddPoints (disp, repulsionDisp);
}

- (BOOL) intersectionWithCell: (Cell*) c
{
  double k = layout->k;
  double vz = layout->viewZone;
  NSRect bb = [c boundingBox];
  NSRect grownPoint = LMSGrowCenterPoint ([self position], k*vz);
  return NSIntersectsRect (bb, grownPoint);

  //we can ignore completely the viewZone and k,
  //and just check if the particle's position is within
  //the bounding box of this cell (this gives a very low
  //quality positioning because it does not consider close
  //neighbors according to the viewZone)
  //return NSPointInRect([self position], [c boundingBox]);
}

- (void) recurseRepulsionWithCell: (Cell*)c
{
  if ([self intersectionWithCell: c]){
    if ([c isLeaf]){
      //consider all my cell mates (and the closest cells mates - defined by viewZone and quality)

      NSEnumerator *en = [[c particles] objectEnumerator];
      Particle *p;
      while ((p = [en nextObject])){
        if (self != p){
          NSPoint n1p = [self position];
          NSPoint n2p = [p position];
          NSPoint normalized = LMSNormalizePoint(NSSubtractPoints (n1p, n2p));
          double distance = LMSDistanceBetweenPoints (n1p, n2p);
         
          if (distance > 0){
            if (distance < layout->k){
              distance = layout->k;
            }
            double factor = distance != 0 ? ((layout->K2 / (distance*distance))) * [self weight] : 0.00001;
            repE += factor;
            disp = NSAddPoints (disp, LMSMultiplyPoint (normalized, factor));

            [[layout energy] add: factor];
          }
        }
      }

    }else{
      //it not leaf, just recurse

      NSEnumerator *en = [[c divisions] objectEnumerator];
      Cell *subcell;
      while ((subcell = [en nextObject])){
        [self recurseRepulsionWithCell: subcell];
      }

    }
  }else{
    if (cell != c){

      BarycenterCellData *bary = (BarycenterCellData*)[c data];
      if (bary == nil){
        [[NSException exceptionWithName: nil
                                 reason: @"bary is nil"
                               userInfo: nil] raise];
      }
      double distance = [bary distanceFromPosition: [self position]];
      double size = [[c space] size];

      if ([c isLeaf] && (size/distance) < layout->theta){
        //then include the interaction between this cell and
        //the particle in the total being accumulated

        if ([bary weight] != 0){
          NSPoint n1p = [self position];
          NSPoint n2p = [bary center];
          NSPoint normalized = LMSNormalizePoint(NSSubtractPoints (n1p, n2p));
          double distance = LMSDistanceBetweenPoints (n1p, n2p);

          if (distance > 0) {
            if (distance < layout->k){
              distance = layout->k;
            }
            double factor = distance != 0 ? ((layout->K2 / (distance*distance))) * [bary weight] : 0.00001;
            repE += factor;
            disp = NSAddPoints (disp, LMSMultiplyPoint (normalized, factor));

            [[layout energy] add: factor];
          }
        }

      }else{
        //otherwise, resolve the current cell into its [eight] four subcells,
        //and recursively examine each one in turn

        NSEnumerator *en = [[c divisions] objectEnumerator];
        Cell *subcell;
        while ((subcell = [en nextObject])){
          [self recurseRepulsionWithCell: subcell];
        }
      }
    }else{
      [[NSException exceptionWithName: [self description]
                               reason: @"cell == c, but it shouldn't because this point is not intersecting c"
                             userInfo: nil] raise];
    }
  }
}

- (void) repulsionNLogN
{
  [self recurseRepulsionWithCell: [layout rootCell]];
}

- (void) move: (long) time
{
  if (!frozen) {
    disp = NSZeroPoint;
    repE = 0;
    attE = 0;

    if (layout->viewZone < 0){
      [self repulsionN2];
    }else{
      [self repulsionNLogN];
    }
    [self attraction];

    disp = LMSMultiplyPoint (disp, layout->force);
    len = LMSDistanceBetweenPoints (NSZeroPoint, disp);

    if (len > (layout->diagonalOfArea / 2)) {
      disp = LMSMultiplyPoint (disp, (layout->diagonalOfArea/2)/len);
      len = layout->diagonalOfArea / 2;
    }

    layout->averageLength += len;

    if (len > layout->maxMoveLength){
      layout->maxMoveLength = len;
    }
    //the displacement is registered in "disp"
    //but this should not be reflected yet to the particle's position
    //the nextStep method is used to commit the change
  }
}

- (void) nextStep: (long) time
{
  if (!NSEqualPoints (NSZeroPoint, disp)){
    NSPoint nextPos = NSAddPoints ([self position], disp);
    [self setPosition: nextPos];
    layout->numberOfMovedNodes++;

    if (cell == nil){
      [[NSException exceptionWithName: [self description]
                               reason: @"No responsible cell?"
                             userInfo: nil] raise];
    }

    [cell moveParticle: self];

    disp = NSZeroPoint;
  }
}

- (void) suicide
{
  [box removeParticle: self];
}

- (void) inserted
{
}

- (void) removed
{
}
@end
