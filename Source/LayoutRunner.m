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

- (void) setProvider: (id<TupiProvider>) prov
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
  [NSThread sleepForTimeInterval: seconds];
}

- (void) run: (id) sender
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  while (![[NSThread currentThread] isCancelled]){
    NSAutoreleasePool *looppool = [[NSAutoreleasePool alloc] init];
    double limit = [layout stabilizationLimit];
    double current = [layout stabilization];
    if (current > limit){
      [self sleep: 0.08];
    }else{
      [layout compute];
      [provider layoutChanged];
      [self sleep: 0.01];
    }
    [looppool release];
  }
  [pool release];
}
@end
