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
- (id) initWithName: (NSString *)n
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
  return self;
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

  // for (EdgeSpring edge : neighbours) {
  //   if (!edge.ignored) {
  //     NodeParticle other = edge.getOpposite(this);

  //     delta.set(other.pos.x - pos.x, other.pos.y - pos.y,
  //               box.is3D ? other.pos.z - pos.z : 0);

  //     double len = delta.normalize();
  //     double k = box.k * edge.weight;

  //     double factor = box.K1 * (len - k);

  //     // delta.scalarMult( factor );
  //     delta.scalarMult(factor * (1f / (neighbours.size() * 0.1f))); // XXX
  //     // NEW
  //     // inertia
  //     // based
  //     // on
  //     // the
  //     // node
  //     // degree.
  //     disp.add(delta);
  //     attE += factor;

  //     box.energies.accumulateEnergy(factor);
  //   }
  // }


// [[layout energy] add: factor];
}

- (void) repulsionN2
{
  NSEnumerator *en = [[layout allParticles] objectEnumerator];
  Particle *p;
  while ((p = [en nextObject])){
    if (self != p){
      NSPoint n1p = [self position];
      NSPoint n2p = [p position];
      NSPoint dif = NSSubtractPoints (n1p, n2p);
      double distance = LMSDistanceBetweenPoints (n1p, n2p);
      double factor = distance != 0 ? ((layout->K2 / (distance*distance))) * [self weight] : 0.00001;
      repE += factor;
      disp = NSAddPoints (disp, LMSMultiplyPoint (LMSNormalizePoint(dif), factor));

      [[layout energy] add: factor];
    }
  }
}

- (BOOL) intersectionWithCell: (Cell*) c
{
  double k = layout->k;
  double vz = layout->viewZone;
  NSRect bb = [c boundingBox];
  NSRect grownPoint = LMSGrowCenterPoint ([self position], k*vz);
  return NSIntersectsRect (bb, grownPoint);
}

- (void) recurseRepulsionWithCell: (Cell*)c
{
  if ([self intersectionWithCell: c]){
    if ([c isLeaf]){
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

      if (![c isLeaf] && (size / distance) > layout->theta){
        NSEnumerator *en = [[c divisions] objectEnumerator];
        Cell *subcell;
        while ((subcell = [en nextObject])){
          [self recurseRepulsionWithCell: subcell];
        }
      }else{
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
      }
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
