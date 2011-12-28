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
#include "Energy.h"

@implementation Energy
- (id) init
{
  self = [super init];
  energies = [[NSMutableArray alloc] init];
  energy = 0;
  accumulator = 0;
  length = 256;
  return self;
}

- (void) dealloc
{
  [energies release];
  [super dealloc];
}

- (void) add: (double) e
{
  accumulator += e;
}

- (void) store
{
  [energies addObject: [NSNumber numberWithDouble: accumulator]];
  if ([energies count] > length){
    [energies removeObjectAtIndex: 0];
  }
  energy = accumulator;
  accumulator = 0;
}

- (void) clear
{
  [energies removeAllObjects];
  energy = 0;
  accumulator = 0;
}

- (double) energy
{
  return energy;
}

- (double) stabilization
{
  double average = [self average];
  double diff = fabs (lastEnergy - average);

  diff = diff < 1 ? 1 : diff;
  return 1/diff;
}

- (double) average
{
  if ([energies count] == 0){
    return 0;
  }

  NSEnumerator *en = [energies objectEnumerator];
  NSNumber *number;
  double energySum = 0;
  while ((number = [en nextObject])){
    energySum += [number doubleValue];
  }
  return energySum/[energies count];
}
@end
