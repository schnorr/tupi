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
#include "LayoutRunner.h"

@implementation LayoutRunner
- (id) init
{
  self = [super init];
  return self;
}

- (void) dealloc
{
  [layout release];
  [super dealloc];
}

- (void) setProvider: (id) prov
{
  provider = prov;
}

- (void) setLayout: (Layout*)l
{
  layout = l;
  [layout retain];
}

- (void) sleep: (NSTimeInterval) seconds
{
  NSLog (@"sleeping for %f seconds", seconds);
  [NSThread sleepForTimeInterval: seconds];
}

- (void) run: (id) sender
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  double limit = [layout stabilizationLimit];
  NSLog (@"Stabilization Limit: %f", limit);
  [layout compute];
  [layout compute];
  while (![[NSThread currentThread] isCancelled]){
    if(limit > 0) {
      NSLog (@"stabilization: %f", [layout stabilization]);
      if([layout stabilization] > [layout stabilizationLimit]) {
        [layout compute];
        [self sleep: 0.8];
      } else {
        [layout compute];
        [self sleep: 0.1];
      }
    } else {
      [layout compute];
      [self sleep: 0.1];
    }
    [provider layoutChanged];
  }
  [pool release];
}
@end
