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
  NSEnumerator *en;
  NSNumber *number;

  //not enough samples? (minimum of 10, why?)
  if ([energies count] < 10){
    return 0;
  }

  //calculate the average
  double average = 0;
  en = [energies objectEnumerator];
  while ((number = [en nextObject])){
    average += [number doubleValue];
  }
  average /= [energies count];

  //calculate the standard deviation
  double standard = 0;
  en = [energies objectEnumerator];
  while ((number = [en nextObject])){
    standard += pow ([number doubleValue] - average, 2);
  }
  standard = sqrt (standard/[energies count]);

  return 1/standard;
}
@end
