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
#include "BarycenterCellData.h"
#include "NSPointFunctions.h"

@implementation BarycenterCellData
- (id) init
{
  self = [super init];
  center = NSZeroPoint;
  return self;
}

- (NSPoint) center
{
  return center;
}

- (double) weight
{
  return weight;
}

- (double) distanceFromPosition: (NSPoint)pos
{
  if (NSEqualPoints(NSZeroPoint, center) && weight != 0){
        [[NSException exceptionWithName: [self description]
                                 reason: @"bary center equals NSZeroPoint"
                               userInfo: nil] raise];
  }
  return LMSDistanceBetweenPoints (center, pos);
}

- (Cell *) cell
{
  return cell;
}

- (void) recompute
{
  NSPoint newCenter = NSZeroPoint;
  double newWeight = 0;

  if (cell == nil){
    [[NSException exceptionWithName: [self description]
                             reason: @"bary without a cell when recomputing"
                           userInfo: nil] raise];
  }

  if ([cell isLeaf]){
    int numberOfParticles = [[cell particles] count];
    NSEnumerator *en = [[cell particles] objectEnumerator];
    Particle *p;
    while ((p = [en nextObject])){
      newCenter = NSAddPoints (newCenter, [p position]);
      newWeight += [p weight];
    }
    if (numberOfParticles > 0){
      newCenter = LMSMultiplyPoint (newCenter, 1.0/numberOfParticles);
    }
  }else{
    int subcellPopCount = 0;
    int cellPopulation = [cell population];
    NSEnumerator *en = [[cell divisions] objectEnumerator];
    Cell *subcell;
    while ((subcell = [en nextObject])){
      BarycenterCellData *data = (BarycenterCellData*)[subcell data];
      int subcellPop = [subcell population];
      newCenter = NSAddPoints (newCenter,
                               LMSMultiplyPoint ([data center], subcellPop));
      newWeight += [data weight];
      subcellPopCount += subcellPop;
    }
    if (cellPopulation != subcellPopCount){
      [[NSException exceptionWithName: [self description]
                               reason: @"Discrepancy in population counts ?"
                             userInfo: nil] raise];
    }
    if (cellPopulation > 0){
      newCenter = LMSMultiplyPoint (newCenter, 1.0/cellPopulation);
    }
  }
  weight = newWeight;
  center = newCenter;
}

- (void) setCell: (Cell*) c
{
  cell = c;
}

- (BarycenterCellData*) newCellData
{
  BarycenterCellData *ret = [[BarycenterCellData alloc] init];
  [ret autorelease];
  return ret;
}
@end
